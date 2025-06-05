#!/usr/bin/env fish
# Unit tests for wt help command

function test_wt_help_command
    test_case "wt help - shows help information"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt help 2>&1)
    assert_success "Should show help successfully"

    # Check for main sections
    assert_contains "$output" "Git Worktree Manager" "Should show title"
    assert_contains "$output" "USAGE:" "Should show usage section"
    assert_contains "$output" "SUBCOMMANDS:" "Should show subcommands section"
    assert_contains "$output" "EXAMPLES:" "Should show examples section"
    assert_contains "$output" "TIPS:" "Should show tips section"

    test_pass
end

function test_wt_help_short_alias
    test_case "wt h - short alias works"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt h 2>&1)
    assert_success "Should show help successfully"
    assert_contains "$output" "Git Worktree Manager" "Should show help content"

    test_pass
end

function test_wt_no_args_shows_help
    test_case "wt - no arguments shows help"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt 2>&1)
    assert_failure "Should return error code"
    assert_contains "$output" "Git Worktree Manager" "Should show help content"

    test_pass
end

function test_wt_unknown_subcommand
    test_case "wt unknown - shows error and suggests help"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt unknown-command 2>&1)
    assert_failure "Should fail with unknown command"
    assert_contains "$output" "Unknown subcommand" "Should show error message"
    assert_contains "$output" "wt help" "Should suggest help command"

    test_pass
end

function test_wt_help_shows_all_commands
    test_case "wt help - includes all subcommands"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt help 2>&1)

    # Check all commands are documented
    assert_contains "$output" new "Should document new command"
    assert_contains "$output" switch "Should document switch command"
    assert_contains "$output" list "Should document list command"
    assert_contains "$output" clean "Should document clean command"
    assert_contains "$output" remove "Should document remove command"
    assert_contains "$output" status "Should document status command"
    assert_contains "$output" help "Should document help command"

    test_pass
end

function test_wt_help_shows_aliases
    test_case "wt help - shows command aliases"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt help 2>&1)

    # Check aliases are shown
    assert_contains "$output" "switch, s" "Should show switch alias"
    assert_contains "$output" "list, ls" "Should show list alias"
    assert_contains "$output" "remove, rm" "Should show remove alias"
    assert_contains "$output" "status, st" "Should show status alias"
    assert_contains "$output" "help, h" "Should show help alias"

    test_pass
end

# Run all tests
test_wt_help_command
test_wt_help_short_alias
test_wt_no_args_shows_help
test_wt_unknown_subcommand
test_wt_help_shows_all_commands
test_wt_help_shows_aliases
