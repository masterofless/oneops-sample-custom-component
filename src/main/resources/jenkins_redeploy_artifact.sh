#!/bin/bash -eux

# calculate a checksum on the artifact jar
JAR=`ls target/sample-artifact*.jar | head -1`
export OO_CHECKSUM=`sha256sum $JAR | perl -pe 's/ .*//'`

# set vars for the OneOps CLI
export OO_SERVER=http://192.168.53.7:9090
export OO_ORG=JustAFC
export OO_ASSEMBLY=MySecondAssembly
export OO_ENV=TEST
export OO_PLATFORM=MyCustomPlatform
export OO_COMPONENT=MyCustomArtifact2

rvm-shell -exu <<EOF

# Login to OneOps
oneops config set site=${OO_SERVER} -g
oneops auth login<<EOA
afc
afcafc
EOA
oneops config set organization=${OO_ORG} -g
oneops config set format=json -g

# set checksum
oneops design component update -a ${OO_ASSEMBLY} -p ${OO_PLATFORM} -c ${OO_COMPONENT} checksum=${OO_CHECKSUM}

# then commit the design
oneops design commit -a ${OO_ASSEMBLY} --comment "Jenkins build ${BUILD_TAG}"

# pull design
oneops transition pull -a ${OO_ASSEMBLY} -e ${OO_ENV}

# commit the release
oneops transition commit -a ${OO_ASSEMBLY} -e ${OO_ENV} -c "Jenkins build ${BUILD_TAG}"

# execute deployment
oneops transition deployment create -a ${OO_ASSEMBLY} -e ${OO_ENV}

EOF

