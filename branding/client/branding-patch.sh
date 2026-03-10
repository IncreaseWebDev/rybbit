#!/bin/sh
# ============================================================================
# Pre-build branding patch for IWD Analytics
# ============================================================================
#
# ⚠️  CRITICAL: This script runs BEFORE the Next.js build
#
# 📖 FULL DOCUMENTATION: /var/www/rybbit/branding/README-BRANDING-SYSTEM.md
#
# Purpose:
#   - Apply IWD Analytics branding (logos, text, domains)
#   - Replace Footer.tsx to remove GitHub links
#   - Enable self-hosted features (Pages, Performance, Web Vitals)
#   - Call additional feature scripts (goals-addon-feature.sh)
#
# When it runs:
#   - During Docker build (see Dockerfile.custom)
#   - Before Next.js compiles the application
#   - Changes are baked into production bundle
#
# Adding new features:
#   1. Create your feature script in /branding/client/
#   2. Add a call to it in this file (see line 76-78 for example)
#   3. Rebuild: docker compose build --no-cache client
#
# ============================================================================

set -e

echo "🎨 Applying IWD Analytics branding to source files..."

# Replace logos
if [ -f "/branding/logo.svg" ]; then
    echo "📦 Copying logos..."
    # Create rybbit directory if it doesn't exist
    mkdir -p /app/client/public/rybbit
    
    # Copy IWD logo to all Rybbit logo locations
    cp /branding/logo.svg /app/client/public/rybbit.svg
    cp /branding/logo.svg /app/client/public/rybbit-text.svg
    cp /branding/logo.svg /app/client/public/rybbit-bg.svg
    cp /branding/logo.svg /app/client/public/rybbit/frog_white.svg
    cp /branding/logo.svg /app/client/public/rybbit/horizontal_white.svg
    echo "✅ Logos copied"
fi

# Replace favicon
if [ -f "/branding/favicon.ico" ]; then
    echo "📦 Copying favicon..."
    cp /branding/favicon.ico /app/client/src/app/favicon.ico
    cp /branding/favicon.ico /app/client/public/favicon.ico 2>/dev/null || true
    echo "✅ Favicon copied"
fi

# Skip apple-icon (corrupted file)

# Text replacements in source files (before build)
echo "📝 Applying text replacements..."

# Replace Footer.tsx with custom version without GitHub links
FOOTER_FILE="/app/client/src/app/components/Footer.tsx"
if [ -f "$FOOTER_FILE" ]; then
    echo "📝 Replacing Footer.tsx..."
    cat > "$FOOTER_FILE" << 'FOOTER_EOF'
import Link from "next/link";

export function Footer() {
  const APP_VERSION = process.env.NEXT_PUBLIC_APP_VERSION;

  return (
    <div className="flex justify-center items-center h-12 text-neutral-400 gap-4 text-xs">
      <p>© 2025 IWD Analytics</p>
      <p>v{APP_VERSION}</p>
      <Link href="https://increasewebdesign.com/docs" className="hover:text-neutral-300">
        Docs
      </Link>
    </div>
  );
}
FOOTER_EOF
    echo "✅ Footer.tsx replaced"
fi

echo "📝 Applying text replacements..."

# Replace "Rybbit" with "IWD Analytics" in user-facing strings ONLY
# These are very specific replacements that won't break code
find /app/client/src -type f \( -name "*.tsx" -o -name "*.ts" \) -exec sed -i \
    -e 's/"Rybbit"/"IWD Analytics"/g' \
    -e "s/'Rybbit'/'IWD Analytics'/g" \
    -e 's/>Rybbit</>IWD Analytics</g' \
    -e 's/title="Rybbit/title="IWD Analytics/g' \
    -e 's/alt="Rybbit/alt="IWD Analytics/g' \
    -e 's/ - Rybbit/ - IWD Analytics/g' \
    -e 's/powered by Rybbit/powered by IWD Analytics/g' \
    -e 's/Welcome to Rybbit/Welcome to IWD Analytics/g' \
    -e 's/from Rybbit/from IWD Analytics/g' \
    -e 's/to Rybbit/to IWD Analytics/g' \
    -e 's/Liking Rybbit/Liking IWD Analytics/g' \
    {} \; 2>/dev/null || true

