# Balena Deploy

Continuously deliver your applications to [BalenaCloud](https://www.balena.io/). A fork of [Balena Push](https://github.com/theaccordance/balena-push). with extra version parameter.

## Inputs

### `api-token`

**Required**: A BalenaCloud API Token, used to authenticate with BalenaCloud. API keys can be created in the [user settings for BalenaCloud](https://dashboard.balena-cloud.com/preferences/access-tokens).

### `application-name`

**Required**: The target application on BalenaCloud

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
      - uses: amingilani/push-to-balenacloud@v1.0.1
        with:
          api-token: ${{secrets.BALENA_API_TOKEN}}
          application-name: ${{secrets.BALENA_APPLICATION_NAME}}
          application-path: "./balena-wpe"
          version: 1.0.0
```

### With NVIDIA Container Registry (nvcr.io)

```yaml
name: BalenaCloud Push with NVCR

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
          registry-urls: "nvcr.io"
          registry-usernames: ${{secrets.NVCR_USERNAME}}
          registry-passwords: ${{secrets.NVCR_PASSWORD}}
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
