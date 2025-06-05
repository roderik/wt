#!/usr/bin/env fish
# Unit tests for wt new command

function test_wt_new_basic
    test_case "wt new - basic branch creation"

    cd $TEST_TEMP_DIR/test_repo
    # Create a new worktree
    wt new feature-test
    assert_success "Should create worktree successfully"

    # Verify branch was created
    assert_branch_exists feature-test "Branch should exist"

    # Verify we're in the new worktree
    set current_dir (pwd)
    assert_contains $current_dir "/.worktrees/feature-test" "Should be in worktree directory"

    # Verify worktree directory exists (check from current location)
    assert_success test -d . "Worktree directory should exist"

    # Verify current branch
    set current_branch (git branch --show-current)
    assert_equal feature-test $current_branch "Should be on feature-test branch"

    test_pass
end

function test_wt_new_from_ref
    test_case "wt new - create from specific ref"

    # Create a commit on main branch
    cd $TEST_TEMP_DIR/test_repo
    echo "test content" >test.txt
    git add test.txt
    git commit -m "Test commit" --quiet
    set main_commit (git rev-parse HEAD)

    # Create another commit
    echo "more content" >test2.txt
    git add test2.txt
    git commit -m "Another commit" --quiet

    # Create worktree from the first commit
    wt new feature-from-ref --from $main_commit
    assert_success "Should create worktree from specific commit"

    # Verify we don't have the second file
    test -f test2.txt
    assert_failure "Should not have file from later commit"

    # Verify we have the first file
    test -f test.txt
    assert_success "Should have file from specified commit"

    test_pass
end

function test_wt_new_from_branch
    test_case "wt new - create from another branch"

    # Create a new branch with different content
    cd $TEST_TEMP_DIR/test_repo
    git checkout -b source-branch --quiet
    echo "source branch content" >source.txt
    git add source.txt
    git commit -m "Source branch commit" --quiet
    git checkout main --quiet

    # Create worktree from source-branch
    wt new feature-from-branch --from source-branch
    assert_success "Should create worktree from branch"

    # Verify we have the file from source branch
    assert_success test -f source.txt "Should have file from source branch"

    test_pass
end

function test_wt_new_no_args
    test_case "wt new - no arguments"

    cd $TEST_TEMP_DIR/test_repo
    wt new 2>/dev/null
    assert_failure "Should fail without branch name"

    test_pass
end

function test_wt_new_invalid_branch_name
    test_case "wt new - invalid branch name with slash"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature/test 2>/dev/null
    assert_failure "Should reject branch name with slash"

    test_pass
end

function test_wt_new_invalid_branch_name_space
    test_case "wt new - invalid branch name with space"

    cd $TEST_TEMP_DIR/test_repo
    wt new "feature test" 2>/dev/null
    assert_failure "Should reject branch name with space"

    test_pass
end

function test_wt_new_existing_branch
    test_case "wt new - existing branch"

    cd $TEST_TEMP_DIR/test_repo
    # Create a branch first
    git checkout -b existing-branch --quiet
    git checkout main --quiet

    # Try to create worktree with same name
    wt new existing-branch 2>/dev/null
    assert_failure "Should fail with existing branch"

    test_pass
end

function test_wt_new_invalid_ref
    test_case "wt new - invalid ref"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-bad-ref --from nonexistent-ref 2>/dev/null
    assert_failure "Should fail with invalid ref"

    test_pass
end

function test_wt_new_existing_worktree_path
    test_case "wt new - existing worktree path"

    cd $TEST_TEMP_DIR/test_repo
    # Create worktree directory manually
    mkdir -p .worktrees/manual-worktree

    # Try to create worktree with same path
    wt new manual-worktree 2>/dev/null
    assert_failure "Should fail when worktree path exists"

    test_pass
end

function test_wt_new_creates_worktrees_dir
    test_case "wt new - creates .worktrees directory"

    cd $TEST_TEMP_DIR/test_repo
    # Remove .worktrees if it exists
    rm -rf .worktrees

    # Create a worktree
    wt new first-worktree
    assert_success "Should create worktree"

    # Go back to main repo to check
    cd $TEST_TEMP_DIR/test_repo
    assert_dir_exists .worktrees "Should create .worktrees directory"

    test_pass
end

# Run all tests
test_wt_new_basic
test_wt_new_from_ref
test_wt_new_from_branch
test_wt_new_no_args
test_wt_new_invalid_branch_name
test_wt_new_invalid_branch_name_space
test_wt_new_existing_branch
test_wt_new_invalid_ref
test_wt_new_existing_worktree_path
test_wt_new_creates_worktrees_dir
