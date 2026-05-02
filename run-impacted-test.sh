#!/bin/bash

TARGET_URL=${DEV_URL:-"http://localhost:8080"}

TOTAL_SUITE_COUNT=18

WORKFLOW_START=$(date +%s)

# -----------------------------
# CALL IMPACT API
# -----------------------------
echo "Calling Impact Analysis API..."

HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" \
"$TARGET_URL/api/dev-ops/test-selector?targetBranch=main~1")

BODY=$(echo "$HTTP_RESPONSE" | sed '$d')
STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)

echo "HTTP Status: $STATUS"
echo "RAW RESPONSE: $BODY"

if [ "$STATUS" != "200" ]; then
  echo "ERROR: Impact API failed"
  exit 1
fi

# -----------------------------
# EXTRACT TAGS
# -----------------------------
TAGS=$(echo "$BODY" | jq -r '.impacted_tags | join(",")')

echo "Extracted Tags: $TAGS"

if [ -z "$TAGS" ] || [ "$TAGS" = "null" ]; then
    echo "No impact found. Running @smoke fallback."
    FINAL_TAGS="@smoke"
else
    FINAL_TAGS="$TAGS"
fi

echo "FINAL TAGS: $FINAL_TAGS"

# -----------------------------
# RUN TESTS
# -----------------------------
TEST_START=$(date +%s)

mvn test -Dkarate.options="--tags $FINAL_TAGS" | tee test_output.log
TEST_EXIT_CODE=$?

TEST_END=$(date +%s)

# -----------------------------
# METRICS
# -----------------------------
WORKFLOW_END=$(date +%s)

TOTAL_DURATION=$((WORKFLOW_END - WORKFLOW_START))
ISOLATED_TEST_DURATION=$((TEST_END - TEST_START))

RUN_COUNT=$(grep -c "\[print\] Executing" test_output.log || echo 0)
SKIPPED_COUNT=$((TOTAL_SUITE_COUNT - RUN_COUNT))

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

echo "=============================="
echo "Reduction Rate: $REDUCTION%"
echo "Test Time: ${ISOLATED_TEST_DURATION}s"
echo "=============================="

exit $TEST_EXIT_CODE