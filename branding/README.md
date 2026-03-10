# IWD Analytics Branding System

**⚠️ IMPORTANT: This folder contains the build-time branding system for IWD Analytics.**

## 📖 Full Documentation

See `/home/ubuntu/rybbit/BRANDING_BUILD_SYSTEM.md` for complete documentation.

## Quick Start

### Build Custom Images

```bash
cd /home/ubuntu/rybbit
bash ./branding/build-images.sh
```

### Deploy

```bash
sudo docker compose down
sudo docker compose up -d
```

## Files in This Folder

### Branding Assets
- `logo.svg` - IWD Analytics logo (replaces all Rybbit logos)
- `favicon.ico` - IWD Analytics favicon
- ~~`apple-icon.png`~~ - Skipped (corrupted file)

### Build Scripts
- `build-images.sh` - Builds custom Docker images with --no-cache
- `client/Dockerfile.custom` - Custom client Dockerfile
- `client/branding-patch.sh` - Applies branding before Next.js build
- `backend/Dockerfile.custom` - Custom backend Dockerfile
- `backend/email-smtp.ts` - SMTP email service (replaces Resend)

### Legacy Files (Not Used)
- ~~`apply-branding.sh`~~ - Old runtime patching method (don't use)
- ~~`update-custom.sh`~~ - Old update script (don't use)

## How It Works

1. **Build Time:** Branding is applied to source files BEFORE Next.js compiles
2. **Custom Images:** Creates `iwd-analytics-client:latest` and `iwd-analytics-backend:latest`
3. **Override File:** `docker-compose.override.yml` tells Docker to use custom images
4. **Permanent:** Branding is baked into the compiled code, survives restarts

## What Gets Branded

- ✅ Logos (all variants)
- ✅ Favicon
- ✅ Footer (custom version without GitHub links)
- ✅ Text: "Rybbit" → "IWD Analytics" (in user-facing strings only)
- ✅ Domains: rybbit.io → increasewebdesign.com
- ✅ Emails: SMTP support with IWD Analytics branding

## Updating After Rybbit Changes

```bash
# 1. Pull latest Rybbit code
cd /home/ubuntu/rybbit
git pull
2. Edit `apply-branding.sh` to change text replacements
3. Run `./branding/apply-branding.sh` to apply

## Important

This folder is gitignored and won't be overwritten when you update Rybbit.
Your branding will persist across updates automatically.
