#!/usr/bin/env fish
# Integration tests for wt - testing complete workflows

function test_integration_full_workflow
    test_case "Integration - complete development workflow"

    cd $TEST_TEMP_DIR/test_repo

    # 1. Create feature branch worktree
    wt new feature-integration
    assert_success "Should create worktree"
    assert_equal (basename (pwd)) feature-integration "Should be in worktree"

    # 2. Make changes in the worktree
    echo "Feature implementation" >feature.txt
    git add feature.txt
    git commit -m "Add feature" --quiet

    # 3. Switch back to main
    cd $TEST_TEMP_DIR/test_repo
    assert_equal (git branch --show-current) main "Should be on main"

    # 4. Create another worktree
    wt new bugfix-integration
    assert_success "Should create second worktree"

    # 5. List all worktrees
    set list_output (wt list 2>&1)
    assert_contains "$list_output" feature-integration "Should list feature worktree"
    assert_contains "$list_output" bugfix-integration "Should list bugfix worktree"
    assert_contains "$list_output" main "Should list main"

    # 6. Switch between worktrees
    wt switch feature-integration
    assert_equal (basename (pwd)) feature-integration "Should switch to feature"

    wt switch bugfix-integration
    assert_equal (basename (pwd)) bugfix-integration "Should switch to bugfix"

    # 7. Check status in worktree
    set status_output (wt status 2>&1)
    assert_contains "$status_output" "Type: Worktree" "Should show worktree status"

    # 8. Clean up all worktrees
    cd $TEST_TEMP_DIR/test_repo
    echo y | wt clean

    assert_dir_not_exists .worktrees/feature-integration "Feature worktree should be removed"
    assert_dir_not_exists .worktrees/bugfix-integration "Bugfix worktree should be removed"

    test_pass
end

function test_integration_parallel_development
    test_case "Integration - parallel feature development"

    cd $TEST_TEMP_DIR/test_repo

    # Simulate working on multiple features in parallel

    # Feature 1: API development
    wt new api-development
    echo "api implementation" >api.txt
    git add api.txt
    git commit -m "Add API" --quiet

    # Feature 2: UI development (branched from main)
    cd $TEST_TEMP_DIR/test_repo
    wt new ui-development
    echo "ui implementation" >ui.txt
    git add ui.txt
    git commit -m "Add UI" --quiet

    # Feature 3: Hotfix from specific commit
    cd $TEST_TEMP_DIR/test_repo
    set main_commit (git rev-parse HEAD)
    echo "pre-hotfix change" >pre-hotfix.txt
    git add pre-hotfix.txt
    git commit -m "Change after hotfix point" --quiet

    wt new hotfix --from $main_commit
    assert_success "Should create hotfix from specific commit"
    # Verify the pre-hotfix file doesn't exist
    test -f pre-hotfix.txt
    assert_failure "Should not have later changes"

    # List to see all parallel work
    cd $TEST_TEMP_DIR/test_repo
    set output (wt list 2>&1)
    assert_contains "$output" api-development "Should show API worktree"
    assert_contains "$output" ui-development "Should show UI worktree"
    assert_contains "$output" hotfix "Should show hotfix worktree"

    test_pass
end

function test_integration_error_handling
    test_case "Integration - error handling and recovery"

    cd $TEST_TEMP_DIR/test_repo

    # Try to create worktree with existing branch name
    git checkout -b existing-feature --quiet
    git checkout main --quiet
    wt new existing-feature 2>/dev/null
    assert_failure "Should fail with existing branch"

    # Try to switch to non-existent worktree
    set output (wt switch nonexistent 2>&1)
    assert_failure "Should fail"
    assert_contains "$output" "Available worktrees" "Should show available options"

    # Create worktree, then try to create another with same name
    wt new duplicate-test
    cd $TEST_TEMP_DIR/test_repo
    wt new duplicate-test 2>/dev/null
    assert_failure "Should fail with duplicate name"

    # Try operations outside git repo
    set isolated_dir (mktemp -d)
    cd $isolated_dir
    wt list 2>/dev/null
    assert_failure "Should fail outside repo"
    rm -rf $isolated_dir

    test_pass