# Replace RybbitLogo component to use IWD Analytics branding
LOGO_FILE="/app/client/src/components/RybbitLogo.tsx"
if [ -f "$LOGO_FILE" ]; then
    echo "📝 Updating RybbitLogo component..."
    sed -i 's/alt="Rybbit"/alt="IWD Analytics"/g' "$LOGO_FILE"
    echo "✅ RybbitLogo component updated"
fi

# Replace domain references
find /app/client/src -type f \( -name "*.tsx" -o -name "*.ts" \) -exec sed -i \
    -e 's/rybbit\.io/increasewebdesign.com/g' \
    -e 's/rybbit\.com/increasewebdesign.com/g' \
    {} \; 2>/dev/null || true

# Replace Rybbit in translation files
echo "📝 Updating translation files..."
find /app/client/messages -type f -name "*.json" -exec sed -i \
    -e 's/"Rybbit/"IWD Analytics/g' \
    -e 's/Rybbit /IWD Analytics /g' \
    -e 's/ Rybbit/ IWD Analytics/g' \
    {} \; 2>/dev/null || true
echo "✅ Translation files updated"

# Fix forgot password link - remove IS_CLOUD gate so it shows on self-hosted
echo "🔧 Enabling forgot password link for self-hosted..."
LOGIN_FILE="/app/client/src/app/login/page.tsx"
if [ -f "$LOGIN_FILE" ]; then
    perl -i -0pe 's/rightElement=\{\s*\n\s*IS_CLOUD && \(\s*\n(\s*<Link href="\/reset-password"[^\n]*\n\s*[^\n]*\n\s*\))\s*\n\s*\}/rightElement={\n                    \1\n                  }/g' "$LOGIN_FILE" 2>/dev/null || true
    echo "✅ Forgot password link enabled"
fi

# Enable Pages and Performance tabs for self-hosted
echo " Enabling Pages and Performance tabs..."
SIDEBAR_FILE="/app/client/src/app/[site]/components/Sidebar/Sidebar.tsx"

if [ -f "$SIDEBAR_FILE" ]; then
    # Replace IS_CLOUD with true to enable Pages and Performance tabs
    sed -i 's/{IS_CLOUD && (/{true \&\& (/g' "$SIDEBAR_FILE"
    echo "✅ Pages and Performance tabs enabled"
else
    echo "⚠️  Sidebar file not found"
fi

# Enable Web Vitals toggle in Site Settings for self-hosted
echo "🔧 Enabling Web Vitals in Site Settings..."
SITE_CONFIG_FILE="/app/client/src/components/SiteSettings/SiteConfiguration.tsx"

if [ -f "$SITE_CONFIG_FILE" ]; then
    # Change the disabled logic to always be false for self-hosted
    sed -i 's/const webVitalsDisabled = subscription?.status !== "active" && IS_CLOUD;/const webVitalsDisabled = false;/' "$SITE_CONFIG_FILE"
    sed -i 's/const trackErrorsDisabled = subscription?.status !== "active" && IS_CLOUD;/const trackErrorsDisabled = false;/' "$SITE_CONFIG_FILE"
    
    # Replace the conditional spread with unconditional array
    sed -i 's/\.\.\.(IS_CLOUD/\.\.\.(true/' "$SITE_CONFIG_FILE"
    
    echo "✅ Web Vitals and Error Tracking enabled"
else
    echo "⚠️  Site Configuration file not found"
fi

echo "✅ Branding and feature patches applied!"

# Apply Goals Addon Feature
echo ""
if [ -f "/branding/client/goals-addon-feature.sh" ]; then
    sh /branding/client/goals-addon-feature.sh
fi

echo ""
echo "✅ All customizations applied!"
