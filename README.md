# saas-sonod-update-image

Unified Docker image for CI pipelines that need:

- AWS CLI (amazon/aws-cli:2.15.30 base)
- Terraform 1.8.x
- Common tooling: `bash`, `jq`, `curl`, `unzip`, PostgreSQL client

This repository also includes a GitHub Actions workflow to build and publish the image to GitHub Container Registry (GHCR).

---

## Image Contents

Base image:

- `amazon/aws-cli:2.15.30`

Additional tools installed in `Dockerfile`:

- `bash`
- `jq`
- `curl`
- `unzip`
- PostgreSQL client (`postgresql` YUM package)
- Terraform `1.8.x` (default `1.8.0`)

Terraform is downloaded directly from HashiCorp releases and installed into `/usr/local/bin/terraform`.

---

## Dockerfile Overview

The main `Dockerfile`:

- Starts from `amazon/aws-cli:2.15.30`.
- Installs required system packages and tooling.
- Downloads and installs Terraform.
- Cleans up package caches to keep the image smaller.

Build argument:

- `TERRAFORM_VERSION` (default `1.8.0`)

Example local build:

```bash
# From repo root

docker build -t ghcr.io/<OWNER>/<REPO>:latest .

# Override Terraform version if needed
docker build \
  --build-arg TERRAFORM_VERSION=1.8.4 \
  -t ghcr.io/<OWNER>/<REPO>:1.8.4 .
```

Replace `<OWNER>` and `<REPO>` with your GitHub org/user and repository name.

---

## GitHub Actions Workflow

The workflow at `.github/workflows/ci.yml`:

- **Triggers** on pushes to the `master` branch.
- **Builds** the Docker image from `Dockerfile`.
- **Tags** it as:
  - `ghcr.io/${{ github.repository }}:latest`
- **Logs in** to GHCR and **pushes** the image only when:
  - `github.repository_owner == "sonodtech"`, and
  - `github.ref == 'refs/heads/master'`.
- Uses GHCR caching to speed up repeated builds.

Key pieces:

- `IMAGE_NAME` environment variable holds the final tag.
- `docker/setup-buildx-action` prepares Buildx.
- `docker/build-push-action` performs the build (and push when allowed).

---

## Using the Image in CI (GitLab Example)

Once the workflow has run on `master`, the image will be available at:

```text
ghcr.io/<OWNER>/<REPO>:latest
```

In GitLab CI jobs, you can reference it as:

```yaml
image:
  name: ghcr.io/sonodtech/saas-sonod-update-image:latest
  entrypoint: [""]
```

Example shared configuration for multiple jobs:

```yaml
.ci_base: &ci_base
  image:
    name: ghcr.io/sonodtech/saas-sonod-update-image:latest
    entrypoint: [""]
  tags:
    - docker
  only:
    - tags
```

Then reuse it:

```yaml
switch_to_main_service:
  stage: 🔁 blue_green_switch
  <<: *ci_base
  when: manual
  before_script:
    - chmod +x deployment/scripts/switch_to_main_service/switch_main_service.sh
    - set -a && source deployment/deployment.env && set +a
  script:
    - bash deployment/scripts/switch_to_main_service/switch_main_service.sh

cleanup_temp_service:
  stage: 🧹 blue_green_finalize
  <<: *ci_base
  when: manual
  before_script:
    - chmod +x deployment/scripts/cleanup_temp_service/cleanup_temp_service.sh
    - set -a && source deployment/deployment.env && set +a
  script:
    - bash deployment/scripts/cleanup_temp_service/cleanup_temp_service.sh

terraform_discover:
  stage: <your_terraform_stage>
  <<: *ci_base
  before_script:
    - terraform version
  script:
    - terraform init
    - terraform plan
```

All three jobs share the same image and have Terraform + AWS CLI + utilities preinstalled.

---

## Using the Image in Other CI Systems

Any CI system that supports Docker images can use:

```text
ghcr.io/<OWNER>/<REPO>:latest
```

Basic pattern (pseudo-code):

```yaml
image: ghcr.io/<OWNER>/<REPO>:latest

steps:
  - name: Run Terraform
    run: |
      terraform init
      terraform plan
```

---

## Notes

- Update `TERRAFORM_VERSION` in the Dockerfile (or via `--build-arg`) when you want to upgrade Terraform.
- If you need additional tools (e.g. `kubectl`, `helm`), add them to the `RUN` instruction in the Dockerfile and rebuild.
