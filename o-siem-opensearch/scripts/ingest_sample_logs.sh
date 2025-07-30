#!/bin/bash
# Script to ingest all sample logs into Logstash via HTTP input

LOGSTASH_URL="http://localhost:8080"
LOG_DIR="$(dirname "$0")/../sample-logs"

for file in "$LOG_DIR"/*.log; do
  [ -e "$file" ] || continue
  while IFS= read -r line; do
    # Escape double quotes in the log line
    safe_line=$(echo "$line" | sed 's/\"/\\\"/g')
    curl -s -X POST "$LOGSTASH_URL" \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"$safe_line\"}"
  done < "$file"
done

echo "Ingestion complete." 