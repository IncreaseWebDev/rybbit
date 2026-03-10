#!/bin/bash
# Build custom IWD Analytics Docker images

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Building Custom IWD Analytics Docker Images             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd /home/ubuntu/rybbit

# Load environment variables (only what we need for build args)
if [ -f .env ]; then
    export BASE_URL=$(grep "^BASE_URL=" .env | cut -d '=' -f2)
    export DISABLE_SIGNUP=$(grep "^DISABLE_SIGNUP=" .env | cut -d '=' -f2)
    export MAPBOX_TOKEN=$(grep "^MAPBOX_TOKEN=" .env | cut -d '=' -f2)
fi

# Build custom backend image
echo "🔨 Building custom backend image..."
echo "   (This includes SMTP email support)"
sudo docker build --no-cache \
    -f branding/backend/Dockerfile.custom \
    -t iwd-analytics-backend:latest \
    -t iwd-analytics-backend:$(date +%Y%m%d) \
    .

echo "✅ Backend image built successfully!"
echo ""

# Build custom client image
echo "🔨 Building custom client image..."
echo "   (This includes IWD Analytics branding)"
sudo docker build --no-cache \
    -f branding/client/Dockerfile.custom \
    --build-arg NEXT_PUBLIC_BACKEND_URL="${BASE_URL}" \
    --build-arg NEXT_PUBLIC_DISABLE_SIGNUP="${DISABLE_SIGNUP}" \
    --build-arg NEXT_PUBLIC_MAPBOX_TOKEN="${MAPBOX_TOKEN}" \
    -t iwd-analytics-client:latest \
    -t iwd-analytics-client:$(date +%Y%m%d) \
    .

echo "✅ Client image built successfully!"
echo ""

# Show built images
echo "📦 Custom images built:"
sudo docker images | grep "iwd-analytics"

echo ""
echo "✅ All custom images built successfully!"
echo ""
echo "Next steps:"
echo "  1. Review docker-compose.override.yml"
echo "  2. Run: docker compose down"
echo "  3. Run: docker compose up -d"
