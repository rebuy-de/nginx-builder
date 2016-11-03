#!/bin/bash

if [ $# -ne 1 ]
then
	print "USAGE: $0 <CENTOS_VERSION>"
	exit 1
fi

OSMAJ=$1
NGINX_REPO=http://nginx.org/packages/centos/$OSMAJ

set -e -x

###
# update yum and install dependencies

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${OSMAJ}.noarch.rpm
yum -y update && yum clean all
yum -y install \
	make openssl-devel pcre-devel readline-devel gcc-c++ lua lua-devel \
	wget rpm-build perl-devel GeoIP-devel \
	perl-ExtUtils-Embed libxslt-devel gd-devel which

###
# define some variables
NGINX_VERSION=$(
	wget -q -O - ${NGINX_REPO}/SRPMS/ \
		| grep '^<a' \
		| grep -v release \
		| grep -v module \
		| grep 'nginx' \
		| sed -e 's/^.*<a[^>]\+>//' -e 's#.src.rpm</a>.*$##' \
		| sort -V \
		| tail -n 1
)
NGX_DEVEL_KIT_VERSION="0.3.0rc1"
NGX_LUA_VERSION="0.10.2"

NGINX_SOURCE=${NGINX_REPO}/SRPMS/${NGINX_VERSION}.src.rpm
NGX_DEVEL_KIT_SOURCE=https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz
NGX_LUA_SOURCE=https://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_VERSION}.tar.gz

NGX_DEVEL_KIT_NAME=ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}
NGX_LUA_NAME=lua-nginx-module-${NGX_LUA_VERSION}

NGINX_PKG=${NGINX_VERSION}.src.rpm
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
sed -i -- 's/^Summary: High performance web server$/Summary: High performance web server (reBuy)/g' nginx.spec.patched
sed -i -- 's#^\(%define BASE_CONFIGURE_ARGS \$(echo ".\+\)")$#\1 --add-module=/nginx-lua/ngx_devel_kit-0.3.0rc1 --add-module=/nginx-lua/lua-nginx-module-0.10.2")#g' nginx.spec.patched
cp nginx.spec.patched /root/rpmbuild/SPECS/nginx.spec

rpmbuild -ba --define "dist .el${OSMAJ}.rebuy" /root/rpmbuild/SPECS/nginx.spec

cp -a /root/rpmbuild .
