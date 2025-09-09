# Balena Deploy

Continuously deliver your applications to [BalenaCloud](https://www.balena.io/). A fork of [Balena Push](https://github.com/theaccordance/balena-push). with extra version parameter.

## Inputs

### `api-token`

**Required**: A BalenaCloud API Token, used to authenticate with BalenaCloud. API keys can be created in the [user settings for BalenaCloud](https://dashboard.balena-cloud.com/preferences/access-tokens).

### `fleet-name`

**Required**: The name of the BalenaCloud Fleet that you'll be pushing to

### `docker-image-name`

**Required**: The name of the local Docker image that you'll be pushing to BalenaCloud

### `application-path`

_Optional_: Provide a sub-path to the location for application being deployed to BalenaCloud. Defaults to the workspace root.

### `version`

_Optional_: Provide a version for the release being deployed to BalenaCloud. Defaults to 0.0.0.

### `draft`

_Optional_: Mark the release as draft. Defaults to false.

## Registry Secrets

This action supports pulling from private Docker registries by providing registry credentials. You can specify credentials in several ways:

### Direct YAML/JSON Format

### `registry-secrets-yaml`

_Optional_: Registry secrets in YAML format. Takes precedence over other registry inputs.

### `registry-secrets-json`

_Optional_: Registry secrets in JSON format. Takes precedence over YAML and other registry inputs.

### Simplified Registry Inputs

### `registry-urls`

_Optional_: Comma-separated list of registry URLs. Use empty string for Docker Hub, 'nvcr.io' for NVIDIA registry.

### `registry-usernames`

_Optional_: Comma-separated list of usernames corresponding to registry URLs.

### `registry-passwords`

_Optional_: Comma-separated list of passwords/tokens corresponding to registry URLs.

**Note**: All three inputs (`registry-urls`, `registry-usernames`, `registry-passwords`) must have the same number of comma-separated values.

## Workflow Example

### Basic Usage

```yaml
name: BalenaCloud Push

on:
  push:
    # Only run workflow for pushes to specific branches
    branches:
      - master

jobs:
  balena-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: polyperception/push-to-balenacloud@v2.0.0
        with:
          api-token: ${{secrets.BALENA_API_TOKEN}}
          fleet-name: ${{secrets.BALENA_APPLICATION_NAME}}
          docker-image-name: "edge:latest"
          application-path: "./edge"
          version: 1.0.0
```

### Usual usage for PolyPerception CI/CD

```yaml
jobs:
  balena-push:
    runs-on: ubuntu-latest

    env:
      ECR_URL: 123456789012.dkr.ecr.eu-central-1.amazonaws.com

    defaults:
      run:
        working-directory: edge

    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ env.to.AWS_ACCESS_KEY_ID}}
          aws-secret-access-key: ${{ env.to.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-central-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
        with:
          mask-password: "false"

      - uses: polyperception/push-to-balenacloud@v1.2.5
        with:
          api-token: ${{secrets.BALENA_API_TOKEN}}
          fleet-name: ${{secrets.BALENA_APPLICATION_NAME}}
          docker-image-name: ${{env.ECR_URL}}/edge:latest
          application-path: "./edge"
          registry-urls: ${{ env.ECR_URL }}
          registry-usernames: ${{ steps.login-ecr.outputs.docker_username_123456789012_dkr_ecr_eu_central_1_amazonaws_com }}
          registry-passwords: ${{ steps.login-ecr.outputs.docker_password_123456789012_dkr_ecr_eu_central_1_amazonaws_com }}
          version: v1.0.0
```

### With Multiple Registries

```yaml
name: BalenaCloud Push with Multiple Registries

on:
  push:
    branches:
      - master

jobs:
  balena-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: polyperception/push-to-balenacloud@v1.2.5
        with:
          api-token: ${{secrets.BALENA_API_TOKEN}}
          application-name: ${{secrets.BALENA_APPLICATION_NAME}}
          registry-urls: ",nvcr.io,my-registry.com:5000"
          registry-usernames: "${{secrets.DOCKERHUB_USERNAME}},${{secrets.NVCR_USERNAME}},${{secrets.CUSTOM_REGISTRY_USERNAME}}"
          registry-passwords: "${{secrets.DOCKERHUB_PASSWORD}},${{secrets.NVCR_PASSWORD}},${{secrets.CUSTOM_REGISTRY_PASSWORD}}"
```

### With Direct YAML Registry Secrets

```yaml
name: BalenaCloud Push with YAML Registry Secrets

on:
  push:
    branches:
      - master

jobs:
  balena-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: amingilani/push-to-balenacloud@v1.0.1
        with:
          api-token: ${{secrets.BALENA_API_TOKEN}}
          application-name: ${{secrets.BALENA_APPLICATION_NAME}}
          registry-secrets-yaml: |
            'nvcr.io':
              username: ${{secrets.NVCR_USERNAME}}
              password: ${{secrets.NVCR_PASSWORD}}
            '':  # Docker Hub
              username: ${{secrets.DOCKERHUB_USERNAME}}
              password: ${{secrets.DOCKERHUB_PASSWORD}}
```
