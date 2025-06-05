#!/usr/bin/env fish
# Unit tests for wt clean command

function test_wt_clean_no_worktrees
    test_case "wt clean - no worktrees to clean"

    cd $TEST_TEMP_DIR/test_repo
    set output (wt clean 2>&1)
    assert_contains "$output" "No worktrees found to clean" "Should report no worktrees"

    test_pass
end

function test_wt_clean_with_worktrees
    test_case "wt clean - clean multiple worktrees"

    cd $TEST_TEMP_DIR/test_repo
    # Create multiple worktrees
    wt new feature-clean-1
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-clean-2
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-clean-3
    cd $TEST_TEMP_DIR/test_repo

    # Clean with confirmation
    echo y | wt clean

    # Verify all worktrees are removed
    assert_dir_not_exists .worktrees/feature-clean-1 "First worktree should be removed"
    assert_dir_not_exists .worktrees/feature-clean-2 "Second worktree should be removed"
    assert_dir_not_exists .worktrees/feature-clean-3 "Third worktree should be removed"

    test_pass
end

function test_wt_clean_cancel
    test_case "wt clean - cancel cleaning"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktrees
    wt new feature-cancel-clean-1
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-cancel-clean-2
    cd $TEST_TEMP_DIR/test_repo

    # Cancel cleaning
    echo n | wt clean

    # Verify worktrees still exist
    assert_dir_exists .worktrees/feature-cancel-clean-1 "First worktree should still exist"
    assert_dir_exists .worktrees/feature-cancel-clean-2 "Second worktree should still exist"

    test_pass
end

function test_wt_clean_returns_to_root
    test_case "wt clean - returns to repository root"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-return
    # We're now in the worktree

    cd $TEST_TEMP_DIR/test_repo
    set original_dir (pwd)

    # Clean worktrees
    echo y | wt clean

    # Verify we're back at root
    set current_dir (pwd)
    assert_equal $original_dir $current_dir "Should return to repository root"

    test_pass
end

function test_wt_clean_shows_summary
    test_case "wt clean - shows removal summary"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktrees
    wt new feature-summary-1
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-summary-2
    cd $TEST_TEMP_DIR/test_repo

    set output (echo "y" | wt clean 2>&1)

    assert_contains "$output" "Found 2 worktree(s) to remove" "Should show count"
    assert_contains "$output" "Summary:" "Should show summary"
    assert_contains "$output" "Successfully removed: 2" "Should show success count"

    test_pass
end

function test_wt_clean_outside_repo
    test_case "wt clean - outside git repo"

    # Create a completely isolated temp directory
    set isolated_dir (mktemp -d)
    cd $isolated_dir
    set output (wt clean 2>&1)
    assert_failure "Should fail outside git repo"
    assert_contains "$output" "Not in a git repository" "Should show error message"

    # Clean up
    rm -rf $isolated_dir

    test_pass
end

function test_wt_clean_all_flag
    test_case "wt clean --all - includes all worktrees"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktree in .worktrees
    wt new feature-dotworktrees
    cd $TEST_TEMP_DIR/test_repo

    # Create worktree outside .worktrees
    git worktree add ../external-worktree -b external-branch --quiet

    # Clean with --all flag
    echo y | wt clean --all

    # Both should be removed
    assert_dir_not_exists .worktrees/feature-dotworktrees "Dotworktrees worktree should be removed"
    assert_dir_not_exists ../external-worktree "External worktree should be removed"

    test_pass
end

function test_wt_clean_only_dotworktrees
    test_case "wt clean - only cleans .worktrees by default"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktree in .worktrees
    wt new feature-internal
    cd $TEST_TEMP_DIR/test_repo

    # Create worktree outside .worktrees
    git worktree add ../external-worktree-2 -b external-branch-2 --quiet

    # Clean without --all flag
    echo y | wt clean

    # Only .worktrees should be removed
    assert_dir_not_exists .worktrees/feature-internal "Internal worktree should be removed"
    assert_dir_exists ../external-worktree-2 "External worktree should still exist"

    # Cleanup external worktree
    git worktree remove ../external-worktree-2 --force

    test_pass
end

# Run all tests
test_wt_clean_no_worktrees
test_wt_clean_with_worktrees
test_wt_clean_cancel
test_wt_clean_returns_to_root
test_wt_clean_shows_summary
test_wt_clean_outside_repo
test_wt_clean_all_flag
test_wt_clean_only_dotworktrees