end

function test_integration_package_manager_detection
    test_case "Integration - package manager detection"

    cd $TEST_TEMP_DIR/test_repo

    # Test with package.json (npm)
    echo '{"name": "test", "dependencies": {"is-even": "^1.0.0"}}' >package.json
    echo '{
  "name": "test",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "test",
      "dependencies": {
        "is-even": "^1.0.0"
      }
    },
    "node_modules/is-even": {
      "version": "1.0.0",
      "resolved": "https://registry.npmjs.org/is-even/-/is-even-1.0.0.tgz",
      "integrity": "sha512-zfTTjx9RF1H9xBQkJ2NqzSv7MaC65VamezGLS7BoLfIvTd1r8rKDGifSjwpe4e8bVqcXSgkk7tZvUrqyf8XLvA==",
      "dependencies": {
        "is-odd": "^0.1.2"
      }
    },
    "node_modules/is-number": {
      "version": "3.0.0",
      "resolved": "https://registry.npmjs.org/is-number/-/is-number-3.0.0.tgz",
      "integrity": "sha512-4cbC0CCbwm4A6TKnZTx1+CvJPDdPnUiC1WT7ZWJr9s7CIJC/gxMOOlKCJR0LPuuLBPdE7GsUwg6AqG5qZfQ4eg==",
      "dependencies": {
        "kind-of": "^3.0.2"
      }
    },
    "node_modules/is-odd": {
      "version": "0.1.2",
      "resolved": "https://registry.npmjs.org/is-odd/-/is-odd-0.1.2.tgz",
      "integrity": "sha512-Bj5ln0TQHJ8nyPx1W7XITMUBW7aDI1SzfNy7REhLr5xmhwjDO/01S3V4PypCpCwaldbFOgG7PDs8UYDdWW9hQQ==",
      "dependencies": {
        "is-number": "^3.0.0"
      }
    },
    "node_modules/kind-of": {
      "version": "3.2.2",
      "resolved": "https://registry.npmjs.org/kind-of/-/kind-of-3.2.2.tgz",
      "integrity": "sha512-NOW9QQXMoZGg/oqnVNoNTTIFEIid1627WCffUBJEdMxYFc7G6ypF3oncLfvNhHOJfzFD1H8lxvNyPKYQvYeBjQ==",
      "dependencies": {
        "is-buffer": "^1.1.5"
      }
    },
    "node_modules/is-buffer": {
      "version": "1.1.6",
      "resolved": "https://registry.npmjs.org/is-buffer/-/is-buffer-1.1.6.tgz",
      "integrity": "sha512-NcdALwpXkTm5Zvvbk7owOUSvVvBKDgKP5/ewfXEznmQFfs4ZRmanOeKBTjRVWka0mHhYEdW3yvwSB8s9Vqpw=="
    }
  }
}' >package-lock.json
    git add package.json package-lock.json
    git commit -m "Add npm project files" --quiet

    # Capture output to check for npm install
    set output (wt new npm-project 2>&1)
    assert_success "Should create worktree"
    assert_contains "$output" "npm install" "Should detect npm"

    # Test with yarn
    cd $TEST_TEMP_DIR/test_repo
    rm package-lock.json
    echo '# THIS IS AN AUTOGENERATED FILE. DO NOT EDIT THIS FILE DIRECTLY.
# yarn lockfile v1


is-buffer@^1.1.5:
  version "1.1.6"
  resolved "https://registry.yarnpkg.com/is-buffer/-/is-buffer-1.1.6.tgz#efaa2ea9daa0d7ab2ea13a97b2b8ad51fefbe8be"
  integrity sha512-NcdALwpXkTm5Zvvbk7owOUSvVvBKDgKP5/ewfXEznmQFfs4ZRmanOeKBTjRVWka0mHhYEdW3yvwSB8s9Vqpw==

