FROM nginx:alpine

# Remove ALL default configs to prevent port 80 binding
RUN rm -f /etc/nginx/conf.d/*
RUN rm -f /etc/nginx/sites-enabled/* 2>/dev/null || true
RUN rm -f /etc/nginx/sites-available/* 2>/dev/null || true

# Copy our config (only listens on 8123)
COPY nginx.redirect.conf /etc/nginx/conf.d/redirect.conf

# Expose only port 8123
EXPOSE 8123 