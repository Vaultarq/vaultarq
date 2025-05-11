FROM node:18-slim

WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy application code
COPY server.js .

# Copy Vaultarq binary (will be mounted at runtime)
# The actual binary will be mounted from the host

# Expose the port the app runs on
EXPOSE 3000

# Start the application with secrets loaded from Vaultarq
CMD ["node", "server.js"] 