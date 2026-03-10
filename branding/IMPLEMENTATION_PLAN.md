# Path A: Pure Custom Docker Image Implementation Plan

## Overview
Build custom Docker images for both backend and client that include all customizations (SMTP email, branding, logos) baked directly into the images. This eliminates the need for post-deployment patching.

---

## Architecture

### Custom Images
1. **Custom Backend Image** (`iwd-analytics-backend`)
   - Extends official Rybbit backend
   - Adds nodemailer for SMTP
   - Includes custom SMTP email service
   - Pre-configured for Google Workspace

2. **Custom Client Image** (`iwd-analytics-client`)
   - Extends official Rybbit client
   - IWD Analytics logos baked in
   - Favicon included
   - Text replacements in source code (before build)

### File Structure
```
/var/www/rybbit/
├── branding/
│   ├── backend/
│   │   ├── Dockerfile.custom              # Custom backend Dockerfile
│   │   └── email-smtp.ts                  # SMTP email service
│   ├── client/
│   │   ├── Dockerfile.custom              # Custom client Dockerfile
│   │   └── branding-patch.sh              # Pre-build branding script
│   ├── logo.svg                           # IWD logo
│   ├── favicon.ico                        # IWD favicon
│   ├── apple-icon.png                     # Apple touch icon
│   ├── build-images.sh                    # Build custom images
│   └── IMPLEMENTATION_PLAN.md             # This file
├── docker-compose.override.yml            # Use custom images
└── .env                                   # SMTP credentials
```

---

## Implementation Steps

### Step 1: Create Custom SMTP Email Service
**File:** `/var/www/rybbit/branding/backend/email-smtp.ts`

Features:
- Uses nodemailer with Google Workspace SMTP
- Maintains same API as Resend version
- Supports all email types (invitations, password resets, reports)
- Reads SMTP config from environment variables

### Step 2: Create Custom Backend Dockerfile
**File:** `/var/www/rybbit/branding/backend/Dockerfile.custom`

Process:
1. Extend official Rybbit backend Dockerfile
2. Install nodemailer in build stage
3. Copy custom email-smtp.ts
4. Replace /app/server/src/lib/email/email.ts with SMTP version
5. Rebuild application with SMTP support

### Step 3: Create Custom Client Dockerfile
**File:** `/var/www/rybbit/branding/client/Dockerfile.custom`

Process:
1. Extend official Rybbit client Dockerfile
2. Copy logos/favicon into build
3. Run text replacement script BEFORE Next.js build
4. Replace "Rybbit" → "IWD Analytics" in source files
5. Build Next.js app with branding baked in

### Step 4: Create Build Script
**File:** `/var/www/rybbit/branding/build-images.sh`

Purpose:
- Builds both custom images
- Tags them appropriately
- Can be run manually or automatically after updates

### Step 5: Create Docker Compose Override
**File:** `/var/www/rybbit/docker-compose.override.yml`

Purpose:
- Override image names to use custom builds
- Add SMTP environment variables
- Keep everything else the same

### Step 6: Update Environment Variables
**File:** `/var/www/rybbit/.env`

Add:
```bash
# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=hello@increasewebdesign.com
SMTP_PASS=<app_password>
SMTP_FROM=IWD Analytics <hello@increasewebdesign.com>

# Custom branding
CLOUD=true  # Enable email functionality
```

### Step 7: Modify Update Script
**File:** `/var/www/rybbit/branding/update-custom.sh`

Process:
1. Run standard Rybbit update (git pull)
2. Rebuild custom images with new base
3. Restart containers with custom images
4. No post-deployment patching needed

---

## Update Workflow

### When Rybbit Releases New Version:

1. **Pull Latest Code:**
   ```bash
   cd /var/www/rybbit
   git pull
   ```

2. **Rebuild Custom Images:**
   ```bash
   ./branding/build-images.sh
   ```

3. **Restart Services:**
   ```bash
   docker compose down
   docker compose up -d
   ```

**Total Time:** ~5-10 minutes (includes image rebuild)

---

## Advantages of Path A

✅ **Permanent Customizations**
- All branding baked into images
- No post-deployment patching
- Survives container restarts

✅ **Clean Architecture**
- No runtime file modifications
- Proper Docker image layering
- Easy to version control

✅ **Reliable Updates**
- Same process every time
- No risk of forgetting to run branding script
- Automated rebuild process

✅ **Performance**
- No runtime overhead
- Optimized builds
- Faster container startup

---

## Disadvantages of Path A

⚠️ **Slower Updates**
- Need to rebuild images (~5-10 min)
- Can't use pre-built images from GitHub

⚠️ **More Complex Initial Setup**
- Multiple Dockerfiles to maintain
- Build process to understand

⚠️ **Storage**
- Custom images take disk space
- Need to manage image versions

---

## Google Workspace SMTP Setup

### Prerequisites:
1. **Enable 2-Factor Authentication** on hello@increasewebdesign.com
2. **Create App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Other (Custom name)"
   - Name it: "Rybbit Analytics"
   - Copy the 16-character password

### SMTP Settings:
- **Host:** smtp.gmail.com
- **Port:** 587 (STARTTLS) or 465 (SSL)
- **Username:** hello@increasewebdesign.com
- **Password:** [App Password from above]
- **From:** IWD Analytics <hello@increasewebdesign.com>

---

## Rollback Plan

If anything goes wrong:

1. **Restore docker-compose.yml:**
   ```bash
   cp /var/www/rybbit/backups/pre_custom_image_20251020_211018/docker-compose.yml.backup /var/www/rybbit/docker-compose.yml
   ```

2. **Remove override:**
   ```bash
   rm /var/www/rybbit/docker-compose.override.yml
   ```

3. **Restart with official images:**
   ```bash
   docker compose down
   docker compose pull
   docker compose up -d
   ```

4. **Restore database if needed:**
   ```bash
   cat /var/www/rybbit/backups/pre_custom_image_20251020_211018/postgres_backup.sql | sudo docker exec -i postgres psql -U frog analytics
   ```

---

## Next Steps

1. ✅ Backup complete
2. ⏳ Review this plan
3. ⏳ Create custom SMTP email service
4. ⏳ Create custom backend Dockerfile
5. ⏳ Create custom client Dockerfile
6. ⏳ Create build script
7. ⏳ Create docker-compose override
8. ⏳ Add SMTP credentials to .env
9. ⏳ Build and test custom images
10. ⏳ Deploy and verify

---

## Estimated Time
- **Initial Setup:** 30-45 minutes
- **Future Updates:** 5-10 minutes (automated rebuild)
