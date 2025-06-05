#!/usr/bin/env fish
# Unit tests for wt switch command

function test_wt_switch_basic
    test_case "wt switch - basic switching"

    cd $TEST_TEMP_DIR/test_repo
    # Create a worktree first
    wt new feature-switch

    # Go back to main
    cd $TEST_TEMP_DIR/test_repo

    # Switch to the worktree
    wt switch feature-switch
    assert_success "Should switch successfully"

    # Verify we're in the correct directory
    set current_dir (pwd)
    assert_contains $current_dir "/.worktrees/feature-switch" "Should be in worktree directory"

    # Verify branch
    set current_branch (git branch --show-current)
    assert_equal feature-switch $current_branch "Should be on correct branch"

    test_pass
end

function test_wt_switch_no_args
    test_case "wt switch - no arguments"

    cd $TEST_TEMP_DIR/test_repo
    wt switch 2>/dev/null
    assert_failure "Should fail without branch name"

    test_pass
end

function test_wt_switch_nonexistent
    test_case "wt switch - nonexistent worktree"

    cd $TEST_TEMP_DIR/test_repo
    wt switch nonexistent-worktree 2>/dev/null
    assert_failure "Should fail with nonexistent worktree"

    test_pass
end

function test_wt_switch_shows_status
    test_case "wt switch - shows modified files status"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktree with modifications
    wt new feature-modified
    echo "modified content" >modified.txt
    git add modified.txt

    # Switch away and back
    cd $TEST_TEMP_DIR/test_repo
    set output (wt switch feature-modified 2>&1)

    assert_success "Should switch successfully"
    assert_contains "$output" feature-modified "Should show branch name"

    test_pass
end

function test_wt_switch_from_worktree
    test_case "wt switch - switch from one worktree to another"

    cd $TEST_TEMP_DIR/test_repo
    # Create two worktrees
    wt new worktree-a
    cd $TEST_TEMP_DIR/test_repo
    wt new worktree-b

    # Switch from b to a
    wt switch worktree-a
    assert_success "Should switch between worktrees"

    set current_dir (pwd)
    assert_contains $current_dir "/.worktrees/worktree-a" "Should be in worktree-a"

    test_pass
end

function test_wt_switch_lists_available
    test_case "wt switch - lists available worktrees on error"

    cd $TEST_TEMP_DIR/test_repo
    # Create some worktrees
    wt new available-1
    cd $TEST_TEMP_DIR/test_repo
    wt new available-2
    cd $TEST_TEMP_DIR/test_repo

    # Try to switch to nonexistent
    set output (wt switch nonexistent 2>&1)
    assert_failure "Should fail"
    assert_contains "$output" "Available worktrees" "Should show available worktrees"

    test_pass
end

# Run all tests
test_wt_switch_basic
test_wt_switch_no_args
test_wt_switch_nonexistent
test_wt_switch_shows_status
test_wt_switch_from_worktree
test_wt_switch_lists_available
