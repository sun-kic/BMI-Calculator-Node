# Use the official Node.js slim image as the base
FROM node:slim

# Create and set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if present)
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 3000

# Define the container startup command
CMD ["node", "server.js"]