is-even@^1.0.0:
  version "1.0.0"
  resolved "https://registry.yarnpkg.com/is-even/-/is-even-1.0.0.tgz#76b5055fbad8d294a86b6a949015e1c97b717c06"
  integrity sha512-zfTTjx9RF1H9xBQkJ2NqzSv7MaC65VamezGLS7BoLfIvTd1r8rKDGifSjwpe4e8bVqcXSgkk7tZvUrqyf8XLvA==
  dependencies:
    is-odd "^0.1.2"

is-number@^3.0.0:
  version "3.0.0"
  resolved "https://registry.yarnpkg.com/is-number/-/is-number-3.0.0.tgz#24fd6201a4782cf50561c810276afc7d12d71195"
  integrity sha512-4cbC0CCbwm4A6TKnZTx1+CvJPDdPnUiC1WT7ZWJr9s7CIJC/gxMOOlKCJR0LPuuLBPdE7GsUwg6AqG5qZfQ4eg==
  dependencies:
    kind-of "^3.0.2"

is-odd@^0.1.2:
  version "0.1.2"
  resolved "https://registry.yarnpkg.com/is-odd/-/is-odd-0.1.2.tgz#bc573b5ce371ef2aad6e6f49799b72bef13978a7"
  integrity sha512-Bj5ln0TQHJ8nyPx1W7XITMUBW7aDI1SzfNy7REhLr5xmhwjDO/01S3V4PypCpCwaldbFOgG7PDs8UYDdWW9hQQ==
  dependencies:
    is-number "^3.0.0"

kind-of@^3.0.2:
  version "3.2.2"
  resolved "https://registry.yarnpkg.com/kind-of/-/kind-of-3.2.2.tgz#31ea21a734bab9bbb0f32466d893aea51e4a3c64"
  integrity sha512-NOW9QQXMoZGg/oqnVNoNTTIFEIid1627WCffUBJEdMxYFc7G6ypF3oncLfvNhHOJfzFD1H8lxvNyPKYQvYeBjQ==
  dependencies:
    is-buffer "^1.1.5"
' >yarn.lock
    git add yarn.lock
    git rm package-lock.json
    git commit -m "Switch to yarn" --quiet

    set output (wt new yarn-project 2>&1)
    assert_success "Should create worktree"
    assert_contains "$output" "yarn install" "Should detect yarn"

    # Test with pnpm
    cd $TEST_TEMP_DIR/test_repo
    rm yarn.lock
    echo 'lockfileVersion: "6.0"
dependencies:
  is-even:
    specifier: ^1.0.0
    version: 1.0.0
packages:
  /is-buffer@1.1.6:
    resolution: {integrity: sha512-NcdALwpXkTm5Zvvbk7owOUSvVvBKDgKP5/ewfXEznmQFfs4ZRmanOeKBTjRVWka0mHhYEdW3yvwSB8s9Vqpw==}
    dev: false
  /is-even@1.0.0:
    resolution: {integrity: sha512-zfTTjx9RF1H9xBQkJ2NqzSv7MaC65VamezGLS7BoLfIvTd1r8rKDGifSjwpe4e8bVqcXSgkk7tZvUrqyf8XLvA==}
    engines: {node: ">=0.10.0"}
    dependencies:
      is-odd: 0.1.2
    dev: false
  /is-number@3.0.0:
    resolution: {integrity: sha512-4cbC0CCbwm4A6TKnZTx1+CvJPDdPnUiC1WT7ZWJr9s7CIJC/gxMOOlKCJR0LPuuLBPdE7GsUwg6AqG5qZfQ4eg==}
    engines: {node: ">=0.10.0"}
    dependencies:
      kind-of: 3.2.2
    dev: false
  /is-odd@0.1.2:
    resolution: {integrity: sha512-Bj5ln0TQHJ8nyPx1W7XITMUBW7aDI1SzfNy7REhLr5xmhwjDO/01S3V4PypCpCwaldbFOgG7PDs8UYDdWW9hQQ==}
    engines: {node: ">=0.10.0"}
    dependencies:
      is-number: 3.0.0
    dev: false
  /kind-of@3.2.2:
    resolution: {integrity: sha512-NOW9QQXMoZGg/oqnVNoNTTIFEIid1627WCffUBJEdMxYFc7G6ypF3oncLfvNhHOJfzFD1H8lxvNyPKYQvYeBjQ==}
    engines: {node: ">=0.10.0"}
    dependencies:
      is-buffer: 1.1.6
    dev: false
