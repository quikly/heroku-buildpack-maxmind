#!/usr/bin/env bash

# Output helpers
step() {
  echo "-----> $*"
}

step_succeeded() {
  echo "       ✓ $*"
}

warn() {
  echo " !     $*" >&2
}

error() {
  echo " !     $*" >&2
  echo " !     Build failed" >&2
}
