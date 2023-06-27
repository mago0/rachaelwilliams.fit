FROM --platform=linux/amd64 node:18

WORKDIR /usr/src/app

# Copy package.json and package-lock.json files to the working directory
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the rest of the application code to the container's working directory
COPY src .

# Expose the port the app will run on
EXPOSE 3000

# Start the server
CMD ["node", "app.js"]
