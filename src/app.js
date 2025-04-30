const express = require("express")
const dotenv = require("dotenv")
const config = require("./config")

dotenv.config()
const environment = process.env.NODE_ENV || "dev"
const port = process.env.PORT || config.listenPort

console.log(`Environment: ${environment}`)

// Create an Express app
const app = express()

// Health check endpoint for container health monitoring
app.get("/healthz", (req, res) => {
  res.status(200).send("OK")
})

// Redirect all other requests to the new website
app.use((req, res) => {
  res.redirect(301, "https://rwpersonaltraining.com")
})

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`)
})
