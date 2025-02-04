#!/bin/bash -o pipefail

EXTRA_ARGS=""

if [[ "${DRAFT}" == "true" ]]; then
  EXTRA_ARGS="--draft"
fi

if [[ -n "${BALENA_DOCKERFILE}" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} --dockerfile ${BALENA_DOCKERFILE}"
fi

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && echo -e "name: ${APPLICATION_NAME}\ntype: sw.application\nversion: ${VERSION}" > balena.yml && /balena-cli/balena login --token ${API_TOKEN} && /balena-cli/balena push ${APPLICATION_NAME} ${EXTRA_ARGS} | grep -v \\[=*\>
