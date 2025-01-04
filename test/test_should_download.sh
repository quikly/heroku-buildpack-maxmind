#!/usr/bin/env bash
set -o pipefail

# Source the functions
source "$(dirname "${0}")/../bin/support/bash_functions.sh"

(
    # Setup test environment
    MAXMIND_CACHE_DIR="$PWD/test/cache/maxmind"
    MAXMIND_LICENSE_KEY="your_license_key"
    MAXMIND_ACCOUNT_ID="your_account_id"

    # Test helper function
    test_scenario() {
        local scenario=$1
        echo "Testing scenario: $scenario"
        # Run the function directly to see output
        should_download "GeoLite2-Country"
        echo "Return code: $?"
        echo "---"
    }

    # Mock wget to return a fake response
    wget() {
        if [[ "$*" == *"HEAD"* ]]; then
            echo "Content-Disposition: attachment; filename=GeoLite2-Country_20240201.tar.gz" >&2
            return 0
        fi
        # For actual downloads (which we won't do in tests), return error
        return 1
    }
    export -f wget

    # Clean any existing test data
    rm -rf "$MAXMIND_CACHE_DIR"
    mkdir -p "$MAXMIND_CACHE_DIR"

    # Test 1: Empty cache
    test_scenario "Empty cache"

    # Test 2: Older version in cache
    mkdir -p "$MAXMIND_CACHE_DIR/GeoLite2-Country_20230101"
    touch "$MAXMIND_CACHE_DIR/GeoLite2-Country_20230101/GeoLite2-Country.mmdb"
    test_scenario "Older version in cache"

    # Test 3: Future version in cache
    rm -rf "$MAXMIND_CACHE_DIR"/*
    mkdir -p "$MAXMIND_CACHE_DIR/GeoLite2-Country_20991231"
    touch "$MAXMIND_CACHE_DIR/GeoLite2-Country_20991231/GeoLite2-Country.mmdb"
    test_scenario "Future version in cache"
)
