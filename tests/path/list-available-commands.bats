#! /usr/bin/env bats

load ../environment

setup() {
  @go.create_test_go_script \
    '. "$_GO_CORE_DIR/lib/internal/path"' \
    '_@go.list_available_commands "$@"'
}

teardown() {
  @go.remove_test_go_rootdir
}

@test "$SUITE: list available commands" {
  # Since we aren't creating any new commands, and _@go.find_commands is already
  # thoroughly tested in isolation, we only check that builtins are available.
  local builtin_cmd
  local expected=()

  for builtin_cmd in "$_GO_ROOTDIR"/libexec/*; do
    if [[ -f "$builtin_cmd" && -x "$builtin_cmd" ]]; then
      expected+=("${builtin_cmd[@]##*/}")
    fi
  done

  run "$TEST_GO_SCRIPT" "$_GO_ROOTDIR/libexec"
  assert_success
  assert_line_equals 0 'Available commands are:'

  unset 'lines[0]'
  local IFS=$'\n'
  assert_equal "${expected[*]/#/  }" "${lines[*]}" 'available commands'
}

@test "$SUITE: error if no commands available" {
  run "$TEST_GO_SCRIPT" "$TEST_GO_SCRIPTS_DIR"
  assert_failure

  assert_line_equals 0 'ERROR: No commands available in:'
  assert_line_equals 1 "  $TEST_GO_SCRIPTS_DIR"
}
