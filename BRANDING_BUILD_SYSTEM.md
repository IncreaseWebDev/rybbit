# IWD Analytics Branding Build System

**Last Updated:** March 9, 2026  
**Status:** ✅ Working and Deployed

## Overview

This document explains how the IWD Analytics custom branding system works. The branding is **baked into Docker images at build time** using custom Dockerfiles and patch scripts. This ensures the branding persists across container restarts and Rybbit updates.

---

## How It Works

### 1. Build-Time Patching (Current Method)

The branding is applied **before the Next.js build** runs, which means:
- ✅ Changes are permanent and baked into the compiled code
- ✅ No runtime modifications needed
- ✅ Survives container restarts
- ✅ Works with `--no-cache` builds
- ✅ No broken JavaScript from text replacements

### 2. Key Components

```
/home/ubuntu/rybbit/
├── docker-compose.yml              # Base configuration
├── docker-compose.override.yml     # Uses custom images (iwd-analytics-*)
├── branding/
│   ├── build-images.sh            # Builds custom images with --no-cache
│   ├── logo.svg                   # IWD Analytics logo
│   ├── favicon.ico                # IWD Analytics favicon
│   ├── client/
│   │   ├── Dockerfile.custom      # Custom client build with branding
│   │   └── branding-patch.sh      # Applies branding before Next.js build
│   └── backend/
│       ├── Dockerfile.custom      # Custom backend build with SMTP
│       └── email-smtp.ts          # SMTP email service
```

---

## Build Process Flow

### Client Build (Simplified)

```
1. Start with official Rybbit source code
2. Copy branding files (logos, favicon) into container
3. Run branding-patch.sh:
   - Replace logos in /public/
   - Replace favicon
   - Replace Footer.tsx (remove GitHub links)
   - Apply text replacements ("Rybbit" → "IWD Analytics")
   - Replace domain references (rybbit.io → increasewebdesign.com)
   - Enable Pages/Performance tabs
   - Enable Web Vitals
4. Build Next.js application with branding baked in
5. Tag as iwd-analytics-client:latest
```

### Backend Build

```
1. Start with official Rybbit source code
2. Install nodemailer dependencies
3. Copy custom email-smtp.ts (replaces Resend with SMTP)
4. Build TypeScript application
5. Tag as iwd-analytics-backend:latest
```

---

## How to Build Custom Images

### Prerequisites
- Docker installed
- Rybbit source code in `/home/ubuntu/rybbit/`
- `.env` file configured with BASE_URL, SMTP credentials, etc.

### Build Command

```bash
cd /home/ubuntu/rybbit
bash ./branding/build-images.sh
```

This script:
1. Loads environment variables from `.env`
2. Builds backend with `--no-cache` flag
3. Builds client with `--no-cache` flag
4. Tags images as `iwd-analytics-backend:latest` and `iwd-analytics-client:latest`
5. Also tags with date (e.g., `iwd-analytics-client:20260309`)

**Build time:** ~5-10 minutes (depending on server)

---

## How to Deploy

### First Time Setup

1. Build the custom images:
   ```bash
   cd /home/ubuntu/rybbit
   bash ./branding/build-images.sh
   ```

2. Ensure `docker-compose.override.yml` exists (it should reference custom images)

3. Deploy:
   ```bash
   sudo docker compose down
   sudo docker compose up -d
   ```

### Updating After Rybbit Upstream Changes

1. Pull latest Rybbit code:
   ```bash
   cd /home/ubuntu/rybbit
   git pull
   ```

2. Rebuild custom images:
   ```bash
   bash ./branding/build-images.sh
   ```

3. Redeploy:
   ```bash
   sudo docker compose down
   sudo docker compose up -d
   ```

---

## Critical Files Explained

### `docker-compose.override.yml`

This file **overrides** the base `docker-compose.yml` to use custom images instead of official ones:

```yaml
services:
  backend:
    image: iwd-analytics-backend:latest
    build:
      context: .
      dockerfile: branding/backend/Dockerfile.custom
  
  client:
    image: iwd-analytics-client:latest
    build:
      context: .
      dockerfile: branding/client/Dockerfile.custom
      args:
        NEXT_PUBLIC_BACKEND_URL: ${BASE_URL}
        NEXT_PUBLIC_DISABLE_SIGNUP: ${DISABLE_SIGNUP}
        NEXT_PUBLIC_MAPBOX_TOKEN: ${MAPBOX_TOKEN}
```

