FROM debian:buster
LABEL Description="Deploy an application using the Balena CLI."

RUN apt-get update && apt-get --yes install curl wget unzip

# download the standalone balena-cli
RUN BALENA_ARCH=$(if uname -m | grep -q "x86_64"; then echo "x64"; else echo "arm64"; fi) && \
	curl -s https://api.github.com/repos/balena-io/balena-cli/releases/latest \
	| grep "linux-${BALENA_ARCH}" \
	| cut -d : -f 12,3 \
	| tr -d \" \
	| xargs -I {} sh -c "wget -q https:{}"

RUN tar xf  *-standalone.tar.gz

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
CMD ["/bin/bash", "-o", "pipefail", "/entrypoint.sh"]
