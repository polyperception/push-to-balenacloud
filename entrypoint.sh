#!/bin/bash -o pipefail

EXTRA_ARGS=" --debug --release-tag ${VERSION}"

if [[ "${DRAFT}" == "true" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} --draft"
fi

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} \
  && /balena/bin//balena login --token ${API_TOKEN} \
  && /balena/bin/balena deploy ${FLEET_NAME} ${DOCKER_IMAGE_NAME} ${EXTRA_ARGS} | grep -v \\[=*\> 

