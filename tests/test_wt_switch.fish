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
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    assert_contains $current_dir "/.wt/$repo_name/feature-switch" "Should be in worktree directory"

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
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    assert_contains $current_dir "/.wt/$repo_name/worktree-a" "Should be in worktree-a"

    test_pass
end

function test_wt_switch_lists_available
    test_case "wt switch - lists available worktrees on error"

    cd $TEST_TEMP_DIR/test_repo
    # Create some worktrees for testing error messages
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

function test_wt_switch_to_main
    test_case "wt switch - switch back to main/master branch"

    cd $TEST_TEMP_DIR/test_repo
    # Determine which default branch exists
    if git show-ref --verify --quiet refs/heads/main
        set default_branch main
    else if git show-ref --verify --quiet refs/heads/master
        set default_branch master
    else
        # Skip test if neither main nor master exists
        echo "Skipping: No main or master branch found"
        test_pass
        return
    end

    # Create a worktree
    wt new feature-branch

    # Verify we're in the worktree
    set current_dir (pwd)
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    assert_contains $current_dir "/.wt/$repo_name/feature-branch" "Should be in worktree"

    # Switch back to default branch
    wt switch $default_branch
    assert_success "Should switch to default branch successfully"

    # Verify we're in the main repository root
    set current_dir (pwd)
    assert_equal $TEST_TEMP_DIR/test_repo $current_dir "Should be in main repository"

    # Verify we're on default branch
    set current_branch (git branch --show-current)
    assert_equal $default_branch $current_branch "Should be on default branch"

    test_pass
end

# Run all tests
test_wt_switch_basic
test_wt_switch_no_args
test_wt_switch_nonexistent
test_wt_switch_shows_status
test_wt_switch_from_worktree
test_wt_switch_lists_available
test_wt_switch_to_main
