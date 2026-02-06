#!/bin/bash
# Notes
# - parts of this script was built using google gemini 3 pro (2026-01-30)

# --- CONFIGURATION ---
MASTER_LIST="all_cve_files.json"
TALLY_FILE="tally.json"
BATCH_SIZE=20
MAX_PER_DAY=350
TODAY=$(date +%Y-%m-%d)

# Fallback for local testing/GitHub Summary
SUM_OUT="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

if ! command -v jq &> /dev/null; then echo "Error: jq is required"; exit 1; fi
if [ ! -f "$MASTER_LIST" ]; then echo "Error: Master list not found"; exit 1; fi

# 1. Initialize or Load set of files related to the Tally
if [ ! -f "$TALLY_FILE" ]; then
    echo "{\"max_per_day\": "$MAX_PER_DAY", \"processed_today\": 0, \"last_updated_day\": \"$TODAY\"}" > "$TALLY_FILE"
fi

PROCESSED_TODAY=$(jq -r '.processed_today' "$TALLY_FILE")
LAST_DAY=$(jq -r '.last_updated_day' "$TALLY_FILE")

# 2. Handle Daily Reset
if [ "$TODAY" != "$LAST_DAY" ]; then
    echo "New day ($TODAY) detected. Resetting daily counter."
    PROCESSED_TODAY=0
fi

# 3. Check if Daily Limit is already reached
if [ "$PROCESSED_TODAY" -ge "$MAX_PER_DAY" ]; then
    echo "Daily limit of $MAX_PER_DAY reached. Exiting."
    # Ensure the date is updated even if we don't process anything
    jq ".last_updated_day = \"$TODAY\" | .processed_today = $PROCESSED_TODAY" "$TALLY_FILE" > "${TALLY_FILE}.tmp" && mv "${TALLY_FILE}.tmp" "$TALLY_FILE"
    exit 0
fi

# 4. Calculate allowance for this specific run
REMAINING_ALLOWANCE=$((MAX_PER_DAY - PROCESSED_TODAY))
if [ "$BATCH_SIZE" -gt "$REMAINING_ALLOWANCE" ]; then
    CURRENT_RUN_LIMIT=$REMAINING_ALLOWANCE
else
    CURRENT_RUN_LIMIT=$BATCH_SIZE
fi
TOTAL_FILES=$(jq '.listing | length' "$MASTER_LIST")

if [ "$TOTAL_FILES" -eq 0 ] || [ "$TOTAL_FILES" == "null" ]; then
    echo "Queue is empty. Nothing to process."
    exit 0
fi

# 2. Extract batch to a temporary text file
BATCH_FILE=$(mktemp)
PROCESS_FILE_LENGTH=$(cat $BATCH_FILE | wc -l)
jq -r ".listing[0:$CURRENT_RUN_LIMIT][]" "$MASTER_LIST" > "$BATCH_FILE"

echo "Processing batch of $BATCH_SIZE CVEs..."

# 3. Loop through the batch and transform files
while IFS= read -r file; do
    if [ -n "$file" ] && [ -f "$file" ]; then

        # Check if the key exists before attempting modification
        if jq -e '.cveMetadata.datePublished' "$file" > /dev/null 2>&1; then
            
            # Create a temp file for the output
            tmp=$(mktemp)

            # 2. Parse, increment second, set microsecond to 999
            # This jq filter:
            # a. Takes the date string
            # b. Converts to seconds (fromdateiso8601)
            # c. Adds 1 second
            # d. Converts back to ISO string (todateiso8601)
            # e. Replaces the 'Z' at the end with '.999Z' to force the microseconds
            # jq '.cveMetadata.datePublished |= (fromdateiso8601 | . + 1 | todateiso8601 | sub("Z$"; ".999Z"))' "$file" > "$tmp"
            jq --indent 4 '.cveMetadata.datePublished |= (
                (if endswith("Z") then . else . + "Z" end) | # Ensure Z suffix exists
                sub("\\.[0-9]+Z$"; "Z") |                   # Strip existing milliseconds
                fromdateiso8601 |                           # Convert to Unix epoch
                . + 1 |                                     # Increment
                strftime("%Y-%m-%dT%H:%M:%S") |        # Format back to string
                . + ".999Z"                                 # Add your specific suffix
                )' "$file" > "$tmp"        
            # Move temp file back to original
            mv "$tmp" "$file"
            # remove final newline
            perl -i -0777 -pe 's/\n\z//' "$file"
        else
            # 3. Error message if key missing, output to stderr
            echo "Error: Key 'cveMetadata.datePublished' not found in $file" >&2
        fi
    fi
done < "$BATCH_FILE"

# 4. Update the Master List by removing the processed items
jq ".listing |= .[$BATCH_SIZE:]" "$MASTER_LIST" > "${MASTER_LIST}.tmp" && mv "${MASTER_LIST}.tmp" "$MASTER_LIST"

# 5. Output status
REMAINING=$(jq '.listing | length' "$MASTER_LIST")
{
  echo "Processing complete."
  echo "Remaining files in queue: $REMAINING"
} >> "$SUM_OUT"

# Cleanup
# cat "$BATCH_FILE"
rm "$BATCH_FILE"

# Calculate new daily total
# Note: In the previous step, we'd need to know exactly how many were processed in the loop
# If you removed the count variable, we can calculate it by the difference in the batch extraction
NEW_PROCESSED_TOTAL=$((PROCESSED_TODAY + BATCH_SIZE)) 

# Prevent going over max in the JSON if the batch was smaller than BATCH_SIZE
# (Optional: refine this if your batch extraction counts actual lines)

jq ".processed_today = $NEW_PROCESSED_TOTAL | .last_updated_day = \"$TODAY\"" "$TALLY_FILE" > "${TALLY_FILE}.tmp" && mv "${TALLY_FILE}.tmp" "$TALLY_FILE"
