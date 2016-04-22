# nginx-builder
[![Build Status](https://api.travis-ci.org/rebuy-de/nginx-builder.svg)](https://travis-ci.org/rebuy-de/nginx-builder)

Builds Nginx RPM with Lua support from mainline SRPM.

## build

1. `./build.sh <CENTOS_VERSION>`
2. grab RPM from `target/<CENTOS_VERSION>/rpmbuild/RPMS`

## bump version

1. change versions in `run.sh`
2. maybe update `nginx.spec.diff`
3. maybe change download urls in `run.sh`
4. debug and pray
