#!/bin/bash

TARGET_URL=${DEV_URL:-"http://localhost:8080"}

# 1. Get the JSON response
RESPONSE=$(curl -s "$TARGET_URL/api/dev-ops/test-selector?targetBranch=main")

# 2. Extract tags using a more flexible sed pattern
TAGS=$(echo $RESPONSE | sed -n 's/.*"impacted_tags":\[\([^]]*\)\].*/\1/p' | sed 's/"//g')

# 3. Execution Logic
if [ ! -z "$TAGS" ] && [ "$TAGS" != "null" ] && [ "$TAGS" != "" ]; then
    echo " Impacted Tags Found: $TAGS"
    # Run maven with the extracted tags
    mvn test -Dkarate.options="--tags $TAGS"
else
    echo "No impact found or parsing failed."
fi