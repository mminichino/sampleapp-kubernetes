#!/bin/sh
#

VERSION=$(wget -q https://hub.docker.com/v2/repositories/mminichino/sample-app/tags -O - | jq .results[1].name)

if [ ! -z "$VERSION" ]
then

cat << EOF > sampleapp-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sampleapp-config
  namespace: default
data:
  appversion: ${VERSION}
EOF

else

echo "Error"

fi
