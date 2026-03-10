#!/bin/bash
# Update Rybbit with Custom Images
# This script updates Rybbit and rebuilds custom images

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        Updating Rybbit with Custom IWD Analytics             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd /var/www/rybbit

# Step 1: Pull latest Rybbit code
echo "📥 Pulling latest Rybbit code..."
git stash 2>/dev/null || true
git pull
echo "✅ Code updated"
echo ""

# Step 2: Stop current services
echo "🛑 Stopping current services..."
sudo docker compose down
echo "✅ Services stopped"
echo ""

# Step 3: Rebuild custom images
echo "🔨 Rebuilding custom images with latest Rybbit base..."
./branding/build-images.sh
echo ""

# Step 4: Start services with custom images
echo "🚀 Starting services with custom images..."
sudo docker compose up -d
echo "✅ Services started"
echo ""

# Step 5: Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
sudo docker compose ps
echo ""

echo "✅ Update complete!"
echo ""
echo "🎉 IWD Analytics is now running with:"
echo "   • Latest Rybbit v2.0.1"
echo "   • SMTP email support (Google Workspace)"
echo "   • IWD Analytics branding"
echo ""
echo "Monitor logs: docker compose logs -f"
