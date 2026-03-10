# CLAUDE.md — IWD Analytics (Rybbit Fork)

This file provides guidance to Claude/Windsurf when working with this repository.
**This is a private fork of Rybbit rebranded as IWD Analytics for Increase Web Design.**

## Project Identity
- **Product name:** IWD Analytics
- **Company:** Increase Web Design (`increasewebdesign.com`)
- **Live URL:** `https://analytics.increasewebdesign.com`
- **Server path:** `/home/ubuntu/rybbit/`
- **GitHub private:** `https://github.com/IncreaseWebDev/rybbit-iwd`
- **GitHub public fork:** `https://github.com/IncreaseWebDev/rybbit`

## Architecture
- **client** — Next.js 14 app, port 3002 (Tailwind, Shadcn UI, Tanstack Query, Zustand)
- **backend** — Fastify + Drizzle ORM + ClickHouse, port 3001
- **postgres** — Auth + site config DB, port 5885 on localhost
- **clickhouse** — Analytics events DB
- All services run via Docker Compose with a custom override file

## ⚠️ Branding System — CRITICAL
- All IWD branding is applied via **build-time patch scripts**, NOT by editing upstream source files directly
- Branding assets: `branding/logo.svg`, `branding/favicon-proper.ico`, `branding/apple-icon.png`
- Client patch: `branding/client/branding-patch.sh` — runs before Next.js build inside Docker
- Backend patch: `branding/backend/` — adds SMTP email support
- **Always update the patch script** for any branding changes — never edit upstream source files directly, as changes will be lost on rebuild
- Exception: `client/src/app/login/page.tsx` — IS_CLOUD gate removed for forgot password link (intentional source edit)

## ⚠️ Build & Deploy Process — CRITICAL
- **Always build with `--no-cache`** — use `bash branding/build-images.sh`
- Do NOT use `docker compose build` — always use `build-images.sh`
- After build: `sudo docker compose down && sudo docker compose up -d`
- Or use the workflow: `bash branding/build-images.sh && sudo docker compose down && sudo docker compose up -d`
- `docker-compose.override.yml` selects images `iwd-analytics-client:latest` and `iwd-analytics-backend:latest`

## Environment Variables
- Config: `/home/ubuntu/rybbit/.env`
- SMTP password must be quoted (contains spaces): `SMTP_PASS="xxxx xxxx xxxx xxxx"`
- SMTP chain: `.env SMTP_PASS` → `docker-compose.override.yml SMTP_PASS=${SMTP_PASS}` → `email-smtp.ts process.env.SMTP_PASS`
- Do NOT rename `SMTP_PASS` — the chain is correctly aligned

## Authentication
- Uses Better Auth with email + password (credential provider)
- Forgot password sends reset email via Gmail SMTP (`hello@increasewebdesign.com`)
- Gmail App Password stored in `.env` as `SMTP_PASS`

## Git Remotes
- `origin` → `https://github.com/IncreaseWebDev/rybbit.git` (public fork)
- `private` → `https://github.com/IncreaseWebDev/rybbit-iwd.git` (private copy)
- Always push to both: `git push origin main && git push private main`

## Key Custom Files
| File | Purpose |
|------|---------|
| `branding/client/branding-patch.sh` | Main branding patch, runs at Docker build time |
| `branding/backend/email-smtp.ts` | Custom SMTP email implementation |
| `branding/backend/Dockerfile.custom` | Custom backend Dockerfile |
| `branding/client/Dockerfile.custom` | Custom client Dockerfile |
| `docker-compose.override.yml` | Overrides images + adds SMTP env vars |
| `branding/build-images.sh` | Build script (always --no-cache) |

## Commands
- Build + deploy: `bash branding/build-images.sh && sudo docker compose down && sudo docker compose up -d`
- Logs: `sudo docker compose logs backend --tail 50`
- DB shell: `sudo docker compose exec -T postgres psql -U frog -d analytics`
- Client dev: `cd client && npm run dev` (port 3002)
- Server dev: `cd server && npm run dev`
- Lint: `cd client && npm run lint` or `cd server && npm run build`
- TypeCheck: `cd client && tsc --noEmit` or `cd server && tsc`

## Code Conventions
- TypeScript strict mode throughout
- React functional components, minimal useEffect, inline functions preferred
- Frontend: Next.js, Tailwind CSS, Shadcn UI, Tanstack Query, Zustand, Luxon, Nivo, react-hook-form
- Backend: Fastify, Drizzle ORM (Postgres), ClickHouse, Zod
- camelCase variables/functions, PascalCase components/types
- Imports: external first, then internal (alphabetical within groups)
- Dark mode is default theme
- Never run database migration scripts directly
