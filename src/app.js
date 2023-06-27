const express = require('express')
const dotenv = require('dotenv')
const path = require('path')
const config = require('./config')

dotenv.config()
const environment = process.env.NODE_ENV || 'dev'
const port = process.env.PORT || config.listenPort
const stripePricingTableID = process.env.STRIPE_PRICING_TABLE_ID || config.stripePricingTableID
const stripePublishableKey = process.env.STRIPE_PUBLISHABLE_KEY || config.stripePublishableKey
const stripeSecretKey = process.env.STRIPE_SECRET_KEY

if (!stripeSecretKey) {
  console.error('Missing Stripe secret key. Set the STRIPE_SECRET_KEY environment variable.')
  process.exit(1)
}

console.log(`Environment: ${environment}`)
console.log(`Secret Key ID: ${stripeSecretKey}`)

// Create an Express app
const app = express()
// Use the EJS templating language
app.set("view engine", "ejs")
app.set('views', path.join(__dirname, 'views'))

// Serve static assets from the 'public' folder
app.use(express.static(path.join(__dirname, 'public')))

app.get("/healthz", (req, res) => {
  res.status(200).send("OK")
})

app.get("/packages", (req, res) => {
  res.render("packages", { pricingTableId: stripePricingTableID, publishableKey: stripePublishableKey })
})

// If no matching route is found, serve the main index.html file
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'))
})

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`)
})
