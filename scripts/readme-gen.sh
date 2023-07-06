#!/bin/bash

# List all files and directories in the root directory
echo "===== Tree ====="
tree -L 5 --gitignore

echo "===== package.json ====="
cat package.json

echo "===== .env.example ====="
cat .env.example

# Dockerfile & Docker Compose
echo "===== Dockerfile & docker-compose.yaml ====="
cat Dockerfile
cat docker-compose.yaml

# Devenv files
echo "===== Devenv(Nix) files ======"
cat devenv.lock
cat devenv.nix
cat devenv.yaml

# Build and Push script
echo "===== Build and Push script ====="
cat scripts/build-push-ecr.sh

# Server files and config
echo "===== app.js ====="
cat src/app.js

echo "===== config.js ====="
cat src/config.js

# Frontend files
echo "===== Frontend HTML/CSS Comments ====="
grep '<!--' -r src/public

# Views
echo "===== packages.ejs ====="
cat src/views/packages.ejs
