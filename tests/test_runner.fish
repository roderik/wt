#!/usr/bin/env fish
# Test runner for wt.fish
# Provides a simple test framework for Fish shell functions

set -g TEST_PASSED 0
set -g TEST_FAILED 0
set -g CURRENT_TEST ""
set -gx TEST_TEMP_DIR ""

# Color codes for output
set -g COLOR_GREEN \e\[32m
set -g COLOR_RED \e\[31m
set -g COLOR_YELLOW \e\[33m
set -g COLOR_RESET \e\[0m

function test_setup --description "Set up test environment"
    # Create temporary directory for tests in current folder structure
    set -gx TEST_TEMP_DIR (pwd)/.test_tmp_(random)
    mkdir -p $TEST_TEMP_DIR
    set -gx ORIGINAL_PWD (pwd)

    # Find the wt.fish file - check multiple possible locations
    set -l possible_paths \
        (dirname (dirname (realpath (status -f))))/wt.fish \
        (dirname (dirname (status -f)))/wt.fish \
        ./wt.fish \
        ../wt.fish

    set -l wt_file ""
    for path in $possible_paths
        if test -f $path
            set wt_file $path
            break
        end
    end

    if test -z "$wt_file"
        echo "Error: Could not find wt.fish"
        exit 1
    end

    # Source the main wt.fish file
    source $wt_file

    # Initialize test git repo
    cd $TEST_TEMP_DIR
    git init --quiet test_repo
    cd $TEST_TEMP_DIR/test_repo
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "# Test Repository" >README.md
    echo ".worktrees/" >.gitignore
    git add README.md .gitignore
    git commit -m "Initial commit" --quiet
end

function test_teardown --description "Clean up test environment"
    cd $ORIGINAL_PWD
    if test -d "$TEST_TEMP_DIR"
        rm -rf $TEST_TEMP_DIR
    end
end

function test_case --description "Start a new test case" --argument name
    set -g CURRENT_TEST $name
    echo -n "Testing $name... "
end

function assert_equal --description "Assert two values are equal" --argument expected actual message
    if test "$expected" = "$actual"
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Expected: '$expected'"
        echo "  Actual: '$actual'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_contains --description "Assert string contains substring" --argument haystack needle message
    if string match -q "*$needle*" $haystack
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  String: '$haystack'"
        echo "  Should contain: '$needle'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_dir_exists --description "Assert directory exists" --argument dir message
    if test -d "$dir"
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Directory does not exist: '$dir'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_dir_not_exists --description "Assert directory does not exist" --argument dir message
    if not test -d "$dir"
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Directory should not exist: '$dir'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_branch_exists --description "Assert git branch exists" --argument branch message
    if git show-ref --verify --quiet refs/heads/$branch
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Branch does not exist: '$branch'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_branch_not_exists --description "Assert git branch does not exist" --argument branch message
    if not git show-ref --verify --quiet refs/heads/$branch
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Branch should not exist: '$branch'"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_success --description "Assert last command succeeded" --argument message
    if test $status -eq 0
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Command should have succeeded"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function assert_failure --description "Assert last command failed" --argument message
    if test $status -ne 0
        return 0
    else
        echo ""
        echo "$COLOR_RED✗ $CURRENT_TEST failed$COLOR_RESET"
        echo "  Command should have failed"
        if test -n "$message"
            echo "  Message: $message"
        end
        set -g TEST_FAILED (math $TEST_FAILED + 1)
        return 1
    end
end

function test_pass --description "Mark current test as passed"
    echo "$COLOR_GREEN✓$COLOR_RESET"
    set -g TEST_PASSED (math $TEST_PASSED + 1)
end

function run_test_file --description "Run a test file" --argument file
    echo ""
    echo "$COLOR_YELLOW=== Running tests from $file ===$COLOR_RESET"
    source $file
end

function test_summary --description "Print test summary"
    echo ""
    echo "================================"
    echo "Test Summary:"
    echo "  $COLOR_GREEN✓ Passed: $TEST_PASSED$COLOR_RESET"
    echo "  $COLOR_RED✗ Failed: $TEST_FAILED$COLOR_RESET"
    echo "  Total: "(math $TEST_PASSED + $TEST_FAILED)
    echo "================================"

    if test $TEST_FAILED -gt 0
        return 1
    else
        return 0
    end
end

# Main test execution
if test (count $argv) -eq 0
    echo "Usage: test_runner.fish <test_files...>"
    exit 1
end

# Run setup
test_setup

# Run all test files
for test_file in $argv
    if test -f $test_file
        run_test_file $test_file
    else
        echo "$COLOR_RED✗ Test file not found: $test_file$COLOR_RESET"
        set -g TEST_FAILED (math $TEST_FAILED + 1)
    end
end

# Run teardown
test_teardown

# Print summary and exit with appropriate code
test_summary
exit $status
