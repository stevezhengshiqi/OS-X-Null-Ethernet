#!/usr/bin/env bash
SCHEME="NullEthernet"
CONFIG="Release"

VERSION=$(
  xcodebuild \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -showBuildSettings 2>/dev/null \
  | awk -F= '/CURRENT_PROJECT_VERSION/ {
      # strip all spaces from the RHS
      gsub(/ /,"",$2)
      print $2
      exit
    }'
)

if [[ -n "$VERSION" ]]; then
  echo "$VERSION"
else
  echo "ERROR: could not read CURRENT_PROJECT_VERSION" >&2
  exit 1
fi