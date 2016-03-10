#!/bin/bash -xeu

# pass credentials on the command line
OO_USER=$1
OO_PW=$2

OO_ASSEMBLY=JustAJar
OO_ENVIRONMENT=TEST1
OO_PLATFORM=JarPlatform
OO_COMPONENT=jartifact
OO_COMPONENT_VERSION=3
BUILD_TAG=${BUILD_TAG:="none"}

# Login to OneOps
oneops auth login<<EOF
$OO_USER
$OO_PW
EOF

# set OO_COMPONENT version to OO_COMPONENT_VERSION
oneops design component update -a ${OO_ASSEMBLY} -p ${OO_PLATFORM} -c ${OO_COMPONENT} version=${OO_COMPONENT_VERSION}

# then commit the design
oneops design commit -a ${OO_ASSEMBLY} --comment "design commit from Jenkins ${BUILD_TAG} via OO CLI"

# then a pull
oneops transition pull -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT}

# then commit the deployment
oneops transition commit -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT} -c "Committed transition via CLI"

# execute deployment
oneops transition deployment create -a ${OO_ASSEMBLY} -e ${OO_ENVIRONMENT}

