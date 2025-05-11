FROM node:18-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy Vaultarq files
COPY . .

# Install Vaultarq (using relative path to avoid PATH issues)
RUN ./install.sh /usr/local/bin

# Create a data volume for persistent storage
VOLUME /root/.vaultarq

# Set the entrypoint to be the vaultarq CLI
ENTRYPOINT ["vaultarq"]

# Default command shows usage information
CMD ["--help"] 