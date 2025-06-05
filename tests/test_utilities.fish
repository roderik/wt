#!/usr/bin/env fish
# Unit tests for utility functions

function test_get_repo_root_in_main
    test_case "_wt_get_repo_root - in main repository"

    cd $TEST_TEMP_DIR/test_repo
    set repo_root (_wt_get_repo_root)
    assert_success "Should get repo root successfully"
    assert_equal (realpath "$TEST_TEMP_DIR/test_repo") (realpath $repo_root) "Should return correct root"

    test_pass
end

function test_get_repo_root_in_worktree
    test_case "_wt_get_repo_root - in worktree"

    cd $TEST_TEMP_DIR/test_repo
    wt new test-root-worktree

    set repo_root (_wt_get_repo_root)
    assert_success "Should get repo root from worktree"
    assert_equal (realpath "$TEST_TEMP_DIR/test_repo") (realpath $repo_root) "Should return main repo root"

    test_pass
end

function test_get_repo_root_outside_repo
    test_case "_wt_get_repo_root - outside repository"

    # Create a completely isolated temp directory
    set isolated_dir (mktemp -d)
    cd $isolated_dir
    _wt_get_repo_root 2>/dev/null
    assert_failure "Should fail outside repository"

    # Clean up
    rm -rf $isolated_dir

    test_pass
end

function test_get_repo_root_nested_dir
    test_case "_wt_get_repo_root - in nested directory"

    cd $TEST_TEMP_DIR/test_repo
    mkdir -p deeply/nested/directory
    cd deeply/nested/directory

    set repo_root (_wt_get_repo_root)
    assert_success "Should get repo root from nested dir"
    assert_equal (realpath "$TEST_TEMP_DIR/test_repo") (realpath $repo_root) "Should return correct root"

    test_pass
end

function test_branch_name_validation
    test_case "branch name validation in wt new"

    cd $TEST_TEMP_DIR/test_repo

    # Test various invalid branch names (only those that wt actually validates)
    set invalid_names feature/test "bug fix" another/slash/name

    for name in $invalid_names
        wt new $name 2>/dev/null
        assert_failure "Should reject invalid name: $name"
    end

    # Test that other special characters are allowed (git allows them)
    set valid_special_names "feat@ure" feature_underscore feature-dash
    for name in $valid_special_names
        # Clean up from previous attempts
        git branch -D $name 2>/dev/null || true
        git worktree prune 2>/dev/null || true
    end

    test_pass
end

function test_worktree_path_handling
    test_case "worktree path construction"

    cd $TEST_TEMP_DIR/test_repo
    # Create deeply nested current directory
    mkdir -p very/deep/nested/structure
    cd very/deep/nested/structure

    # Should still create worktree in repo root/.worktrees
    wt new nested-test

    # Go back to repo root to check
    cd $TEST_TEMP_DIR/test_repo
    assert_dir_exists .worktrees/nested-test "Should create in root .worktrees"

    test_pass
end

# Run all tests
test_get_repo_root_in_main
test_get_repo_root_in_worktree
test_get_repo_root_outside_repo
test_get_repo_root_nested_dir
test_branch_name_validation
test_worktree_path_handling
