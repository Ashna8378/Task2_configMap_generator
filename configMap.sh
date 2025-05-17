#!/bin/bash

# Take file names from terminal
BLUEPRINT_FILE="$1"
DUMMY_FILE="$2"

if [[ -z "$BLUEPRINT_FILE" || -z "$DUMMY_FILE" ]]; then
    echo "Usage: $0 <blueprint.xml> <dummy.cfg>"
    exit 1
fi

TMP_FILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
OUTPUT_FILE="ConfigMap.yaml"

declare -A dummy_values

# Load dummy.cfg into associative array (optimized)
while IFS='=' read -r key value; do
    # Remove surrounding whitespace
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    
    # Skip empty keys and comments
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    dummy_values["$key"]="$value"
done < "$DUMMY_FILE"

# Write YAML header
{
    echo "apiVersion: v1"
    echo "kind: ConfigMap"
    echo "metadata:"
    echo "  name: blueprint-config"
    echo "data:"
} > "$OUTPUT_FILE"

# Extract keys and write to tmp file (preserving original logic)
grep -E '<(from|to)' "$BLUEPRINT_FILE" | grep -Ev 'jdbc|cxf|cxfrs|activemq|repostingActivemq' |
while read -r line; do
    while [[ "$line" =~ (\{\{[^\}]+\}\}) ]]; do
        match="${BASH_REMATCH[1]}"
        echo "$match" >> "$TMP_FILE"

        # Extract nested key inside it (if any) - preserve original behavior
        if [[ "$match" =~ \{\{[^\{\}]*\{\{([^\{\}]+)\}\} ]]; then
            nested_key="${BASH_REMATCH[1]}"
            echo "{{${nested_key}}}" >> "$TMP_FILE"
        fi

        # Remove processed {{...}} to search next
        line="${line/${match}/}"
    done
done

# Process keys and append to YAML (preserving original substitution logic)
sort -u "$TMP_FILE" | while read -r key; do
    cleaned_key=$(echo "$key" | sed 's/[{}]//g')

    # Preserve the original currentSetUp substitution logic
    if [[ "$key" == *"{{"* && "$key" != "{{${cleaned_key}}}" ]]; then
        var_value="${dummy_values[currentSetUp]}"
        cleaned_key="${cleaned_key//currentSetUp/$var_value}"
    fi

    value="${dummy_values[$cleaned_key]}"

    # Maintain original output format (empty if not found)
    echo "  $cleaned_key: \"$value\"" >> "$OUTPUT_FILE"
done

# Display the output file
cat "$OUTPUT_FILE"

# Clean up tmp file
rm -f "$TMP_FILE"

echo -e "\nProcess Level Resource Usage:"
ps -p $$ -o pid,ppid,cmd,%cpu,%mem,rss,vsz


