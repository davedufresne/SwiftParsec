#!/bin/bash

set -ev

SWIFT_URL="https://swift.org/builds/swift-3.0-release/ubuntu1404/swift-3.0-RELEASE/swift-3.0-RELEASE-ubuntu14.04.tar.gz"

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
  mkdir .swift
  curl -sSL "${SWIFT_URL}" | tar xz -C .swift &> /dev/null
  export PATH=$(pwd)/.swift/swift-3.0-RELEASE-ubuntu14.04/usr/bin:$PATH
fi
