#!/bin/bash -o pipefail

cd ${GITHUB_WORKSPACE} && cd ${APPLICATION_PATH} && echo -e "name: ${APPLICATION_NAME}\ntype: sw.application\nversion: ${VERSION}" > balena.yml && /balena-cli/balena login --token ${API_TOKEN} && /balena-cli/balena push ${APPLICATION_NAME} | grep -v \\[=*\>
