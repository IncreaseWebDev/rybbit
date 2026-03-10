# IWD Analytics (Rybbit Fork) — Windsurf Rules

## Project Identity
- This is a **private fork of Rybbit** rebranded as **IWD Analytics** for Increase Web Design
- Live URL: `https://analytics.increasewebdesign.com`
- Server: `/home/ubuntu/rybbit/`
- GitHub (private): `https://github.com/IncreaseWebDev/rybbit-iwd`
- GitHub (public fork): `https://github.com/IncreaseWebDev/rybbit`

## Architecture
- **client** — Next.js 14 app (port 3002), Tailwind, Shadcn UI, Tanstack Query, Zustand
- **server/backend** — Fastify + Drizzle ORM (Postgres) + ClickHouse (port 3001)
- **postgres** — Auth + site config DB (port 5885 on localhost)
- **clickhouse** — Analytics events DB
- All services run via Docker Compose with custom override

## Branding System
- All IWD branding is applied via **build-time patch scripts**, NOT by editing source files directly
- Branding assets live in `/home/ubuntu/rybbit/branding/`
- Client patch script: `branding/client/branding-patch.sh` — runs before Next.js build inside Docker
- Backend patch: `branding/backend/` — adds SMTP email support
- **NEVER edit upstream source files for branding** — always update the patch script so changes survive rebuilds
- Logo files: `branding/logo.svg`, `branding/favicon-proper.ico`, `branding/apple-icon.png`

## Build & Deploy Process
- **Always build with `--no-cache`** via `bash branding/build-images.sh`
- Then deploy: `sudo docker compose down && sudo docker compose up -d`
- The override file `docker-compose.override.yml` uses custom images `iwd-analytics-client:latest` and `iwd-analytics-backend:latest`
- Do NOT use `docker compose build` — always use `build-images.sh`

## Environment Variables
- Config file: `/home/ubuntu/rybbit/.env`
- SMTP password uses quoted value with spaces: `SMTP_PASS="xxxx xxxx xxxx xxxx"` (Gmail App Password)
- SMTP env var chain: `.env SMTP_PASS` → `docker-compose.override.yml SMTP_PASS=${SMTP_PASS}` → `email-smtp.ts process.env.SMTP_PASS`
- Do NOT rename SMTP_PASS — the chain is now correctly aligned

## Authentication
- Uses **Better Auth** with **email + password** (credential provider)
- Passwordless OTP is NOT the current flow — password login is active
- Forgot password link is enabled via branding patch (removed `IS_CLOUD` gate)
- Reset password emails sent via Gmail SMTP from `hello@increasewebdesign.com`

## Key Source Files (custom)
- `branding/client/branding-patch.sh` — main branding patch, runs at Docker build time
- `branding/backend/email-smtp.ts` — custom SMTP email implementation
- `branding/backend/Dockerfile.custom` — custom backend Dockerfile
- `branding/client/Dockerfile.custom` — custom client Dockerfile
- `docker-compose.override.yml` — overrides images and adds SMTP env vars
- `client/src/app/login/page.tsx` — has IS_CLOUD gate removed for forgot password link

## Git Remotes
- `origin` → `https://github.com/IncreaseWebDev/rybbit.git` (public fork)
- `private` → `https://github.com/IncreaseWebDev/rybbit-iwd.git` (private copy)
- Always push to both: `git push origin main && git push private main`

## Code Conventions
- TypeScript strict mode throughout
- React functional components, minimal useEffect
- camelCase variables/functions, PascalCase components/types
- Dark mode is default theme
- Never run database migration scripts directly
- Backend: Fastify, Drizzle ORM, Zod validation
