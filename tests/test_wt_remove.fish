#!/usr/bin/env fish
# Unit tests for wt remove command

function test_wt_remove_basic
    test_case "wt remove - basic removal with confirmation"

    cd $TEST_TEMP_DIR/test_repo
    # Create a worktree
    wt new feature-remove
    cd $TEST_TEMP_DIR/test_repo

    # Remove it with confirmation
    echo y | wt remove feature-remove
    assert_success "Should remove successfully"

    # Verify worktree is gone
    assert_dir_not_exists .worktrees/feature-remove "Worktree directory should be removed"

    # Branch should still exist unless we confirm deletion
    assert_branch_exists feature-remove "Branch should still exist"

    test_pass
end

function test_wt_remove_with_branch_deletion
    test_case "wt remove - removal with branch deletion"

    cd $TEST_TEMP_DIR/test_repo
    # Create a worktree
    wt new feature-remove-branch
    cd $TEST_TEMP_DIR/test_repo

    # Remove with both confirmations
    printf "y\ny\n" | wt remove feature-remove-branch
    assert_success "Should remove successfully"

    # Verify both worktree and branch are gone
    assert_dir_not_exists .worktrees/feature-remove-branch "Worktree should be removed"
    assert_branch_not_exists feature-remove-branch "Branch should be deleted"

    test_pass
end

function test_wt_remove_no_args
    test_case "wt remove - no arguments"

    cd $TEST_TEMP_DIR/test_repo
    wt remove 2>/dev/null
    assert_failure "Should fail without branch name"

    test_pass
end

function test_wt_remove_nonexistent
    test_case "wt remove - nonexistent worktree"

    cd $TEST_TEMP_DIR/test_repo
    wt remove nonexistent-worktree 2>/dev/null
    assert_failure "Should fail with nonexistent worktree"

    test_pass
end

function test_wt_remove_current_worktree
    test_case "wt remove - cannot remove current worktree"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-current-remove
    # We're now in the worktree

    wt remove feature-current-remove 2>/dev/null
    assert_failure "Should fail when removing current worktree"

    test_pass
end

function test_wt_remove_cancel
    test_case "wt remove - cancel removal"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-cancel
    cd $TEST_TEMP_DIR/test_repo

    # Cancel removal
    echo n | wt remove feature-cancel

    # Verify worktree still exists
    assert_dir_exists .worktrees/feature-cancel "Worktree should still exist"
    assert_branch_exists feature-cancel "Branch should still exist"

    test_pass
end

function test_wt_remove_cancel_branch_deletion
    test_case "wt remove - remove worktree but keep branch"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-keep-branch
    cd $TEST_TEMP_DIR/test_repo

    # Confirm worktree removal, cancel branch deletion
    printf "y\nn\n" | wt remove feature-keep-branch

    # Verify worktree is gone but branch remains
    assert_dir_not_exists .worktrees/feature-keep-branch "Worktree should be removed"
    assert_branch_exists feature-keep-branch "Branch should still exist"

    test_pass
end

function test_wt_remove_outside_repo
    test_case "wt remove - outside git repo"

    # Create a completely isolated temp directory
    set isolated_dir (mktemp -d)
    cd $isolated_dir
    wt remove some-branch 2>/dev/null
    assert_failure "Should fail outside git repo"

    # Clean up
    rm -rf $isolated_dir

    test_pass
end

# Run all tests
test_wt_remove_basic
test_wt_remove_with_branch_deletion
test_wt_remove_no_args
test_wt_remove_nonexistent
test_wt_remove_current_worktree
test_wt_remove_cancel
test_wt_remove_cancel_branch_deletion
test_wt_remove_outside_repo
