FROM nginx:alpine

# Force fresh build (update this comment to bust cache)
# Build timestamp: 2025-07-21

# Remove ALL default configs to prevent port 80 binding
RUN rm -rf /etc/nginx/conf.d/*
RUN rm -rf /etc/nginx/sites-enabled/ 2>/dev/null || true
RUN rm -rf /etc/nginx/sites-available/ 2>/dev/null || true

# Verify no configs exist that could bind to port 80
RUN find /etc/nginx -name "*.conf" -exec grep -l "listen.*80" {} \; || echo "No port 80 configs found - good!"

# Copy our config (only listens on 8123)
COPY nginx.redirect.conf /etc/nginx/conf.d/redirect.conf

# Verify our config is the only one
RUN ls -la /etc/nginx/conf.d/
RUN cat /etc/nginx/conf.d/redirect.conf

# Expose only port 8123
EXPOSE 8123 