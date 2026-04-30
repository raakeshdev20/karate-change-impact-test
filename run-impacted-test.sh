#!/bin/bash

TARGET_URL=${DEV_URL:-"http://localhost:8080"}

# --- START PHASE 1 METRICS ---
# Total Suite: 3 features x 5 scenarios + 3 smoke tests
TOTAL_SUITE_COUNT=18

# [A] Start Global Workflow Clock
WORKFLOW_START=$(date +%s)

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

# [B] Start Isolated Test Engine Clock
TEST_START=$(date +%s)

# 4. Run Maven and capture output to count executions
mvn test -Dkarate.options="--tags $FINAL_TAGS" | tee test_output.log
TEST_EXIT_CODE=$?

# [C] End Isolated Test Engine Clock
TEST_END=$(date +%s)

# --- GENERATE METRICS ARTIFACT ---
WORKFLOW_END=$(date +%s)

# Calculate Durations
TOTAL_DURATION=$((WORKFLOW_END - WORKFLOW_START))
ISOLATED_TEST_DURATION=$((TEST_END - TEST_START))

# Count Scenario executions
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
  "test_reduction_rate": "$REDUCTION%",
  "timing_metrics": {
    "total_workflow_seconds": $TOTAL_DURATION,
    "isolated_test_seconds": $ISOLATED_TEST_DURATION,
    "api_overhead_seconds": $((TOTAL_DURATION - ISOLATED_TEST_DURATION))
  }
}
EOF

echo "------------------------------------------"
echo "Reduction Rate: $REDUCTION%"
echo "Isolated Test Time: ${ISOLATED_TEST_DURATION}s"
echo "------------------------------------------"

exit $TEST_EXIT_CODE