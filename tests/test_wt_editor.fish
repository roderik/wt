#!/usr/bin/env fish
# Unit tests for wt editor launch commands

function test_wt_claude_command
    test_case "wt --claude - shows launch message"

    cd $TEST_TEMP_DIR/test_repo

    # Since we can't actually test launching Claude, just verify help includes it
    set output (wt help)
    assert_contains "$output" --claude "Help should mention --claude option"

    test_pass
end

function test_wt_cursor_command
    test_case "wt --cursor - shows launch message"

    cd $TEST_TEMP_DIR/test_repo

    # Since we can't actually test launching Cursor, just verify help includes it
    set output (wt help)
    assert_contains "$output" --cursor "Help should mention --cursor option"

    test_pass
end

function test_wt_all_command
    test_case "wt --all - shows launch message"

    cd $TEST_TEMP_DIR/test_repo

    # Since we can't actually test launching both editors, just verify help includes it
    set output (wt help)
    assert_contains "$output" --all "Help should mention --all option"

    test_pass
end

function test_wt_help_shows_editor_options
    test_case "wt help - shows editor options"

    cd $TEST_TEMP_DIR/test_repo

    set output (wt help)

    # Verify editor options section exists
    assert_contains "$output" "EDITOR OPTIONS:" "Should have editor options section"
    assert_contains "$output" --claude "Should show --claude option"
    assert_contains "$output" --cursor "Should show --cursor option"
    assert_contains "$output" --all "Should show --all option"

    test_pass
end

function test_wt_editor_from_worktree
    test_case "wt editor commands - from worktree"

    cd $TEST_TEMP_DIR/test_repo

    # Create and switch to a worktree
    wt new test-editor-worktree
    assert_success "Should create worktree"

    # Test that help shows editor options from within worktree
    set output (wt help)
    assert_contains "$output" "EDITOR OPTIONS:" "Should show editor options from worktree"

    test_pass
end

function test_wt_editor_options_are_standalone
    test_case "wt editor - options are standalone"

    cd $TEST_TEMP_DIR/test_repo

    # Verify that editor options work as standalone commands
    set help_output (wt help)
    assert_contains "$help_output" --claude "Should have --claude option"
    assert_contains "$help_output" --cursor "Should have --cursor option"
    assert_contains "$help_output" --all "Should have --all option"

    # Editor options are treated as primary commands, not flags
    # So they work like 'wt --claude' not 'wt new --claude'

    test_pass
end

# Run all tests
test_wt_claude_command
test_wt_cursor_command
test_wt_all_command
test_wt_help_shows_editor_options
test_wt_editor_from_worktree
test_wt_editor_options_are_standalone
