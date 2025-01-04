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

should_download() {
  local edition=$1
  local download_url="https://download.maxmind.com/geoip/databases/${edition}/download?suffix=tar.gz"

  # Check if any version of this edition exists in cache
  if ! ls "${MAXMIND_CACHE_DIR}/${edition}_"* >/dev/null 2>&1; then
    return 0
  fi

  step "Checking for updates to ${edition} database..."
  step "Using credentials: MAXMIND_ACCOUNT_ID=${MAXMIND_ACCOUNT_ID:-<not set>}"
  step "Checking URL: $download_url"

  # Get remote file info using curl HEAD request
  local headers
  headers=$(curl -sLI \
                 --user "$MAXMIND_ACCOUNT_ID:$MAXMIND_LICENSE_KEY" \
                 "$download_url" 2>&1)
  local curl_status=$?

  if [ $curl_status -ne 0 ]; then
    step "curl failed with status $curl_status"
    step "curl output: $headers"
    step "Failed to check for updates, using cached version"
    return 1
  fi

  # Extract date from Content-Disposition filename (YYYYMMDD format)
  local remote_date=$(echo "$headers" | grep -i 'content-disposition' | grep -o '[0-9]\{8\}')
  if [ -z "$remote_date" ]; then
    step "Could not determine remote version date, using cached version"
    return 1
  fi

  # Get local file's timestamp from the cached directory name
  local cached_dir
  cached_dir=$(find "${MAXMIND_CACHE_DIR}" -maxdepth 1 -type d -name "${edition}_*" | sort -r | head -n1)
  if [ -z "$cached_dir" ]; then
    step "No cached version found, downloading new version"
    return 0
  fi

  local local_date
  local_date=$(echo "$cached_dir" | grep -o '[0-9]\{8\}')
  if [ -z "$local_date" ]; then
    step "Could not determine local version date, downloading new version"
    return 0
  fi

  step "Found local version: ${local_date}, remote version: ${remote_date}"

  if [ "$remote_date" -gt "$local_date" ]; then
    step "New version available"
    return 0
  fi

  step "Local database is up to date (${local_date})"
  return 1
}
