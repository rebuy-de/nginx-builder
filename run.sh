#!/bin/bash

set -e -x

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
yum -y update && yum clean all
yum -y install \
	make openssl-devel pcre-devel readline-devel gcc-c++ lua lua-devel \
	wget rpm-build perl-devel GeoIP-devel \
	perl-ExtUtils-Embed libxslt-devel gd-devel

NGINX_VERSION="1.9.15-1.el6"
NGX_DEVEL_KIT_VERSION="0.3.0rc1"
NGX_LUA_VERSION="0.10.2"

NGINX_SOURCE=http://nginx.org/packages/mainline/centos/6/SRPMS/nginx-${NGINX_VERSION}.ngx.src.rpm
NGX_DEVEL_KIT_SOURCE=https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz
NGX_LUA_SOURCE=https://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_VERSION}.tar.gz

NGX_DEVEL_KIT_NAME=ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}
NGX_LUA_NAME=lua-nginx-module-${NGX_LUA_VERSION}

NGINX_PKG=nginx-${NGINX_VERSION}.ngx.src.rpm
NGX_DEVEL_KIT_PKG=${NGX_DEVEL_KIT_NAME}.tar.gz
NGX_LUA_PKG=${NGX_DEVEL_KIT_PKG}.tar.gz

cd $( dirname $0 )

wget -q -c -O ${NGINX_PKG} ${NGINX_SOURCE}
wget -q -c -O ${NGX_DEVEL_KIT_PKG} ${NGX_DEVEL_KIT_SOURCE}
wget -q -c -O ${NGX_LUA_PKG} ${NGX_LUA_SOURCE}

tar xzf ${NGX_DEVEL_KIT_PKG}
tar xzf ${NGX_LUA_PKG}

rpm -ivh ${NGINX_PKG}

cp /root/rpmbuild/SPECS/nginx.spec nginx.spec.original
cp nginx.spec.original nginx.spec.patched
patch --forward nginx.spec.patched < nginx.spec.diff
cp nginx.spec.patched /root/rpmbuild/SPECS/nginx.spec

rpmbuild -ba /root/rpmbuild/SPECS/nginx.spec

cp -a /root/rpmbuild .
