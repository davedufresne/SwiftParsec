#!/bin/bash
set -ev

if [ "${SPM}" == "YES" ]; then
  swift build
  swift test
else
  xcodebuild test -project SwiftParsec.xcodeproj -scheme SwiftParsec -destination "${DESTINATION}" TOOLCHAINS=swift
fi
