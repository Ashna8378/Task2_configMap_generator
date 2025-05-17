#!/bin/bash

# Accept blueprint folder, dummy folder, and output folder
BLUEPRINT_DIR="$1"
DUMMY_DIR="$2"
OUTPUT_DIR="$3"

# Validate inputs
if [[ -z "$BLUEPRINT_DIR" || -z "$DUMMY_DIR" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <blueprint_folder> <dummy_folder> <output_yaml_folder>"
    exit 1
fi

# Check if blueprint folder exists
if [[ ! -d "$BLUEPRINT_DIR" ]]; then
    echo "Error: $BLUEPRINT_DIR is not a valid directory"
    exit 1
fi

# Find dummy.cfg inside dummy folder
DUMMY_FILE=$(find "$DUMMY_DIR" -type f -name "*.cfg" | head -n 1)
if [[ -z "$DUMMY_FILE" ]]; then
    echo "Error: No .cfg file found in $DUMMY_DIR"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

declare -A dummy_values

# Load dummy.cfg into associative array
while IFS='=' read -r key value; do
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    dummy_values["$key"]="$value"
done < "$DUMMY_FILE"

# Process all blueprint files
for blueprint_file in "$BLUEPRINT_DIR"/*.xml; do
    [ -e "$blueprint_file" ] || continue

    TMP_FILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
    base_name=$(basename "$blueprint_file" .xml)
    OUTPUT_FILE="$OUTPUT_DIR/${base_name}_ConfigMap.yaml"

    {
        echo "apiVersion: v1"
        echo "kind: ConfigMap"
        echo "metadata:"
        echo "  name: blueprint-config-${base_name}"
        echo "data:"
    } > "$OUTPUT_FILE"

    # Extract placeholders from XML
    grep -E '<(from|to)' "$blueprint_file" | grep -Ev 'jdbc|cxf|cxfrs|activemq|repostingActivemq' |
    while read -r line; do
        while [[ "$line" =~ (\{\{[^\}]+\}\}) ]]; do
            match="${BASH_REMATCH[1]}"
            echo "$match" >> "$TMP_FILE"

            if [[ "$match" =~ \{\{[^\{\}]*\{\{([^\{\}]+)\}\} ]]; then
                nested_key="${BASH_REMATCH[1]}"
                echo "{{${nested_key}}}" >> "$TMP_FILE"
            fi
            line="${line/${match}/}"
        done
    done

    # Process placeholders and write to output YAML
    sort -u "$TMP_FILE" | while read -r key; do
        cleaned_key=$(echo "$key" | sed 's/[{}]//g')

        if [[ "$key" == *"{{"* && "$key" != "{{${cleaned_key}}}" ]]; then
            var_value="${dummy_values[currentSetUp]}"
            cleaned_key="${cleaned_key//currentSetUp/$var_value}"
        fi

        value="${dummy_values[$cleaned_key]}"
        echo "  $cleaned_key: \"$value\"" >> "$OUTPUT_FILE"
    done

    echo "Generated: $OUTPUT_FILE"
    rm -f "$TMP_FILE"
done

echo "All done!"
