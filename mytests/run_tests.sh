#!/usr/bin/env bash

# Run from the tests/ directory
BIN="../Project5"
EXPECTED_DIR="expected"
CURRENT_DIR="current"

mkdir -p "$CURRENT_DIR"

# Ensure student compiler exists
if [[ ! -x "$BIN" ]]; then
  echo "Missing executable: $BIN"
  exit 1
fi

# Ensure wat2wasm is available
if ! command -v wat2wasm >/dev/null 2>&1; then
  echo "Error: 'wat2wasm' not found in PATH. Please install wabt."
  exit 1
fi

pass=0
fail=0

shopt -s nullglob
tests=( "$EXPECTED_DIR"/test-*.expected )
shopt -u nullglob

if (( ${#tests[@]} == 0 )); then
  echo "No expected files found in '$EXPECTED_DIR'."
  exit 1
fi

for exp in "${tests[@]}"; do
  base="${exp##*/}"              # e.g., test-00.expected
  id="${base%.expected}"         # e.g., test-00

  code_file="${id}.strix"
  wat_file="${CURRENT_DIR}/${id}.wat"
  wasm_file="${CURRENT_DIR}/${id}.wasm"
  status_file="${EXPECTED_DIR}/${id}.status"
  compile_log="${CURRENT_DIR}/${id}.compile.log"
  wat2wasm_log="${CURRENT_DIR}/${id}.wat2wasm.log"

  if [[ ! -f "$code_file" ]]; then
    echo "$id ... Failed (missing code file: $code_file)"
    ((fail++))
    continue
  fi

  expected_rc=0
  if [[ -f "$status_file" ]]; then
    # Trim whitespace/newlines from status
    expected_rc=$(tr -d '[:space:]' < "$status_file")
    [[ -z "$expected_rc" ]] && expected_rc=0
  else
    echo "NOTE: Missing expected status file: $status_file (defaulting to 0)"
  fi

  # Clean old artifacts (if any)
  : > "$compile_log"
  : > "$wat2wasm_log"
  rm -f "$wat_file" "$wasm_file"

  # === Compile: stdout -> WAT, stderr -> compile log ===
  "$BIN" "$code_file" >"$wat_file" 2>"$compile_log"
  rc=$?

  if [[ "$expected_rc" != "0" ]]; then
    # === ERROR-EXPECTED CASE ===
    # Must return non-zero; stop here.
    if [[ "$rc" -ne 0 ]]; then
      echo "$id ... Passed (compiler returned non-zero as expected)"
      ((pass++))
    else
      echo "$id ... Failed (expected non-zero exit; got 0)"
      echo "---- compile stderr (first 20 lines) ----"
      sed -n '1,20p' "$compile_log"
      echo "-----------------------------------------"
      ((fail++))
    fi
    continue
  fi

  # === NORMAL CASE (EXPECT SUCCESS) ===
  if [[ "$rc" -ne 0 ]]; then
    echo "$id ... Failed (compiler exit $rc; expected 0)"
    echo "---- compile stderr (first 20 lines) ----"
    sed -n '1,20p' "$compile_log"
    echo "-----------------------------------------"
    ((fail++))
    continue
  fi

  if [[ ! -s "$wat_file" ]]; then
    echo "$id ... Failed (no WAT produced or empty WAT)"
    echo "---- compile stderr (first 20 lines) ----"
    sed -n '1,20p' "$compile_log"
    echo "-----------------------------------------"
    ((fail++))
    continue
  fi

  # Validate WAT by assembling to WASM
  if ! wat2wasm "$wat_file" -o "$wasm_file" 2>"$wat2wasm_log"; then
    echo "$id ... Failed (wat2wasm failed: invalid WAT)"
    echo "---- wat2wasm stderr (first 20 lines) ----"
    sed -n '1,20p' "$wat2wasm_log"
    echo "------------------------------------------"
    ((fail++))
    continue
  fi

  echo "$id ... Passed!"
  ((pass++))
done

total=$((pass + fail))
echo "Passed $pass of $total tests (Failed $fail)"