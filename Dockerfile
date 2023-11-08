FROM ghcr.io/actions/actions-runner:latest

ARG TARGETOS="linux"
ARG TARGETARCH="amd64"

USER root

RUN \
    apt-get update && \
    apt-get install --yes --quiet \
        python3 \
        python3-pip \
        git \
        curl \
        wget \
        zip \
        unzip \
        gettext-base \
        lsb-core \
        jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN export RUNNER_ARCH="${TARGETARCH}" && \
    if [ "${RUNNER_ARCH}" = "amd64" ]; then export AWS_ARCH="x86_64" ; fi && \
    if [ "${RUNNER_ARCH}" = "arm64" ]; then export AWS_ARCH="aarch64" ; fi && \
    curl \
        --fail \
        --silent \
        --location \
        --output "awscliv2.zip" \
        "https://awscli.amazonaws.com/awscli-exe-${TARGETOS}-${AWS_ARCH}.zip" && \
    unzip -qq awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws/install awscliv2.zip

RUN \
    export KUBECTL_VERSION=$(curl --location --silent https://dl.k8s.io/release/stable.txt) && \
    curl \
        --fail \
        --silent \
        --location \
        --output kubectl \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl" && \
    install ./kubectl /usr/local/bin/ && \
    rm ./kubectl

RUN \
    curl \
        --fail \
        --silent \
        "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    install ./kustomize /usr/local/bin/ && \
    rm ./kustomize

RUN \
    curl \
        --fail \
        --silent \
        "https://fluxcd.io/install.sh" | bash

RUN pip install cfn-lint yamllint

USER runner
