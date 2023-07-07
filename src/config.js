const getEnv = () => {
  if (process.env.NODE_ENV === "prod") {
    return "prod"
  }
  if (process.env.NODE_ENV === "stag") {
    return "stag"
  }
  return "dev"
}

const config = {
  dev: {
    listenPort: 3000,
    region: "us-east-1",
    stripePricingTableID: "prctbl_1NNLbnLU6KY872bh1XbbHU2r",
    stripePublishableKey:
      "pk_test_51NHsWeLU6KY872bhgEcKezmgDDuTzcRQZ0vbglFGOq7nAbR9lKAMSfCQMy9S8f0Poe8kPO7qn3AARcgHl7XLVrv000remIaaIz",
  },
  stag: {
    listenPort: 3000,
    region: "us-east-1",
    stripePricingTableID: "prctbl_1NNLbnLU6KY872bh1XbbHU2r",
    stripePublishableKey:
      "pk_test_51NHsWeLU6KY872bhgEcKezmgDDuTzcRQZ0vbglFGOq7nAbR9lKAMSfCQMy9S8f0Poe8kPO7qn3AARcgHl7XLVrv000remIaaIz",
  },
  prod: {
    listenPort: 3000,
    region: "us-east-1",
    stripePricingTableID: "prctbl_1NQC7rLU6KY872bhoZuugpAJ",
    stripePublishableKey:
      "pk_live_51NHsWeLU6KY872bhQGQXnc1Dk5jUKPAkBNo68YvoBa3QUvyKBm44RpZc52cC5qMTVUCSWI8v1qzfUUZy0eQ2J7mc00yEdZZfTR",
  },
}

module.exports = config[getEnv()]
