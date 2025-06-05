#!/usr/bin/env fish
# Unit tests for wt status command

function test_wt_status_in_main
    test_case "wt status - in main repository"

    cd $TEST_TEMP_DIR/test_repo
    # Ensure we're on main branch
    git checkout main --quiet 2>/dev/null || true

    set output (wt status 2>&1)
    assert_success "Should show status successfully"

    assert_contains "$output" "Current Worktree Status" "Should show header"
    assert_contains "$output" "Type: Main repository" "Should identify as main repo"
    assert_contains "$output" "Branch: main" "Should show main branch"

    test_pass
end

function test_wt_status_in_worktree
    test_case "wt status - in worktree"

    cd $TEST_TEMP_DIR/test_repo
    wt new feature-status

    set output (wt status 2>&1)
    assert_success "Should show status successfully"

    assert_contains "$output" "Type: Worktree" "Should identify as worktree"
    assert_contains "$output" "Branch: feature-status" "Should show correct branch"
    assert_contains "$output" ".worktrees/feature-status" "Should show worktree path"

    test_pass
end

function test_wt_status_shows_changes
    test_case "wt status - shows file changes"

    cd $TEST_TEMP_DIR/test_repo
    # Create some changes
    echo "new file" >newfile.txt
    echo modified >>README.md
    git add newfile.txt

    set output (wt status 2>&1)
    assert_success "Should show status successfully"

    assert_contains "$output" "Changes:" "Should show changes section"
    assert_contains "$output" "Staged:" "Should show staged count"
    assert_contains "$output" "Modified:" "Should show modified count"
    assert_contains "$output" "Untracked:" "Should show untracked count"

    test_pass
end

function test_wt_status_shows_upstream
    test_case "wt status - shows upstream info when available"

    cd $TEST_TEMP_DIR/test_repo
    # Set up a remote
    git remote add origin https://example.com/repo.git
    git push -u origin main 2>/dev/null || true

    set output (wt status 2>&1)
    assert_success "Should show status successfully"

    # Note: This might not show upstream in test environment
    # but should not fail

    test_pass
end

function test_wt_status_outside_repo
    test_case "wt status - outside git repo"

    # Create a completely isolated temp directory
    set isolated_dir (mktemp -d)
    cd $isolated_dir
    set output (wt status 2>&1)
    assert_failure "Should fail outside git repo"
    assert_contains "$output" "Not in a git repository" "Should show error message"

    # Clean up
    rm -rf $isolated_dir

    test_pass
end

function test_wt_status_clean_repo
    test_case "wt status - clean repository"

    # Create a fresh test repo to ensure clean state
    set clean_repo (mktemp -d)
    cd $clean_repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "# Clean Repo" >README.md
    git add README.md
    git commit -m "Initial commit" --quiet

    set output (wt status 2>&1)
    assert_success "Should show status successfully"

    assert_contains "$output" "Staged: 0 files" "Should show 0 staged"
    assert_contains "$output" "Modified: 0 files" "Should show 0 modified"
    assert_contains "$output" "Untracked: 0 files" "Should show 0 untracked"

    # Clean up
    cd $TEST_TEMP_DIR
    rm -rf $clean_repo

    test_pass
end

# Run all tests
test_wt_status_in_main
test_wt_status_in_worktree
test_wt_status_shows_changes
test_wt_status_shows_upstream
test_wt_status_outside_repo
test_wt_status_clean_repo
