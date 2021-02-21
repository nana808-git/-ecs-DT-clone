#!/bin/bash -ex

################################################################################
# Bootstrap

# The bootstrap log file:
LOG_FILE=/var/log/bootstrap.log

# Script error handling and output redirect
set -e                               # Fail on error
set -o pipefail                      # Fail on pipes
exec >> $LOG_FILE                    # stdout to log file
exec 2>&1                            # stderr to log file
set -x                               # Bash verbose

################################################################################
# Get metadata from api

export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}')

################################################################################
# Get metadata from tags

while true; do
  export ANSIBLE_ROLE=$(aws ec2 describe-tags --region ${REGION} \
    --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=AnsibleRole" | \
    grep Value|sed -r 's%.*Value": "(.*)"%\1%g')
  [[ -n $ANSIBLE_ROLE ]] && break
  sleep 1
done

while true; do
  export BUCKET_NAME=$(aws ec2 describe-tags --region ${REGION} \
    --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=BucketName" | \
    grep Value|sed -r 's%.*Value": "(.*)"%\1%g')
  [[ -n $BUCKET_NAME ]] && break
  sleep 1
done

while true; do
  export APPLICATION=$(aws ec2 describe-tags --region ${REGION} \
    --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Application" | \
    grep Value|sed -r 's%.*Value": "(.*)"%\1%g')
  [[ -n $APPLICATION ]] && break
  sleep 1
done

while true; do
  export ENVIRONMENT=$(aws ec2 describe-tags --region ${REGION} \
    --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=key,Values=Environment" | \
    grep Value|sed -r 's%.*Value": "(.*)"%\1%g')
  [[ -n $ENVIRONMENT ]] && break
  sleep 1
done

################################################################################
# Create configuration file

echo ANSIBLE_ROLE=${ANSIBLE_ROLE} > /etc/infra
echo BUCKET_NAME=${BUCKET_NAME} >> /etc/infra
echo INSTANCE_ID=${INSTANCE_ID} >> /etc/infra
echo APPLICATION=${APPLICATION} >> /etc/infra
echo ENVIRONMENT=${ENVIRONMENT} >> /etc/infra

################################################################################
# Build bucket URL

export BUCKET_URL="s3://${BUCKET_NAME}/${APPLICATION}/${ENVIRONMENT}"

################################################################################
# Download Ansible manifests and run it

# Deploy ansible
mkdir -p /opt/ansible
touch /opt/ansible/version

# Run it
/usr/local/bin/run_ansible_from_s3.sh
