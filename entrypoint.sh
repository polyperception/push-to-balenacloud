#!/bin/bash -o pipefail

EXTRA_ARGS=""
REGISTRY_SECRETS_FILE=""

if [[ "${DRAFT}" == "true" ]]; then
  EXTRA_ARGS="--draft"
fi

# Handle registry secrets
if [[ -n "${REGISTRY_SECRETS_JSON}" ]]; then
  # Use provided JSON directly
  echo "Using provided registry secrets JSON"
  REGISTRY_SECRETS_FILE="/tmp/registry-secrets.json"
  echo "${REGISTRY_SECRETS_JSON}" > "${REGISTRY_SECRETS_FILE}"
elif [[ -n "${REGISTRY_SECRETS_YAML}" ]]; then
  # Use provided YAML directly
  echo "Using provided registry secrets YAML"
  REGISTRY_SECRETS_FILE="/tmp/registry-secrets.yml"
  echo "${REGISTRY_SECRETS_YAML}" > "${REGISTRY_SECRETS_FILE}"
elif [[ -n "${REGISTRY_URLS}" && -n "${REGISTRY_USERNAMES}" && -n "${REGISTRY_PASSWORDS}" ]]; then
  # Build registry secrets from comma-separated inputs
  echo "Creating registry secrets from comma-separated inputs"
  
  # Convert comma-separated strings to arrays
  IFS=',' read -ra URLS <<< "${REGISTRY_URLS}"
  IFS=',' read -ra USERNAMES <<< "${REGISTRY_USERNAMES}"
  IFS=',' read -ra PASSWORDS <<< "${REGISTRY_PASSWORDS}"
  
  # Check that arrays have the same length
  if [[ ${#URLS[@]} -ne ${#USERNAMES[@]} || ${#URLS[@]} -ne ${#PASSWORDS[@]} ]]; then
    echo "Error: registry-urls, registry-usernames, and registry-passwords must have the same number of comma-separated values"
    exit 1
  fi
  
  REGISTRY_SECRETS_CONTENT=""
  
  # Build YAML content from arrays
  for i in "${!URLS[@]}"; do
    url="${URLS[$i]}"
    username="${USERNAMES[$i]}"
    password="${PASSWORDS[$i]}"
    
    # Skip if any value is empty (except URL which can be empty for Docker Hub)
    if [[ -z "${username}" || -z "${password}" ]]; then
      echo "Warning: Skipping registry entry ${i} due to empty username or password"
      continue
    fi
    
    # Use empty string for Docker Hub, otherwise use the URL
    if [[ -z "${url}" ]]; then
      REGISTRY_SECRETS_CONTENT+="'':  # Docker Hub
  username: ${username}
  password: ${password}
"
    else
      REGISTRY_SECRETS_CONTENT+="'${url}':
  username: ${username}
  password: ${password}
"
    fi
  done
  
  # Create registry secrets file if we have any content
  if [[ -n "${REGISTRY_SECRETS_CONTENT}" ]]; then
    REGISTRY_SECRETS_FILE="/tmp/registry-secrets.yml"
    echo "${REGISTRY_SECRETS_CONTENT}" > "${REGISTRY_SECRETS_FILE}"
    echo "Registry secrets file created with ${#URLS[@]} registries"
  fi
fi

# Add registry secrets argument if we have a secrets file
if [[ -n "${REGISTRY_SECRETS_FILE}" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} --registry-secrets ${REGISTRY_SECRETS_FILE}"
  echo "Registry secrets file created at: ${REGISTRY_SECRETS_FILE}"
fi

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && echo -e "name: ${APPLICATION_NAME}\ntype: sw.application\nversion: ${VERSION}" > balena.yml && /balena/bin//balena login --token ${API_TOKEN} && /balena/bin/balena push ${APPLICATION_NAME} ${EXTRA_ARGS} | grep -v \\[=*\>
