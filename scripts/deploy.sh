#!/bin/sh
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# helm upgrade --reuse-values wethex $SCRIPTPATH/../deploy/wethex -n $KUBERNETES_NAMESPACE \
#   --set image.repository=$DRONE_REPO \
#   --set image.tag=stable

kubectl set image deployment/wethex -n wethex wethex=wethex/condenser:$DRONE_TAG