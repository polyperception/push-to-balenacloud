#!/bin/bash -o pipefail

EXTRA_ARGS=""

if [[ "${DRAFT}" == "true" ]]; then
  EXTRA_ARGS="--draft"
fi

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && echo -e "name: ${APPLICATION_NAME}\ntype: sw.application\nversion: ${VERSION}" > balena.yml && /balena/bin//balena login --token ${API_TOKEN} && /balena/bin/balena push ${APPLICATION_NAME} ${EXTRA_ARGS} | grep -v \\[=*\>