### `branding/client/branding-patch.sh`

This is the **most important file**. It runs before the Next.js build and applies all branding:

**What it does:**
1. Copies `logo.svg` → `/app/client/public/rybbit.svg` (and variants)
2. Copies `favicon.ico` → `/app/client/src/app/favicon.ico`
3. Replaces `Footer.tsx` with custom version (no GitHub links)
4. Applies text replacements in source files:
   - `"Rybbit"` → `"IWD Analytics"`
   - `'Rybbit'` → `'IWD Analytics'`
   - `>Rybbit<` → `>IWD Analytics<`
   - Domain references: `rybbit.io` → `increasewebdesign.com`
5. Enables self-hosted features (Pages, Performance, Web Vitals)

**Critical:** The sed replacements are **very specific** to avoid breaking code:
- ✅ Only replaces in quoted strings
- ✅ Only replaces in specific contexts (titles, alt text, etc.)
- ❌ Does NOT replace in import statements
- ❌ Does NOT replace component names (e.g., `RybbitLogo`)
- ❌ Does NOT replace variable names

### `branding/build-images.sh`

Orchestrates the build process:

**Key features:**
- Uses `--no-cache` flag to ensure fresh builds
- Loads environment variables from `.env` (without sourcing, to avoid issues)
- Tags images with both `latest` and date tags
- Builds backend first, then client

---

## Environment Variables

Required in `/home/ubuntu/rybbit/.env`:

```bash
# Backend URL (NO quotes, NO trailing slash)
BASE_URL=https://analytics.increasewebdesign.com

# Disable public signups
DISABLE_SIGNUP=true

# Mapbox token (optional, empty string if not used)
MAPBOX_TOKEN=

# SMTP Configuration (for email)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=IWD Analytics <hello@increasewebdesign.com>
```

**Important:** `BASE_URL` must NOT have quotes or trailing slash, or the build will fail.

---

## Troubleshooting

### Build fails with "Invalid PNG signature"
**Cause:** Corrupted `apple-icon.png` file  
**Solution:** The branding script now skips this file (line 49 in `branding-patch.sh`)

### Build fails with "Expected ',', got 'AnalyticsLogo'"
**Cause:** sed replacements breaking import statements  
**Solution:** The branding script has been fixed to only replace in quoted strings (lines 82-99)

### Build fails with "Invalid base URL"
**Cause:** `BASE_URL` has quotes or trailing slash in `.env`  
**Solution:** Edit `.env` and ensure: `BASE_URL=https://analytics.increasewebdesign.com` (no quotes)

### Branding not showing after deploy
**Cause:** Browser cache or using official images instead of custom ones  
**Solution:** 
1. Verify custom images are being used: `sudo docker compose ps` (should show `iwd-analytics-client:latest`)
2. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)
3. Check nginx cache: `sudo systemctl reload nginx`

### Changes not appearing after rebuild
**Cause:** Docker layer caching  
**Solution:** The build script already uses `--no-cache`, but you can also manually remove old images:
```bash
sudo docker rmi iwd-analytics-client:latest
sudo docker rmi iwd-analytics-backend:latest
bash ./branding/build-images.sh
```

---

## What Gets Branded

### Visual Elements
- ✅ Logo (all variants: rybbit.svg, rybbit-text.svg, rybbit-bg.svg)
- ✅ Favicon
- ✅ Footer (custom version without GitHub links)

### Text Replacements
- ✅ "Rybbit" → "IWD Analytics" (in quoted strings only)
- ✅ "rybbit.io" → "increasewebdesign.com"
- ✅ "rybbit.com" → "increasewebdesign.com"
- ✅ Page titles, meta descriptions
- ✅ Welcome emails, invitation emails

### Features Enabled
- ✅ Pages tab (normally cloud-only)
- ✅ Performance tab (normally cloud-only)
- ✅ Web Vitals toggle (normally cloud-only)
- ✅ Error Tracking toggle (normally cloud-only)

---

## Maintenance

### When to Rebuild

You should rebuild custom images when:
1. **Rybbit releases an update** (after `git pull`)
2. **Branding files change** (new logo, favicon, etc.)
3. **Branding script changes** (`branding-patch.sh` modified)
4. **Environment variables change** (BASE_URL, SMTP settings, etc.)

