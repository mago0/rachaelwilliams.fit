# Rachael Williams Redirect Service

Simple nginx-based redirect service for [rachaelwilliams.fit](https://rachaelwilliams.fit) that redirects all traffic to [rwpersonaltraining.com](https://rwpersonaltraining.com).

## Overview

This repository contains a lightweight Docker Compose setup that runs an nginx container to handle 301 redirects from the old domain to the new personal training website.

## Runtime Environment

- **Web Server**: nginx (alpine image)
- **Container Platform**: Docker Compose
- **SSL Termination**: Handled upstream by nginx proxy manager

## Files

- `docker-compose.yml` - Docker Compose configuration
- `nginx.conf.template` - nginx configuration template for redirects
- `.env.example` - Example environment configuration
- `README.md` - This file

## Running the Service

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose installed

### Local Development/Testing

1. Clone this repository:
```bash
git clone https://github.com/mago0/rachaelwilliams.fit.git
cd rachaelwilliams.fit
```

2. (Optional) Configure the port by creating a `.env` file:
```bash
cp .env.example .env
# Edit .env to set NGINX_PORT if different from 80
```

3. Start the service:
```bash
docker-compose up -d
```

4. Test the redirect:
```bash
curl -I http://localhost/
# Should return: HTTP/1.1 301 Moved Permanently
# Location: https://rwpersonaltraining.com/
```

5. Test the health check:
```bash
curl http://localhost/healthz
# Should return: OK
```

### Production Deployment

This service is designed to be deployed via Portainer by pointing it at this repository. The Docker Compose file will automatically:

- Pull the `nginx:alpine` image
- Mount the nginx configuration
- Expose port 80 for the upstream proxy
- Include health checks and restart policies

## Configuration

### Environment Variables

- `NGINX_PORT` - Port for nginx to listen on (default: 80)

### nginx Configuration

The nginx configuration provides:

- **Health Check Endpoint**: `GET /healthz` returns `200 OK`
- **Redirect**: All other requests redirect to `https://rwpersonaltraining.com` with 301 status
- **URI Preservation**: Original request URI is preserved in the redirect
- **Dynamic Port**: Port can be configured via `NGINX_PORT` environment variable

## Monitoring

The service includes a health check endpoint at `/healthz` that can be used by:
- Docker health checks (configured in docker-compose.yml)
- Load balancers
- Monitoring systems

Health checks run every 30 seconds and consider the service healthy when the `/healthz` endpoint responds successfully.
