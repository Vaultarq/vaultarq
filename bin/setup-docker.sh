#!/bin/bash
# Setup script for Docker deployment

# Create bin directory if it doesn't exist
mkdir -p $(dirname "$0")

echo "Setting up Vaultarq for Docker deployment..."

# Build the Vaultarq container
docker-compose build vaultarq

# Create a helper function to run Vaultarq in the container
cat > vaultarq-docker.sh << 'EOF'
#!/bin/bash
# Helper script to run Vaultarq in Docker

# Run the Vaultarq container with the provided arguments
docker-compose run --rm vaultarq "$@"
EOF

chmod +x vaultarq-docker.sh

# Copy the Vaultarq binary from the container for use by other containers
echo "Extracting Vaultarq binary for shared use..."
docker-compose run --rm vaultarq bash -c "cp /usr/local/bin/vaultarq /app/bin/"
chmod +x bin/vaultarq

echo "Setup complete!"
echo ""
echo "To initialize Vaultarq:"
echo "./vaultarq-docker.sh init"
echo ""
echo "To add secrets:"
echo "./vaultarq-docker.sh push API_KEY=mysecret"
echo ""
echo "To run the example app with secrets:"
echo "docker-compose run example" 