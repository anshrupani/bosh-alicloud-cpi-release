#!/usr/bin/env bash

set -e

: ${ALICLOUD_ACCESS_KEY_ID:?}
: ${ALICLOUD_SECRET_ACCESS_KEY:?}
: ${ALICLOUD_DEFAULT_REGION:?}

source bosh-cpi-src/ci/tasks/utils.sh

export GOPATH=${PWD}/bosh-cpi-src
export PATH=${GOPATH}/bin:$PATH

export ACCESS_KEY_ID=${ALICLOUD_ACCESS_KEY_ID}
export ACCESS_KEY_SECRET=${ALICLOUD_SECRET_ACCESS_KEY}

check_go_version $GOPATH
export GOPATH=${PWD}/bosh-cpi-src

cd ${PWD}/bosh-cpi-src


# logs
echo "current pwd..."
pwd
echo "files..."
ls -ll
echo "go path..."
echo $GOPATH


# fix Git clone Error: RPC failed; result=56, HTTP code = 200
# https://confluence.atlassian.com/stashkb/git-clone-fails-error-rpc-failed-result-56-http-code-200-693897332.html
export GIT_TRACE_PACKET=1
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1

git version

git config --global http.postBuffer 20M
git config lfs.batch false


# fix https fetch failed: Get https://golang.org/x/net/html/charset?go-get=1: dial tcp 216.239.37.1:443: i/o timeout
# git config --global http.proxy http://127.0.0.1:1080 
# git config --global https.proxy https://127.0.0.1:1080

pushd src
  #go get github.com/golang/net
  mkdir -p golang.org/x/net
  pushd golang.org/x/net
    git clone https://github.com/golang/net
  popd
  mkdir -p golang.org/x/text
  pushd golang.org/x/text
    git clone https://github.com/golang/text
  popd
  go install golang.org/x/text/gen.go
popd

go env


make test
