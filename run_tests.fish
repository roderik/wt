#!/usr/bin/env fish
# Run all tests for wt.fish

set script_dir (dirname (status -f))
set test_dir "$script_dir/tests"

# Check if tests directory exists
if not test -d $test_dir
    echo "Error: tests directory not found at $test_dir"
    exit 1
end

# Find all test files
set test_files (find $test_dir -name "test_*.fish" -type f | sort)

if test (count $test_files) -eq 0
    echo "Error: No test files found in $test_dir"
    exit 1
end

echo "🧪 Running wt.fish test suite"
echo "Found "(count $test_files)" test files"
echo ""

# Run the test runner with all test files
$test_dir/test_runner.fish $test_files

# Exit with the test runner's exit code
exit $status
