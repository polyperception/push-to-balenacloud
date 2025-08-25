#!/bin/bash -o pipefail

EXTRA_ARGS=" --debug"

if [[ "${DRAFT}" == "true" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} --draft"
fi

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} \
  && echo -e "name: ${FLEET_NAME}\ntype: sw.application\nversion: ${VERSION}" > balena.yml \
  && /balena/bin//balena login --token ${API_TOKEN} \
  && /balena/bin/balena deploy ${FLEET_NAME} ${DOCKER_IMAGE_NAME} ${EXTRA_ARGS} | grep -v \\[=*\> 

