# IWD Analytics Fork & Update Workflow

**Last Updated:** March 9, 2026

## Overview

This document explains how to maintain your own fork of Rybbit with custom branding while staying up-to-date with upstream changes.

---

## Strategy: Fork + Upstream Tracking

### Recommended Approach

1. **Create your own fork** on GitHub (e.g., `increasewebdesign/rybbit-iwd`)
2. **Commit your branding customizations** to your fork
3. **Track upstream** Rybbit repository for updates
4. **Merge upstream changes** periodically into your fork
5. **Build custom images** from your fork

### Benefits

- ✅ Your customizations are version controlled
- ✅ Easy to pull upstream updates
- ✅ Can make additional custom changes
- ✅ Full history of what you've changed
- ✅ Can contribute improvements back to Rybbit

---

## Initial Setup

### Step 1: Create Your Fork

**Option A: Using GitHub OAuth MCP (Recommended)**

The GitHub OAuth MCP allows you to interact with GitHub without personal access tokens. You can:
- Create a fork directly from Windsurf
- Push commits
- Create pull requests
- Manage repositories

**Option B: Manual via GitHub Web UI**

1. Go to https://github.com/rybbit-io/rybbit
2. Click "Fork" button
3. Name it `rybbit-iwd` or similar
4. Create fork under your organization account

### Step 2: Initialize Git Repository

```bash
cd /home/ubuntu/rybbit

# Initialize git repository
git init

# Add your fork as origin
git remote add origin https://github.com/YOUR_ORG/rybbit-iwd.git

# Add upstream Rybbit
git remote add upstream https://github.com/rybbit-io/rybbit.git

# Verify remotes
git remote -v
```

### Step 3: Create Initial Commit with Customizations

```bash
# Stage all current files
git add .

# Create .gitignore if needed
cat > .gitignore << 'EOF'
.env
*.log
node_modules/
.next/
dist/
*.tar.gz
*.sql
EOF

# Commit your current state (with branding)
git commit -m "Initial commit: IWD Analytics branded Rybbit

- Custom branding system (build-time patching)
- IWD Analytics logos and favicon
- SMTP email configuration
- Custom Dockerfiles for client and backend
- docker-compose.override.yml for custom images
- Comprehensive documentation"

# Push to your fork
git push -u origin main
```

---

## Updating from Upstream

### Workflow

```bash
cd /home/ubuntu/rybbit

# 1. Fetch latest changes from upstream Rybbit
git fetch upstream

# 2. Check what's new
git log HEAD..upstream/main --oneline

# 3. Merge upstream changes into your fork
git merge upstream/main

# 4. Resolve any conflicts (if needed)
# Edit conflicting files, then:
git add .
git commit -m "Merge upstream Rybbit updates"

# 5. Push to your fork
git push origin main

# 6. Rebuild custom images with updates
bash ./branding/build-images.sh

# 7. Deploy
sudo docker compose down
sudo docker compose up -d

# 8. Test and verify
curl -s http://localhost:3002 | grep "IWD Analytics"
```

---

## Files to Track in Your Fork

### ✅ Include in Git

**Branding System:**
- `branding/` (entire folder)
  - `logo.svg`
  - `favicon.ico`
  - `build-images.sh`
  - `client/Dockerfile.custom`
  - `client/branding-patch.sh`
  - `backend/Dockerfile.custom`
  - `backend/email-smtp.ts`

**Configuration:**
- `docker-compose.override.yml`
- `.gitignore`

**Documentation:**
- `BRANDING_BUILD_SYSTEM.md`
- `FORK_WORKFLOW.md` (this file)
- `branding/README.md`

### ❌ Exclude from Git (in .gitignore)

- `.env` (contains secrets)
- `*.log`
- `node_modules/`
- `.next/`
- `dist/`
- `*.tar.gz`
- `*.sql`
- Database backups

---

## Handling Merge Conflicts

### Common Conflict Scenarios

#### 1. docker-compose.yml Changes

**Upstream changes:** New services, updated images, new environment variables  
**Your changes:** Port bindings, custom configurations

**Resolution:**
```bash
# Keep upstream changes, reapply your customizations
git checkout --theirs docker-compose.yml
# Then manually edit to add your custom port bindings
```

#### 2. Client/Server Source Code

**Upstream changes:** Bug fixes, new features  
**Your changes:** None (branding is in separate files)

**Resolution:**
```bash
# Always take upstream changes
git checkout --theirs client/
git checkout --theirs server/
```

Your branding patches will be reapplied during the build process.

#### 3. Package Dependencies

**Upstream changes:** Updated package.json  
**Your changes:** None

**Resolution:**
```bash
# Always take upstream changes
git checkout --theirs client/package.json
git checkout --theirs server/package.json
```

---

## Making Your Own Custom Changes

