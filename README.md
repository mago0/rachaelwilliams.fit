# Rachael Williams Online Strength and Mobility

Welcome to the repository for [rachaelwilliams.fit](https://rachaelwilliams.fit). This website is a platform for Rachael Williams, a professional personal trainer, to offer her strength and mobility training services to clients.

This repository contains the source code for the website, along with setup files, scripts, tests, and other resources necessary to run, maintain, and scale the platform.

## Runtime Environment

This application is written in Node.js and uses Express. Most of the web UI is written in plain HTML, CSS, and Javascript.

It's built on top of Docker and deployed to AWS using ECS/Fargate and an Application Load-balancer. We're using Terraform and AWS Copilot to manage the environment and deployments.

## Installing & Running the App

Before you run the application, it is necessary to have [Docker](https://docs.docker.com/get-docker/) installed on your machine. After Docker is installed, follow these steps:

1. Clone and navigate into this repository:

```
git clone https://github.com/mago0/rachaelwilliams.fit.git
cd rachaelwilliams.fit
```

2. Build and run the Docker image via Docker Compose:

```
docker compose up
# or
npm run dev
```

3. (optional) View the container logs.

```
docker compose logs -f
# or
npm run dev:logs
```

4. Open up your from browser and navigate to `http://localhost:3000`.

## Building and Deploying

This needs AWS credentials for Terraform and Copilot. I recommend setting the following:

```
export AWS_PROFILE=
export AWS_REGION=
```

### Terraform

```
cd terraform
terraform init
terraform apply
```

### AWS Copilot (manual)

Note: The `AmazonSESFullAccess` policy must be added to `webapp-prod-frontend-TaskRole` in order for the contact form to submit successfully.

1. Deploy env prod: `copilot env deploy --name prod`
2. Deploy the prod service: `COPILOT_ENVIRONMENT=prod copilot svc deploy --env prod`

### AWS Copilot (pipeline)

This deployment method is automated.

1. Push to git @main will deploy prod

### Feedback

I'm not sure why you'd be contributing to this but you can do so [here](https://github.com/mago0/rachaelwilliams.fit/issues).
