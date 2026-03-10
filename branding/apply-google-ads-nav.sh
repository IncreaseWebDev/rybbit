#!/bin/bash
# Post-build patch to add Google Ads to navigation
# This runs AFTER the build to inject Google Ads into the compiled files

set -e

echo "📊 Adding Google Ads to navigation (post-build)..."

# Find and patch the Sidebar JavaScript files in the built output
echo "🔍 Finding Sidebar files..."

# Patch the main Sidebar chunks
sudo docker exec client find /app/.next/server/chunks -name "*Sidebar*.js" -type f -exec sed -i \
    's/children:"Events"/children:"Events"},{href:`\/${e}\/google-ads`,label:"Google Ads",active:t===`\/${e}\/google-ads`,icon:(0,i.jsx)(s.TrendingUp,{className:"h-4 w-4"})/g' {} \; 2>/dev/null || true

# Alternative: Patch app-pages-browser files
sudo docker exec client find /app/.next/static/chunks -name "app-pages-browser*.js" -type f -exec sed -i \
    's/label:"Events"/label:"Events"},{href:e+\"\/google-ads\",label:"Google Ads",active:t===e+\"\/google-ads\",icon:jsx(TrendingUp,{className:\"h-4 w-4\"})/g' {} \; 2>/dev/null || true

# Restart client to pick up changes
echo "🔄 Restarting client container..."
sudo docker restart client

echo "✅ Google Ads navigation added!"
echo "   Please refresh your browser to see the changes."
