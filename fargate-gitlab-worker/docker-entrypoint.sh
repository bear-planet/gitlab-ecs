#!/bin/sh

# --------------------------------------------------------
# Get AWS credentials of the IAM role attached to the ECS container task
# --------------------------------------------------------

# Query the unique security credentials generated for the task.
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
echo "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI=${AWS_CONTAINER_CREDENTIALS_RELATIVE_URI}"
AWS_CREDENTIALS=$(curl 169.254.170.2${AWS_CONTAINER_CREDENTIALS_RELATIVE_URI})

# Read the `AccessKeyId`, `SecretAccessKey`, and `Token` values.
AWS_ACCESS_KEY_ID=$(echo $AWS_CREDENTIALS | jq '.AccessKeyId' --raw-output)
AWS_SECRET_ACCESS_KEY=$(echo $AWS_CREDENTIALS | jq '.SecretAccessKey' --raw-output)
AWS_SESSION_TOKEN=$(echo $AWS_CREDENTIALS | jq '.Token' --raw-output)

# --------------------------------------------------------
# Set up SSH
# --------------------------------------------------------

# Create a folder to store user's SSH keys if it does not exist.
USER_SSH_KEYS_FOLDER=~/.ssh
[ ! -d ${USER_SSH_KEYS_FOLDER} ] && mkdir -p ${USER_SSH_KEYS_FOLDER}

# Copy contents from the `SSH_PUBLIC_KEY` environment variable
# to the `$USER_SSH_KEYS_FOLDER/authorized_keys` file.
# The environment variable must be set when the container starts.
echo ${SSH_PUBLIC_KEY} > ${USER_SSH_KEYS_FOLDER}/authorized_keys

# Clear the `SSH_PUBLIC_KEY` environment variable.
unset SSH_PUBLIC_KEY

# Start the SSH daemon
# exec /usr/sbin/sshd -D
exec /usr/sbin/sshd -D -o "SetEnv=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"