' >pnpm-lock.yaml
    git add pnpm-lock.yaml
    git rm yarn.lock
    git commit -m "Switch to pnpm" --quiet

    set output (wt new pnpm-project 2>&1)
    assert_success "Should create worktree"
    assert_contains "$output" "pnpm install" "Should detect pnpm"

    # Test with bun
    cd $TEST_TEMP_DIR/test_repo
    rm pnpm-lock.yaml
    # For bun, just use an empty lockfile - it will be regenerated properly
    touch bun.lock
    git add bun.lock
    git rm pnpm-lock.yaml
    git commit -m "Switch to bun" --quiet

    set output (wt new bun-project 2>&1)
    assert_success "Should create worktree"
    assert_contains "$output" "bun install" "Should detect bun"

    test_pass
end

function test_integration_complex_repository_structure
    test_case "Integration - complex repository with nested worktrees"

    cd $TEST_TEMP_DIR/test_repo

    # Create a more complex repository structure
    mkdir -p src/components docs/api config
    echo source >src/main.js
    echo component >src/components/Button.js
    echo docs >docs/api/README.md
    echo config >config/app.json
    git add .
    git commit -m "Add complex structure" --quiet

    # Create worktree and verify files are there
    wt new complex-feature
    assert_success "Should create worktree"

    # Verify complex structure is preserved
    assert_success test -f src/main.js "Should have src/main.js"
    assert_success test -f src/components/Button.js "Should have component"
    assert_success test -f docs/api/README.md "Should have docs"
    assert_success test -f config/app.json "Should have config"

    # Make changes in worktree
    echo "modified in worktree" >>src/main.js

    # Switch to main and verify isolation
    cd $TEST_TEMP_DIR/test_repo
    set main_content (cat src/main.js)
    assert_equal source "$main_content" "Main should have original content"

    test_pass
end

function test_integration_worktree_removal_scenarios
    test_case "Integration - various removal scenarios"

    cd $TEST_TEMP_DIR/test_repo

    # Scenario 1: Remove worktree but keep branch
    wt new keep-branch-test
    cd $TEST_TEMP_DIR/test_repo
    printf "y\nn\n" | wt remove keep-branch-test

    assert_dir_not_exists .worktrees/keep-branch-test "Worktree should be gone"
    assert_branch_exists keep-branch-test "Branch should remain"

    # Scenario 2: Remove both worktree and branch
    wt new remove-both-test
    cd $TEST_TEMP_DIR/test_repo
    printf "y\ny\n" | wt remove remove-both-test

    assert_dir_not_exists .worktrees/remove-both-test "Worktree should be gone"
    assert_branch_not_exists remove-both-test "Branch should be gone"

    # Scenario 3: Remove while inside worktree (should auto-switch to main)
    wt new inside-test
    # We're now inside the worktree
    echo y | wt remove inside-test
    assert_success "Should succeed by auto-switching to main"

    # Verify we're now in main repository
    assert_equal (pwd) "$TEST_TEMP_DIR/test_repo" "Should be in main repository"
    assert_dir_not_exists .worktrees/inside-test "Worktree should be removed"

    test_pass
end

# Run all integration tests
test_integration_full_workflow
test_integration_parallel_development
test_integration_error_handling
test_integration_package_manager_detection
test_integration_complex_repository_structure
test_integration_worktree_removal_scenarios
