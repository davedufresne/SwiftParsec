#!/bin/bash

set -ev

if [ ! -z "${XCODE_DESTINATION}" ]; then
  PARSEC="-project SwiftParsec.xcodeproj -scheme SwiftParsec"
  xcodebuild test $PARSEC -destination "${XCODE_DESTINATION}" TOOLCHAINS=swift
else
  swift test
fi
