#!/bin/bash

set -e -x

container=$(\
	docker run \
	-d \
	centos:6 \
	sleep infinity
)

mkdir -p target

docker exec ${container} mkdir -p /nginx-lua
docker cp nginx.spec.diff ${container}:/nginx-lua/nginx.spec.diff
docker cp run.sh ${container}:/nginx-lua/run.sh
docker exec ${container} chmod +x /nginx-lua/run.sh

set +x # When something fails, we still want to get the files for debugging.

docker exec -i -t ${container} /nginx-lua/run.sh | tee target/run.log

docker cp ${container}:/root/rpmbuild target
docker cp ${container}:/nginx-lua/nginx.spec.patched target/nginx.spec.patched

docker kill ${container}
docker rm ${container}
