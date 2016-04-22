nginx-builder
=============

Builds Nginx RPM with Lua support from mainline SRPM.

## build

1. `./build.sh`
2. grab RPM from `target/rpmbuild/RPMS`

## bump version

1. change versions in `run.sh`
2. maybe update `nginx.spec.diff`
3. maybe change download urls in `run.sh`
4. debug and pray
