#!/bin/bash

TARGET_URL=${DEV_URL:-"http://localhost:8080"}

# --- START PHASE 1 METRICS ---
START_TIME=$(date +%s)
TOTAL_SUITE_COUNT=15 # Our 3 feature files x 5 examples each

# 1. Get the JSON response
# Using main~1 ensures we see the diff even on a direct push to main
RESPONSE=$(curl -s "$TARGET_URL/api/dev-ops/test-selector?targetBranch=main~1")

echo "------------------------------------------"
echo "DEBUG: Raw API Response from Fintech App: $RESPONSE"
echo "------------------------------------------"

# 2. Extract tags
TAGS=$(echo $RESPONSE | sed -n 's/.*"impacted_tags":\[\([^]]*\)\].*/\1/p' | sed 's/"//g')

# 3. Execution Logic
if [ ! -z "$TAGS" ] && [ "$TAGS" != "null" ] && [ "$TAGS" != "" ]; then
    echo "Impacted Tags Found: $TAGS"
    FINAL_TAGS="$TAGS"
else
    echo "No impact found. Running @smoke fallback."
    FINAL_TAGS="@smoke"
fi

# 4. Run Maven and capture output to count executions
mvn test -Dkarate.options="--tags $FINAL_TAGS" | tee test_output.log
TEST_EXIT_CODE=$?

# --- GENERATE METRICS ARTIFACT ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Count how many of our 'Scenario Outline' examples actually ran
# This looks for the 'Executing' string we added to the feature files
RUN_COUNT=$(grep -c "Executing" test_output.log || echo 0)
SKIPPED_COUNT=$((TOTAL_SUITE_COUNT - RUN_COUNT))

# Calculate reduction percentage
if [ $TOTAL_SUITE_COUNT -gt 0 ]; then
    REDUCTION=$(( (SKIPPED_COUNT * 100) / TOTAL_SUITE_COUNT ))
else
    REDUCTION=0
fi

cat <<EOF > metrics.json
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "impacted_tags": "$FINAL_TAGS",
  "scenarios_executed": $RUN_COUNT,
  "scenarios_skipped": $SKIPPED_COUNT,
  "execution_time_seconds": $DURATION,
  "test_reduction_rate": "$REDUCTION%"
}
EOF

echo "------------------------------------------"
echo "Reduction Rate: $REDUCTION%"
echo "------------------------------------------"

exit $TEST_EXIT_CODE