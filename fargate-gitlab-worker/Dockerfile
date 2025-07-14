FROM ubuntu:22.04

# ---------------------------------------------------------------------
# Install https://github.com/krallin/tini - a very small 'init' process
# that helps processing signalls sent to the container properly.
# ---------------------------------------------------------------------
ARG TINI_VERSION=v0.19.0

RUN apt-get update && \
    apt-get install -y curl && \
    curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini


# ----------------------------------------
# Install GitLab CI required dependencies.
# ----------------------------------------
    ARG GITLAB_RUNNER_VERSION=v12.9.0

    RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
        chmod +x /usr/local/bin/gitlab-runner && \
        # Test if the downloaded file was indeed a binary and not, for example,
        # an HTML page representing S3's internal server error message or something
        # like that.
        gitlab-runner --version
    
    RUN apt-get install -y bash ca-certificates git git-lfs && \
        git lfs install --skip-repo


# ---------------------------------------------------------------------------- #
# Install the AWS CLI version 2.                                               #
# ---------------------------------------------------------------------------- #
RUN apt-get update -qq -y \
    && apt-get install -qq -y curl unzip \
    && curl -Lo awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws 


# ---------------------------------------------------------------------------- #
# Install and configure 'jq', a tool to parse Amazon ECS temporary/unique      #
# security credentials, which come in the JSON format.                         #
# ---------------------------------------------------------------------------- #
RUN apt-get install -qq -y jq


# ----------------------------------------
# Install Terraform
# ----------------------------------------
RUN apt-get update && apt-get install -y gnupg software-properties-common wget
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
RUN gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update
RUN apt-get install terraform


# --------------------------------------------------------------------------
# Install and configure sshd.
# https://docs.docker.com/engine/examples/running_ssh_service for reference.
# --------------------------------------------------------------------------
RUN apt-get install -y openssh-server && \
    # Creating /run/sshd instead of /var/run/sshd, because in the Debian
    # image /var/run is a symlink to /run. Creating /var/run/sshd directory
    # as proposed in the Docker documentation linked above just doesn't
    # work.
    mkdir -p /run/sshd

EXPOSE 22


# -------------------------------------------------------------------------------------
# Execute a startup script.
# https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
# for reference.
# -------------------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

