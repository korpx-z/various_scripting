#!/bin/bash

# 
# This script will create a docker image capable of running ibmcloud cli, and log you in at startup. 
# Must provide an apikey
if [[ -z "$1" ]]; then
  echo "must supply ibmcloud apikey as arg"
  exit 1
fi

API_KEY=$1
CONTAINER_NAME="ibmcloud"

cat <<EOF > Dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install curl docker.io python3 vim jq -y
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
RUN ibmcloud plugin install container-registry
ENTRYPOINT ["sh","-c","ibmcloud login --apikey \$0 && exec bash"]
EOF

echo "Building ibmcloud image.."
docker build . --tag $CONTAINER_NAME

echo "now running container.."
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock $CONTAINER_NAME $API_KEY
