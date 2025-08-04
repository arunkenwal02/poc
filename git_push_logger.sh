#!/bin/bash

# Extract branch name from arguments
BRANCH=""
for arg in "$@"; do
  if [[ "$arg" != "origin" && "$arg" != "git" && "$arg" != "push" ]]; then
    BRANCH="$arg"
  fi
done

if [ -z "$BRANCH" ]; then
  echo "❌ Please provide branch name: e.g., git-push-with-log.sh origin main"
  exit 1
fi

# Get old HEAD of remote branch
OLD_COMMIT=$(git rev-parse origin/$BRANCH 2>/dev/null)

# Push normally
git push origin $BRANCH

# Get new HEAD after push
NEW_COMMIT=$(git rev-parse HEAD)

# Get commit details between old and new (if any)
if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
  COMMITS=$(git log $OLD_COMMIT..$NEW_COMMIT --pretty=format:'{"sha":"%H","author":"%an","message":"%s","timestamp":"%cd"},')
  COMMITS_JSON="[${COMMITS%,}]"
else
  COMMITS_JSON="[]"
fi

# Create push entry
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
PUSH_ID="push_$(date +%Y%m%d_%H%M%S)"

echo "{" >> push_log.json
echo "  \"push_id\": \"$PUSH_ID\"," >> push_log.json
echo "  \"branch\": \"$BRANCH\"," >> push_log.json
echo "  \"timestamp\": \"$TIMESTAMP\"," >> push_log.json
echo "  \"commits\": $COMMITS_JSON" >> push_log.json
echo "}," >> push_log.json

echo "✅ Push and log recorded successfully."