### Backup Strategy

Before rebuilding:
```bash
# Backup current images
sudo docker save iwd-analytics-client:latest > /tmp/client-backup.tar
sudo docker save iwd-analytics-backend:latest > /tmp/backend-backup.tar

# Backup database
sudo docker exec postgres pg_dump -U postgres rybbit > /tmp/rybbit-db-backup.sql
```

---

## Architecture Comparison

### ❌ Runtime Patching (Old Method - Don't Use)
```
1. Start official Rybbit container
2. Run apply-branding.sh script
3. Modify files inside running container
4. Restart container
```
**Problems:**
- Changes lost on container restart
- sed breaks compiled JavaScript
- Fragile and error-prone
- Doesn't work with Next.js static generation

### ✅ Build-Time Patching (Current Method)
```
1. Start with official Rybbit source
2. Apply branding patches to source files
3. Build Next.js application
4. Create custom Docker image
5. Deploy custom image
```
**Benefits:**
- Changes are permanent
- No broken JavaScript
- Works with all Next.js features
- Survives container restarts
- Professional and maintainable

---

## File Locations Reference

```
Production Site:
  URL: https://analytics.increasewebdesign.com
  Nginx Config: /etc/nginx/sites-available/rybbit-analytics.conf
  
Rybbit Installation:
  Path: /home/ubuntu/rybbit/
  Compose: /home/ubuntu/rybbit/docker-compose.yml
  Override: /home/ubuntu/rybbit/docker-compose.override.yml
  Env File: /home/ubuntu/rybbit/.env
  
Branding Files:
  Build Script: /home/ubuntu/rybbit/branding/build-images.sh
  Client Dockerfile: /home/ubuntu/rybbit/branding/client/Dockerfile.custom
  Client Patch: /home/ubuntu/rybbit/branding/client/branding-patch.sh
  Backend Dockerfile: /home/ubuntu/rybbit/branding/backend/Dockerfile.custom
  Backend Email: /home/ubuntu/rybbit/branding/backend/email-smtp.ts
  Logo: /home/ubuntu/rybbit/branding/logo.svg
  Favicon: /home/ubuntu/rybbit/branding/favicon.ico
  
Docker Images:
  Client: iwd-analytics-client:latest
  Backend: iwd-analytics-backend:latest
  
Logs:
  Client: sudo docker logs client
  Backend: sudo docker logs backend
  Nginx: /var/log/nginx/rybbit_analytics_error.log
```

---

## Quick Reference Commands

```bash
# Build custom images
cd /home/ubuntu/rybbit && bash ./branding/build-images.sh

# Deploy
sudo docker compose down && sudo docker compose up -d

# Check status
sudo docker compose ps

# View logs
sudo docker logs client --tail 50
sudo docker logs backend --tail 50

# Verify branding
curl -s http://localhost:3002 | grep "IWD Analytics"

# List custom images
sudo docker images | grep iwd-analytics

# Remove old images
sudo docker rmi iwd-analytics-client:20260308
sudo docker rmi iwd-analytics-backend:20260308
```

---

## Success Criteria

After deployment, verify:

1. ✅ All containers healthy: `sudo docker compose ps`
2. ✅ Client using custom image: Should show `iwd-analytics-client:latest`
3. ✅ Backend using custom image: Should show `iwd-analytics-backend:latest`
4. ✅ Site loads: `curl -s http://localhost:3002` returns 200
5. ✅ Branding visible: Check https://analytics.increasewebdesign.com (clear cache)
6. ✅ No console errors: Check browser developer tools
7. ✅ Footer shows "IWD Analytics" (not "Rybbit")
8. ✅ Logo is IWD Analytics logo (not Rybbit logo)

---

## Support

For issues or questions:
1. Check this documentation first
2. Review logs: `sudo docker logs client` and `sudo docker logs backend`
3. Check build logs: `/tmp/build-final.log`
4. Verify environment variables: `grep "^BASE_URL=" /home/ubuntu/rybbit/.env`

---

**Document Version:** 1.0  
**Last Successful Build:** March 9, 2026  
**Build Time:** ~8 minutes  
**Image Sizes:** Client: 1.31GB, Backend: 475MB
