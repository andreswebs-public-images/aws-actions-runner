FROM ghcr.io/actions/actions-runner:latest

ARG TARGETOS="linux"
ARG TARGETARCH="amd64"

USER root

RUN \
    apt-get update && \
    apt-get install --yes --quiet \
        curl wget zip unzip jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export RUNNER_ARCH="${TARGETARCH}" && \
    if [ "${RUNNER_ARCH}" = "amd64" ]; then export AWS_ARCH="x86_64" ; fi && \
    if [ "${RUNNER_ARCH}" = "arm64" ]; then export AWS_ARCH="aarch64" ; fi && \
    curl -fLo "awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-${TARGETOS}-${AWS_ARCH}.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws/install awscliv2.zip

USER runner
