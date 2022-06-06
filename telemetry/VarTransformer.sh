#!/usr/bin/env bash
#set -e

#res="$(cat)"
sedMap=()
#sed -e s#V_WHOAMI#radha#g
CURRENTPATH="$(dirname $(realpath $0))"
#file="/home/appsadm/radhapoc/telemetryreplace/cdoverlays/int-vnext/telemetry/build.properties"
file="$CURRENTPATH/build.properties"
while IFS='=' read -r key value; do
sedMap+=(-e "s#${key}#${value}#g")
#sed -e "s#${key}#${value}#g"
done < "$file"
sed "${sedMap[@]}"
#echo "
#kind: ResourceList
#items:
#- kind: ConfigMap
#  apiVersion: v1
#  metadata:
#    name: the-map
#  data:
#    test.txt: |- 
#      "$sedMap"
#"
