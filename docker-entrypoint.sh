#!/bin/sh

# Set default port if not provided
NGINX_PORT=${NGINX_PORT:-80}

# Use envsubst to replace variables in the template and create the actual config
envsubst '${NGINX_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# Remove the template file to avoid conflicts
rm -f /etc/nginx/conf.d/default.conf.template

# Start nginx
exec nginx -g "daemon off;" 