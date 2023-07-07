const express = require("express")
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

console.log(`Environment: ${environment}`)

// Create an Express app
const app = express()
// Use the EJS templating language
app.set("view engine", "ejs")
app.set("views", path.join(__dirname, "views"))

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
app.post("/contact", (req, res) => {
  const data = req.body

  const contents = `${data.message}\n\n${data.name}\n${data.email}\n`

  var params = buildParams(data, contents)

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

// If no matching route is found, serve the main index.html file
app.use((req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"))
})

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`)
})
