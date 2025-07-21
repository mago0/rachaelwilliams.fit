FROM nginx:alpine

# Remove default config
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy our config
COPY nginx.redirect.conf /etc/nginx/conf.d/redirect.conf

# Expose port 8123
EXPOSE 8123 