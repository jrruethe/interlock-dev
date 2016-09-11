#!/bin/bash

# Set up volumes
INTERLOCK=`pwd`/interlock
USBARMORY=`pwd`/usbarmory
BUILDROOT=`pwd`/buildroot
LUKS=`pwd`/luks
OUTPUT=`pwd`/output

# Make sure volumes exist
mkdir -p ${INTERLOCK}
mkdir -p ${USBARMORY}
mkdir -p ${BUILDROOT}
mkdir -p ${LUKS}
mkdir -p ${OUTPUT}

# Remove an existing container
docker stop interlock-dev > /dev/null
docker rm interlock-dev > /dev/null

# Create a new container
# Note that until this is automated, 
# the /bin/bash command will start an interactive shell
docker run -it --name interlock-dev \
-p 4430:4430 \
-v ${INTERLOCK}:/mnt/interlock \
-v ${USBARMORY}:/mnt/usbarmory \
-v ${BUILDROOT}:/mnt/buildroot \
-v ${LUKS}:/mnt/luks \
--privileged \
interlock-dev "${1}"