### Adding New Features

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-custom-feature
   ```

2. **Make your changes** (e.g., new analytics dashboard)

3. **Commit changes:**
   ```bash
   git add .
   git commit -m "Add custom analytics dashboard"
   ```

4. **Merge back to main:**
   ```bash
   git checkout main
   git merge feature/my-custom-feature
   ```

5. **Push to your fork:**
   ```bash
   git push origin main
   ```

### Modifying Branding

1. **Update branding files:**
   - Edit `branding/logo.svg`
   - Edit `branding/client/branding-patch.sh`
   - etc.

2. **Commit changes:**
   ```bash
   git add branding/
   git commit -m "Update branding: new logo and color scheme"
   ```

3. **Rebuild and deploy:**
   ```bash
   bash ./branding/build-images.sh
   sudo docker compose down
   sudo docker compose up -d
   ```

---

## Using GitHub OAuth MCP

### Setup

The GitHub OAuth MCP is already available in Windsurf. It provides:
- OAuth 2.1 PKCE authentication (no tokens needed)
- Full GitHub API access
- Repository management
- Commit and push operations

### Common Operations

**Create a fork:**
```
Ask Cascade: "Create a fork of rybbit-io/rybbit to my organization"
```

**Push commits:**
```
Ask Cascade: "Commit and push my branding changes to my fork"
```

**Check for updates:**
```
Ask Cascade: "Check if there are new commits in upstream rybbit-io/rybbit"
```

**Merge upstream:**
```
Ask Cascade: "Merge latest changes from rybbit-io/rybbit into my fork"
```

---

## Recommended Update Schedule

### Monthly Updates
- Check for upstream Rybbit updates
- Review changelog for breaking changes
- Merge and test in development environment
- Deploy to production

### Security Updates
- Apply immediately when announced
- Test critical functionality
- Deploy ASAP

### Feature Updates
- Review new features
- Decide if you want them
- Merge and test
- Deploy when ready

---

## Backup Strategy

Before any major update:

```bash
# 1. Backup database
sudo docker exec postgres pg_dump -U postgres rybbit > /tmp/rybbit-db-$(date +%Y%m%d).sql

# 2. Backup Docker images
sudo docker save iwd-analytics-client:latest > /tmp/client-$(date +%Y%m%d).tar
sudo docker save iwd-analytics-backend:latest > /tmp/backend-$(date +%Y%m%d).tar

# 3. Backup entire installation
cd /home/ubuntu
sudo tar -czf rybbit-backup-$(date +%Y%m%d).tar.gz rybbit/

# 4. Commit current state to git
cd /home/ubuntu/rybbit
git add .
git commit -m "Backup before update $(date +%Y%m%d)"
git push origin main
```

---

## Rollback Procedure

If an update breaks something:

### Option 1: Git Rollback
```bash
cd /home/ubuntu/rybbit
git log --oneline -10  # Find the commit before update
git reset --hard <commit-hash>
bash ./branding/build-images.sh
sudo docker compose down
sudo docker compose up -d
```

### Option 2: Restore from Backup
```bash
cd /home/ubuntu
sudo rm -rf rybbit
sudo tar -xzf rybbit-backup-YYYYMMDD.tar.gz
cd rybbit
sudo docker compose up -d
```

### Option 3: Restore Database Only
```bash
sudo docker exec -i postgres psql -U postgres -c "DROP DATABASE rybbit;"
sudo docker exec -i postgres psql -U postgres -c "CREATE DATABASE rybbit;"
sudo docker exec -i postgres psql -U postgres rybbit < /tmp/rybbit-db-YYYYMMDD.sql
```

---

## Current Status

**Installation:** `/home/ubuntu/rybbit/`  
**Git Status:** Not initialized (restored from backup)  
**Upstream:** https://github.com/rybbit-io/rybbit  
**Your Fork:** Not created yet

**Next Steps:**
1. Create fork on GitHub (use GitHub OAuth MCP or web UI)
2. Initialize git repository in `/home/ubuntu/rybbit/`
3. Add remotes (origin = your fork, upstream = rybbit-io/rybbit)
4. Commit current state with branding
5. Push to your fork

---

## Quick Reference

```bash
# Check for upstream updates
git fetch upstream
git log HEAD..upstream/main --oneline

# Merge upstream updates
git merge upstream/main

# Rebuild after updates
bash ./branding/build-images.sh

# Deploy
sudo docker compose down && sudo docker compose up -d

# Check status
sudo docker compose ps
curl -s http://localhost:3002 | grep "IWD Analytics"

# View your changes
git log --oneline -10
git diff upstream/main

# Push to your fork
git push origin main
```

---

## GitHub OAuth MCP vs Regular Git

### GitHub OAuth MCP (Recommended)
- ✅ No personal access tokens needed
- ✅ OAuth 2.1 PKCE authentication
- ✅ Integrated with Windsurf
- ✅ Can manage repos, commits, PRs
- ✅ Automatic token refresh

### Regular Git (Alternative)
- ⚠️ Requires personal access token
- ⚠️ Manual token management
- ⚠️ Token can expire
- ✅ Works from command line
- ✅ Standard git workflow

**Recommendation:** Use GitHub OAuth MCP for repository operations, regular git for local commits.

---

## Support

For questions:
1. Check this documentation
2. Review `BRANDING_BUILD_SYSTEM.md`
3. Check git status: `git status`
4. Check remotes: `git remote -v`
5. View commit history: `git log --oneline -20`

---

**Document Version:** 1.0  
**Last Updated:** March 9, 2026  
**Status:** Ready to implement
