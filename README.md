# Rachael Williams Online Strength and Mobility

Welcome to the repository for *rachaelwilliams.fit*. This website is primarily designed as a platform for Rachael Williams, a professional personal trainer, to offer her strength and mobility training services to clients.

This repository contains the source code for the website, along with setup files, scripts, tests, and other resources necessary to run, maintain, and scale the platform.

## Project Structure

```
rachaelwilliams.fit
|-- Dockerfile
|-- docker-compose.yaml
|-- package-lock.json
|-- package.json
|-- devenv.nix
|-- devenv.lock
|-- devenv.yaml
|-- terraform/
|-- scripts/
|   |-- build-push-ecr.sh
|   |-- readme-gen.sh
|-- src/
|   |-- app.js
|   |-- config.js
|   |-- public/
|   |   |-- home.html
|   |   |-- about.html
|   |   |-- contact.html
|   |   |-- ...
|   |-- views/
|   |   |-- packages.ejs
```

## Runtime Environment

This application is written in Node.js and uses Express. As a cross-platform backend framework, Express allows our application to be run on a diverse array of hosting platforms. 

Even more, by using Docker, we ensure that our application is further isolated and bundled with its dependencies, making our application more secure and scalable. This means our application can be run locally or in a production environment with the same Docker configurations and without any additional setup.

## Installing & Running the App

Before you run the application, it is necessary to have [Docker](https://docs.docker.com/get-docker/) installed on your machine. After Docker is installed, follow these steps:

1. Clone this repository:
```
git clone https://github.com/mago0/rachaelwilliams.fit.git
```

2. Navigate into the repository:
```
cd rachaelwilliams.fit
```

3. Build the Docker image:
```
docker build -t webapp .
```

4. Run the Docker image:
```
docker run -p 3000:3000 webapp
```

5. Open up your from browser and navigate to `http://localhost:3000`.

We also provide a `docker-compose.yaml` file for easier development and testing. You can use this file to run the app by using the command: `docker-compose up`.

## Testing

To run all tests:
```
npm test
```
Note: As of now, this script will exit with code 1 (error) as no tests have been specified.

## Additional Scripts

In the `scripts/` folder, you'll find additional scripts related to the application:

- The `build-push-ecr.sh` script is used to build a Docker image of the application and push it to the AWS ECR registry. 
- The `readme-gen.sh` simply contains a boilerplate script to generate a README file for a project. 

## Environmental Variables

Certain configurations are sensitive and are therefore loaded in as environment variables. An example of this are the Stripe API keys. These keys are loaded in using the dotenv npm package. An example .env file is provided in the `.env.example` file. 

## Building and Deploying

This project uses Terraform to automate infrastructure creation on AWS. The configuration files are divided into two parts: `01_base` and `02_app`, each in their corresponding folders.

### `./01_base` 

The main Terraform configuration file in this folder is `main.tf` and is responsible for setting up the base infrastructure. 

Here is what is being created:

- __AWS Provider__: Specifies that AWS is the cloud provider and the region it operates in.
- __VPC Resources__: Creates a Virtual Private Cloud (VPC), Elastic Container Registry (ECR) repository, Security Groups for ECS service and Application Load Balancer (ALB).
- __Subnet Resources__: Defines four subnets, 2 public and 2 private for different availability zones.
- __Internet Gateway and Routing__: Sets up an internet gateway and routing table for the VPC and subnets, connecting subnets to the internet gateway.
- __Elastic IP and NAT Gateway__: Creates an Elastic IP and associates it with a NAT Gateway, for access to the internet from the private subnet.
- __VPC Endpoint__: An interface to connect to AWS services without a NAT gateway, specifically the SecretsManager.

In the same folder, the `route53.tf` file sets up the DNS configuration with Route 53. It creates a hosted zone and several DNS record sets, primarily for email service and website domain verification purposes.

The `backend.tf` file configures Amazon S3 for Terraform state storage. It ensures the terraform state file (which keeps track of the infrastructure resources created by terraform) is stored in an S3 bucket. This aids in managing and versioning the Terraform state.

### `./02_app`

The main Terraform configuration in this directory is found in `main.tf` and it creates resources necessary for the application to run.

Here is what is being created:

- __ECS Cluster__: The base for the application to run on with an associated log group for storing container logs.
- __IAM Roles__: An execution role for ECS tasks is created together with several policy attachments that give necessary permissions to the ECS service.
- __ECS Task Definition and Service__: The task definition includes one container that runs the application. The ECS service then uses this task definition to launch the application.
- __Load Balancer__: The configuration creates an Application Load Balancer, with listeners on ports 80 and 443 (HTTP and HTTPS) and it also creates Route 53 record that points to the Load Balancer's DNS name.
- __Listener Rules__: The configuration also establishes listener rules that forward all incoming requests to the target group where ECS services are registered.

The `backend.tf` file is similar to the one in `01_base` directory, but with a different `workspace_key_prefix`, indicating that it is for the application space. This ensures the Terraform state for the application is stored separately from the base infrastructure.

### Feedback
In case of any issues, please feel free to open an issue on GitHub [here](https://github.com/mago0/rachaelwilliams.fit/issues).
