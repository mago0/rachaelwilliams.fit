const express = require("express")
const axios = require("axios")
const compression = require("compression")
const dotenv = require("dotenv")
const path = require("path")
const config = require("./config")
const AWS = require("aws-sdk")

dotenv.config()
const environment = process.env.NODE_ENV || "dev"
const port = process.env.PORT || config.listenPort
const region = process.env.REGION || config.region
const stripePricingTableID =
  process.env.STRIPE_PRICING_TABLE_ID || config.stripePricingTableID
const stripePublishableKey =
  process.env.STRIPE_PUBLISHABLE_KEY || config.stripePublishableKey
const recaptchaSecretKey =
  process.env.RECAPTCHA_SECRET_KEY || config.recaptchaSecretKey
const recaptchaSiteKey =
  process.env.RECAPTCHA_SITE_KEY || config.recaptchaSiteKey

console.log(`Environment: ${environment}`)

// Create an Express app
const app = express()
// Use the EJS templating language
app.set("view engine", "ejs")
app.set("views", path.join(__dirname, "views"))

app.use(compression())

// Serve static assets from the 'public' folder
app.use(express.static(path.join(__dirname, "public")))

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

const ses = new AWS.SES({ region })

const buildParams = (data, contents) => {
  return {
    Destination: {
      ToAddresses: ["rachael+contact@rachaelwilliams.fit"],
    },
    Message: {
      Body: {
        Text: { Data: contents },
      },
      Subject: { Data: `Contact Form Submission: ${data.name}` },
    },
    Source: "noreply@rachaelwilliams.fit",
  }
}

// POSTs
app.post("/contact", async (req, res) => {
  const data = req.body

  if (!data["g-recaptcha-response"]) {
    return res.status(400).send("reCAPTCHA token is missing.")
  }

  const verificationURL = `https://www.google.com/recaptcha/api/siteverify`
  const token = data["g-recaptcha-response"]

  try {
    const response = await axios.post(
      verificationURL,
      `secret=${recaptchaSecretKey}&response=${token}`,
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      },
    )

    if (
      !response.data.success ||
      (response.data.score && response.data.score < 0.5)
    ) {
      const errorReason = response.data["error-codes"] || "low score"
      console.log("reCAPTCHA verification failed:", errorReason)
      return res.status(401).send("Failed captcha verification")
    }

    // Use the email and message fields from the contact form
    const contents = `Message: ${data.message}\n\nName: ${data.name}\nEmail: ${data.email}\n`
    const params = buildParams(data, contents)

    if (process.env.NODE_ENV === "dev") {
      console.log("Development mode - skipping email send")
      return res.status(200).send("Email would be sent in production.")
    }

    ses.sendEmail(params, function (err, sesResponse) {
      if (err) {
        console.error("Error sending email:", err)
        return res.status(500).send("Error sending email")
      }
      console.log("Email sent successfully:", sesResponse)
      return res.status(200).send("Email sent successfully")
    })
  } catch (error) {
    console.error(
      "Error during reCAPTCHA verification or email sending:",
      error,
    )
    return res.status(500).send("Server error")
  }
})

app.post("/inquiry", (req, res) => {
  const data = req.body

  // concatenates all form data into a string
  const contents = `Name and Age: ${data.name}\n
  Goal: ${data.goals}\n
  Occupation: ${data.occupation}\n
  Hobbies: ${data.hobbies}\n
  Seriousness: ${data.seriousness}\n
  Investment Readiness: ${data["investment-readiness"]}\n
  Cell Phone Number: ${data.cellNumber}`

  const params = buildParams(data, contents)

  console.log("params: ", params)
  console.log("contents: ", contents)

  if (process.env.NODE_ENV === "dev") {
    res.status(200).send("OK")
  } else {
    ses.sendEmail(params, function (err, data) {
      if (err) {
        console.log(err, err.stack)
        res.status(500).send("Something went wrong")
      } else {
        console.log(data)
        res.status(200).send("OK")
      }
    })
  }
})

app.get("/healthz", (req, res) => {
  res.status(200).send("OK")
})

app.get("/packages", (req, res) => {
  res.render("packages", {
    pricingTableId: stripePricingTableID,
    publishableKey: stripePublishableKey,
  })
})

app.get("/", (req, res) => {
  res.render("index")
})

app.get("/about", (req, res) => {
  res.render("about")
})

app.get("/contact", (req, res) => {
  res.render("contact", {
    recaptchaSiteKey,
  })
})

app.get("/inquiry-confirmation", (req, res) => {
  res.render("inquiry-confirmation")
})

// If no matching route is found, serve the main index.html file
// app.use((req, res) => {
//   res.sendFile(path.join(__dirname, "public", "index.html"))
// })

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`)
})
