FROM ubuntu:22.04

RUN apt-get update

# ---------------------------------------------------------------------------- #
# Create directories for GitLab Runner and install GitLab Runner.              #
# ---------------------------------------------------------------------------- #
RUN mkdir -p /opt/gitlab-runner/metadata
RUN mkdir -p /opt/gitlab-runner/builds
RUN mkdir -p /opt/gitlab-runner/cache
RUN apt install -y curl
RUN curl -s "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
RUN apt install -y gitlab-runner

# ---------------------------------------------------------------------------- #
# Install the AWS CLI version 2.                                               #
# ---------------------------------------------------------------------------- #
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN apt install -y unzip
RUN unzip awscliv2.zip
RUN ./aws/install

# ---------------------------------------------------------------------------- #
# Download the GitLab Runner Fargate driver.                                   #
# ---------------------------------------------------------------------------- #
RUN curl -Lo /opt/gitlab-runner/fargate "https://gitlab-runner-custom-fargate-downloads.s3.amazonaws.com/latest/fargate-linux-amd64"
RUN chmod +x /opt/gitlab-runner/fargate

# ---------------------------------------------------------------------------- #
# Install https://github.com/krallin/tini - a very small 'init' process        #
# that helps processing signalls sent to the container properly.               #
# ---------------------------------------------------------------------------- #
ARG TINI_VERSION=v0.19.0
RUN curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64
RUN chmod +x /usr/local/bin/tini

# ----------------------------------------------------------------------------------- #
# Configure SSH for root user and copy the public key into the root's .ssh directory. #
# ----------------------------------------------------------------------------------- #
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY authorized_keys /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# ---------------------------------------------------------------------------- #
# Install OpenSSH server and Vim.                                              #
# ---------------------------------------------------------------------------- #
RUN apt-get update && apt-get install -y openssh-server vim

EXPOSE 22

# ---------------------------------------------------------------------------- #
# Execute a startup script.                                                    #
# ---------------------------------------------------------------------------- #
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
