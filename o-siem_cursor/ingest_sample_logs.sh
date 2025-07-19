for file in sample-logs/*.log; do
  while IFS= read -r line; do
    # Escape double quotes in the log line
    safe_line=$(echo "$line" | sed 's/\"/\\\"/g')
    curl -s -X POST http://localhost:8080 \
      -H "Content-Type: application/json" \
      -d "{\"message\": \"$safe_line\"}"
  done < "$file"
done
