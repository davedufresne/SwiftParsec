#!/bin/bash

set -ev

SWIFT_VERSION="5.0.3"
SWIFT_URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1404/swift-${SWIFT_VERSION}-RELEASE/swift-${SWIFT_VERSION}-RELEASE-ubuntu14.04.tar.gz"

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
  mkdir .swift
  curl -sSL "${SWIFT_URL}" | tar xz -C .swift &> /dev/null
  export PATH=$(pwd)/.swift/swift-${SWIFT_VERSION}-RELEASE-ubuntu14.04/usr/bin:$PATH
fi
