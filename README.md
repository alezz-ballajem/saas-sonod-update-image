# saas-sonod-update-image

Docker image for GitLab CI pipelines that need to SSH into remote servers, sync files, and run deployment scripts.

---

## Image Contents

**Base image:** `alpine:latest`

**Installed tools:**

- `ansible` — configuration management and orchestration
- `openssh-client` — SSH connections to remote servers
- `rsync` — file synchronization between servers
- `git` — repository operations
- `curl` — HTTP requests
- `jq` — JSON processing
- `bash` — script execution

**SSH configuration:**

- SSH directory pre-configured at `/root/.ssh/`
- `StrictHostKeyChecking` disabled for CI automation

---

## How It Works

This image is used as the base `image:` in `.gitlab-ci.yml` files across multiple projects. The typical flow:

1. GitLab CI job starts using this image
2. The job injects SSH private keys via CI/CD variables
3. Scripts connect to target servers via SSH
4. Files are synced with `rsync` and/or bash scripts are executed remotely

---

## Usage in GitLab CI

Reference the image in your `.gitlab-ci.yml`:

```yaml
image:
  name: ghcr.io/sonodtech/saas-sonod-update-image:latest
  entrypoint: [""]
```

Example job that SSHs into a server and runs a script:

```yaml
deploy:
  image:
    name: ghcr.io/sonodtech/saas-sonod-update-image:latest
    entrypoint: [""]
  before_script:
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | ssh-add -
  script:
    - rsync -avz ./files/ user@server:/path/
    - ssh user@server 'bash /path/to/deploy.sh'
```

---

## Building Locally

```bash
docker build -t ghcr.io/sonodtech/saas-sonod-update-image:latest .
```

---

## CI/CD

The GitHub Actions workflow at `.github/workflows/ci.yml` automatically builds and pushes the image to GHCR on every push to `main`.
