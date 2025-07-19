#!/bin/bash
# Script to import OpenSearch Dashboards saved objects (dashboards, visualizations, searches)
# Usage: ./scripts/import_dashboards.sh

DASHBOARDS_FILE="dashboards/o-siem-dashboards.ndjson"
DASHBOARDS_URL="http://localhost:5601/api/saved_objects/_import"

if [ ! -f "$DASHBOARDS_FILE" ]; then
  echo "File $DASHBOARDS_FILE not found!"
  exit 1
fi

curl -X POST "$DASHBOARDS_URL" \
  -H "osd-xsrf: true" \
  --form file=@$DASHBOARDS_FILE

echo "Import complete. Check OpenSearch Dashboards for your visualizations and dashboards." 