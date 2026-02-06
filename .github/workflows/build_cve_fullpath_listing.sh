#!/bin/bash
# Builds a full path listing of all files currently in SEARCH_DIR
# Note: this script was partly build using google gemini 3 pro (2026-01-30)

OUTFILENAME=all_cve_files.json

# get the starting timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Define the starting directory (default to current directory if not provided)
SEARCH_DIR="${1:-.}"

# 1. Find the CVE files
# 2. Resolve the absolute path
# 3. Sort them alphabetically by the full path
# 4. output to all_cve_files.json
find "$SEARCH_DIR" -type f -name "CVE-*-*.json" \
  | sort \
  | jq -R -s \
    --arg ts "$TIMESTAMP" \
    --slurpfile delta $SEARCH_DIR/deltaLog.json \
    '{
      listingGeneratedTimestamp: $ts,
      deltaLogFetchTime: $delta[0][0].fetchTime,
      listing: (split("\n") | map(select(length > 0)))
    }' > $OUTFILENAME