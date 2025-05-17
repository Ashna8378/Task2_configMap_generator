#!/usr/bin/env bats

setup() {
    SCRIPT="./configMap.sh"
    BLUEPRINT="blueprint.xml"
    DUMMY="dummy.cfg"
    EXPECTED="ConfigMap.yaml"
    OUTPUT="ConfigMap.yaml"

    # Ensure script exists and is executable
    [ -f "$SCRIPT" ] || { echo "$SCRIPT not found"; exit 1; }
    [ -x "$SCRIPT" ] || chmod +x "$SCRIPT"

    # Backup output file if exists (input files untouched)
    if [ -f "$OUTPUT" ]; then
        cp "$OUTPUT" "$OUTPUT.bak"
    fi
}

teardown() {
    # Remove only output file (don't touch input files!)
    [ -f "$OUTPUT" ] && rm "$OUTPUT"

    # Restore backup of output file
    if [ -f "$OUTPUT.bak" ]; then
        mv "$OUTPUT.bak" "$OUTPUT"
    fi
}

@test "Script runs without errors and creates ConfigMap.yaml" {
    run "$SCRIPT" "$BLUEPRINT" "$DUMMY"
    [ "$status" -eq 0 ]
    [ -f "$OUTPUT" ]
}

@test "ConfigMap.yaml content matches expected.yaml" {
    run "$SCRIPT" "$BLUEPRINT" "$DUMMY"
    [ "$status" -eq 0 ]
    [ -f "$OUTPUT" ]

    run diff "$EXPECTED" "$OUTPUT"
    [ "$status" -eq 0 ]
}




