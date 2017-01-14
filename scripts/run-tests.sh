#!/bin/bash

set -ev

if [ -z "${XCODE_DESTINATION}" ]; then
  swift build
  swift test
else
  xcodebuild test -project SwiftParsec.xcodeproj -scheme SwiftParsec -destination "${XCODE_DESTINATION}" TOOLCHAINS=swift
fi
