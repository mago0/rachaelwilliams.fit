#!/bin/bash
set -eux -o pipefail

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 595378669852.dkr.ecr.us-east-1.amazonaws.com
docker build -t webapp .
docker tag webapp:latest 595378669852.dkr.ecr.us-east-1.amazonaws.com/webapp:latest
docker push 595378669852.dkr.ecr.us-east-1.amazonaws.com/webapp:latest
