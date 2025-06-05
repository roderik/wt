#!/usr/bin/env fish
# Unit tests for wt list command

function test_wt_list_empty
    test_case "wt list - no worktrees"
    
    cd $TEST_TEMP_DIR/test_repo
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    assert_contains "$output" "Git Worktrees" "Should show header"
    
    test_pass
end

function test_wt_list_with_worktrees
    test_case "wt list - with multiple worktrees"
    
    cd $TEST_TEMP_DIR/test_repo
    # Create some worktrees
    wt new feature-list-1
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-list-2
    cd $TEST_TEMP_DIR/test_repo
    
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    assert_contains "$output" "feature-list-1" "Should show first worktree"
    assert_contains "$output" "feature-list-2" "Should show second worktree"
    assert_contains "$output" "main" "Should show main branch"
    
    test_pass
end

function test_wt_list_shows_current
    test_case "wt list - indicates current worktree"
    
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-current
    # We're now in feature-current
    
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    assert_contains "$output" "→" "Should show current indicator"
    assert_contains "$output" "→ 🌿 feature-current" "Should indicate current worktree"
    
    test_pass
end

function test_wt_list_shows_commits
    test_case "wt list - shows commit hashes"
    
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-commits
    
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    # Check for commit hash pattern (7 characters)
    assert_contains "$output" "(" "Should show commit info"
    assert_contains "$output" ")" "Should close commit info"
    
    test_pass
end

function test_wt_list_distinguishes_main
    test_case "wt list - distinguishes main repo"
    
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-type
    cd $TEST_TEMP_DIR/test_repo
    
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    assert_contains "$output" "🏠" "Should show home icon for main"
    assert_contains "$output" "🌿" "Should show tree icon for worktree"
    
    test_pass
end

function test_wt_list_shows_paths
    test_case "wt list - shows worktree paths"
    
    cd $TEST_TEMP_DIR/test_repo
    wt new feature-paths
    
    set output (wt list 2>&1)
    assert_success "Should list successfully"
    assert_contains "$output" ".worktrees/feature-paths" "Should show worktree path"
    assert_contains "$output" "test_repo" "Should show main repo path"
    
    test_pass
end

function test_wt_list_outside_repo
    test_case "wt list - outside git repo"
    
    cd $TEST_TEMP_DIR
    set output (wt list 2>&1)
    assert_failure "Should fail outside git repo"
    assert_contains "$output" "Not in a git repository" "Should show error message"
    
    test_pass
end

# Run all tests
test_wt_list_empty
test_wt_list_with_worktrees
test_wt_list_shows_current
test_wt_list_shows_commits
test_wt_list_distinguishes_main
test_wt_list_shows_paths
test_wt_list_outside_repo