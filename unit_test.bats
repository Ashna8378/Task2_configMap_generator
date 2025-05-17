#!/usr/bin/env bats

@test "ConfigMap.yaml is created with valid input" {
  run bash configMap.sh blueprint.xml dummy.cfg
  [ "$status" -eq 0 ]
  [ -f ConfigMap.yaml ]
}

@test "Fails when script.sh is broken (e.g., syntax error or logic issue)" {
  run bash configMap.sh blueprint.xml dummy.cfg

  # Expect script to fail if it's broken (non-zero status OR missing file)
  if [ "$status" -ne 0 ] || [ ! -f ConfigMap.yaml ]; then
    echo "script.sh is broken or failed to generate ConfigMap.yaml"
    false
  else
    true
  fi
}







