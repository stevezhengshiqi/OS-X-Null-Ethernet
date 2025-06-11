#!/usr/bin/env bash

version=$(sw_vers -productVersion)
if [[ "$version" =~ ^([0-9]+)\.([0-9]+) ]]; then
  major=${BASH_REMATCH[1]}
  minor=${BASH_REMATCH[2]}
  if (( major > 10 )); then
    # Big Sur (11) or above
    echo "11+"
  elif (( minor <= 10 )); then
    # 10.0 – 10.10
    echo "10.10-"
  else
    # 10.11 – 10.15
    echo "10.11-10.15"
  fi
else
  echo "unknown"
fi