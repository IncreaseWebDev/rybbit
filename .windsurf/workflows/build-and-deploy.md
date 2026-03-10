---
description: Build and deploy IWD Analytics (full rebuild with no cache)
---

## Build and Deploy IWD Analytics

Run this workflow any time branding, backend, or client code changes need to be deployed.

**Always builds with `--no-cache` to ensure all changes are applied.**

1. Navigate to the project directory and build all custom Docker images
// turbo
```bash
cd /home/ubuntu/rybbit && bash branding/build-images.sh
```

2. Bring all services down and back up with the new images
// turbo
```bash
cd /home/ubuntu/rybbit && sudo docker compose down && sudo docker compose up -d
```

3. Verify all services are running and SMTP is connected
// turbo
```bash
cd /home/ubuntu/rybbit && sudo docker compose ps && sudo docker compose logs backend --tail 20 | grep -E "✅|❌|SMTP|started|error"
```

4. Push all committed changes to both GitHub remotes
```bash
cd /home/ubuntu/rybbit && git push origin main && git push private main
```
