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
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    assert_contains $current_dir "/.wt/$repo_name/feature-test" "Should be in worktree directory"

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
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    mkdir -p ~/.wt/$repo_name/manual-worktree

    # Try to create worktree with same path
    wt new manual-worktree 2>/dev/null
    assert_failure "Should fail when worktree path exists"

    test_pass
end

function test_wt_new_creates_worktrees_dir
    test_case "wt new - creates ~/.wt/<repo> directory"

    cd $TEST_TEMP_DIR/test_repo
    # Remove ~/.wt/<repo> if it exists
    set repo_name (basename $TEST_TEMP_DIR/test_repo)
    rm -rf ~/.wt/$repo_name

    # Create a worktree
    wt new first-worktree
    assert_success "Should create worktree"

    # Check that the directory was created
    assert_dir_exists ~/.wt/$repo_name "Should create ~/.wt/<repo> directory"

    test_pass
end

function test_wt_new_default_from_main
    test_case "wt new - defaults to creating from default branch"

    cd $TEST_TEMP_DIR/test_repo
    # Get the default branch name
    set default_branch (git branch --show-current)

    # Create a commit on default branch
    echo "main content" >main.txt
    git add main.txt
    git commit -m "Main commit" --quiet
    set main_commit (git rev-parse HEAD)

    # Create and checkout a different branch
    git checkout -b other-branch --quiet
    echo "other content" >other.txt
    git add other.txt
    git commit -m "Other commit" --quiet

    # Create worktree while on other-branch (should still use default branch)
    wt new feature-default
    assert_success "Should create worktree from default branch"

    # Verify we have the file from default branch
    assert_success test -f main.txt "Should have file from default branch"

    # Verify we don't have the file from other-branch
    test -f other.txt
    assert_failure "Should not have file from other branch"

    # Verify the worktree is based on default branch's commit
    set worktree_commit (git rev-parse HEAD)
    assert_equal $main_commit $worktree_commit "Should be based on default branch commit"

    test_pass
end

function test_wt_new_fetches_from_origin
    test_case "wt new - fetches latest changes from origin"

    cd $TEST_TEMP_DIR/test_repo

    # Set up a remote repository
    set remote_repo $TEST_TEMP_DIR/remote_repo
    git init --bare $remote_repo --quiet
    git remote add origin $remote_repo

    # Push initial state to remote
    echo "initial content" >initial.txt
    git add initial.txt
    git commit -m "Initial commit" --quiet
    git push origin main --quiet

    # Make a change directly in the remote (simulating another developer's push)
    cd $TEST_TEMP_DIR
    git clone $remote_repo clone_repo --quiet
    cd clone_repo
    echo "remote change" >remote.txt
    git add remote.txt
    git commit -m "Remote commit" --quiet
    git push origin main --quiet

    # Go back to original repo (which doesn't have the remote change yet)
    cd $TEST_TEMP_DIR/test_repo

    # Create a new worktree - it should fetch and include the remote change
    set output (wt new feature-fetch 2>&1)
    assert_success "Should create worktree successfully"
    assert_contains "$output" "Fetching latest changes from origin" "Should show fetch message"
    assert_contains "$output" "Fetched latest changes from origin" "Should show fetch success"

    # Verify the new worktree has the remote change
    assert_success test -f remote.txt "Should have file from remote after fetch"

    test_pass
end

function test_wt_new_editor_options
    test_case "wt new - editor launch options"

    cd $TEST_TEMP_DIR/test_repo

    # Test help shows editor options
    set output (wt new 2>&1)
    assert_contains "$output" --claude "Should show --claude option"
    assert_contains "$output" --cursor "Should show --cursor option"
    assert_contains "$output" --all "Should show --all option"
    assert_contains "$output" --none "Should show --none option"

    test_pass
end

function test_wt_new_with_none_option
    test_case "wt new --none - creates worktree without launching editor"

    cd $TEST_TEMP_DIR/test_repo

    # Create worktree with --none option
    set output (wt new feature-no-editor --none 2>&1)
    assert_success "Should create worktree successfully"

    # Verify worktree was created
    assert_branch_exists feature-no-editor "Branch should exist"

    # Verify no editor launch messages (use string match to check they're NOT present)
    if string match -q "*Launching Cursor*" $output
        echo ""
        echo "✗ Test failed: Output should not contain 'Launching Cursor'"
        return 1
    end
    if string match -q "*Launching Claude*" $output
        echo ""
        echo "✗ Test failed: Output should not contain 'Launching Claude'"
        return 1
    end

    test_pass
end

function test_wt_new_editor_options_with_from
    test_case "wt new - editor options work with --from"

    cd $TEST_TEMP_DIR/test_repo

    # Create a tag to use as ref
    git tag v1.0.0

    # Test --none option with --from
    wt new feature-from-tag --from v1.0.0 --none
    assert_success "Should create worktree with --from and --none"
    assert_branch_exists feature-from-tag "Branch should exist"

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
test_wt_new_default_from_main
test_wt_new_fetches_from_origin
test_wt_new_editor_options
test_wt_new_with_none_option
test_wt_new_editor_options_with_from
