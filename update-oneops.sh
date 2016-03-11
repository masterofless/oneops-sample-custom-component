#!/bin/bash -xeu

# Use the OneOps CLI and some env vars to update the OneOps artifact version, etc.
# and trigger a deployment

OO_ASSEMBLY=${OO_ASSEMBLY:=JustAJar}
OO_ENVIRONMENT=${OO_ENVIRONMENT:=TEST1}
OO_PLATFORM=${OO_PLATFORM:=JarPlatform}
OO_COMPONENT=${OO_COMPONENT:=jartifact}
BUILD_TAG=${BUILD_TAG:="none"}

# Login to OneOps
oneops config set site=${OO_URL} -g
oneops auth login<<EOF
$OO_USER
$OO_PW
EOF
oneops config set organization=AFC -g
oneops config set format=json -g

# set checksum
oneops design component update -a ${OO_ASSEMBLY} -p ${OO_PLATFORM} -c ${OO_COMPONENT} checksum=${OO_CHECKSUM}

# then commit the design
oneops design commit -a ${OO_ASSEMBLY} --comment "Jenkins build ${BUILD_TAG}"

# pull design
oneops transition pull -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT}

# commit the release
oneops transition commit -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT} -c "Jenkins build ${BUILD_TAG}"

# execute deployment
oneops transition deployment create -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT}

