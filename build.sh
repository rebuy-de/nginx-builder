#!/bin/bash

OSMAJ=${1:-6}

set -e -x

container=$(\
	docker run \
	-d \
	centos:${OSMAJ} \
	sleep infinity
)

DST=target/centos_${OSMAJ}
mkdir -p ${DST}

docker exec ${container} mkdir -p /nginx-lua
docker cp nginx.spec.diff ${container}:/nginx-lua/nginx.spec.diff
docker cp run.sh ${container}:/nginx-lua/run.sh
docker exec ${container} chmod +x /nginx-lua/run.sh

set +x # When something fails, we still want to get the files for debugging.

docker exec -i -t ${container} /nginx-lua/run.sh ${OSMAJ} | tee ${DST}/run.log

docker cp ${container}:/root/rpmbuild ${DST}
docker cp ${container}:/nginx-lua/nginx.spec.patched ${DST}/nginx.spec.patched

docker kill ${container}
docker rm ${container}
