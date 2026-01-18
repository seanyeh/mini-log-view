#!/bin/bash
set -e

LOG_DIR="$1"
OUTPUT_DIR="$2"

if [ -z "$LOG_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 <log-directory> <output-directory>"
  exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Log directory '$LOG_DIR' does not exist"
  exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

echo "Generating static log viewer..."
echo "Input: $LOG_DIR"
echo "Output: $OUTPUT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy CSS
echo "Copying assets..."
cp "$TEMPLATE_DIR/style.css" "$OUTPUT_DIR/"

# Collect all services
all_services=()
for file in "$LOG_DIR"/*.jsonl; do
  if [ -f "$file" ]; then
    service_name=$(basename "$file" .jsonl)
    all_services+=("$service_name")
  fi
done

# Generate index page
echo "Generating index page..."
SERVICE_LINKS=""
for service in "${all_services[@]}"; do
  SERVICE_LINKS="$SERVICE_LINKS    <a href=\"${service}.html\" class=\"service-tab\">$service</a>"$'\n'
done

SERVICE_LINKS="$SERVICE_LINKS" envsubst < "$TEMPLATE_DIR/index.html.template" > "$OUTPUT_DIR/index.html"

# Generate individual service pages
echo "Processing JSONL files..."
for file in "$LOG_DIR"/*.jsonl; do
  if [ -f "$file" ]; then
    service_name=$(basename "$file" .jsonl)
    echo "Processing $service_name..."
    
    # Generate service navigation tabs
    SERVICE_TABS=""
    for svc in "${all_services[@]}"; do
      if [ "$svc" = "$service_name" ]; then
        SERVICE_TABS="$SERVICE_TABS    <span class=\"service-tab active\">$svc</span>"$'\n'
      else
        SERVICE_TABS="$SERVICE_TABS    <a href=\"${svc}.html\" class=\"service-tab\">$svc</a>"$'\n'
      fi
    done
    
    # Generate log entries
    LOG_ENTRIES=""
    if [ -s "$file" ]; then
      while IFS= read -r line; do
        if [ -n "$line" ]; then
          # Use jq to safely parse JSON
          timestamp=$(echo "$line" | jq -r '.timestamp // "Unknown"')
          status=$(echo "$line" | jq -r '.status // "info"')
          message=$(echo "$line" | jq -r '.message // ""')
          
          # Format timestamp (remove timezone info for simplicity)
          formatted_time=$(echo "$timestamp" | sed 's/T/ /' | sed 's/[+-][0-9][0-9]:[0-9][0-9]$//')
          
          # Escape HTML in message
          escaped_message=$(echo "$message" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
          
          LOG_ENTRIES="$LOG_ENTRIES    <div class=\"log-entry\">
      <div class=\"log-time\">$formatted_time</div>
      <div>
        <span class=\"log-level ${status,,}\">${status^^}</span>
        <span class=\"log-message\">$escaped_message</span>
      </div>
    </div>"$'\n'
        fi
      done < <(tail -n 20 "$file")
    else
      LOG_ENTRIES="    <div class=\"log-entry\">
      <span class=\"log-message\">No logs available</span>
    </div>"
    fi
    
    # Generate HTML
    SERVICE_NAME="$service_name" SERVICE_TABS="$SERVICE_TABS" LOG_ENTRIES="$LOG_ENTRIES" \
      envsubst < "$TEMPLATE_DIR/service.html.template" > "$OUTPUT_DIR/${service_name}.html"
  fi
done

echo "Static log viewer generated successfully in $OUTPUT_DIR"
