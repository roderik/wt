# Contributing to wt

Thank you for your interest in contributing to wt! This guide will help you get started.

## Development Setup

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/wt.git
   cd wt
   ```

2. Create a new worktree for your feature (eating our own dog food!):
   ```fish
   source wt.fish
   wt new feature-your-feature
   ```

3. Set up the development environment:
   ```fish
   ./setup-dev.fish
   ```

   This will install pre-commit hooks that automatically:
   - Format Fish scripts with `fish_indent`
   - Check Fish syntax
   - Fix trailing whitespace
   - Ensure files end with a newline
   - Check YAML syntax

## Code Style

### Fish Scripts

All Fish scripts are automatically formatted using `fish_indent`. The pre-commit hooks will handle this for you, but you can also manually format files:

```fish
fish_indent -w wt.fish
fish_indent -w tests/*.fish
```

### General Guidelines

- Use descriptive variable names
- Add comments for complex logic
- Follow existing patterns in the codebase
- Keep functions focused and single-purpose
- Use meaningful commit messages

## Testing

### Running Tests Locally

Run the full test suite:
```fish
./run_tests.fish
```

Run specific tests:
```fish
./tests/test_runner.fish tests/test_wt_new.fish
```

### Writing Tests

When adding new features or fixing bugs:

1. Add appropriate unit tests in `tests/test_wt_*.fish`
2. Add integration tests if needed in `tests/test_integration.fish`
3. Ensure all tests pass before submitting a PR

Example test:
```fish
function test_my_new_feature
    test_case "My feature description"
    
    # Test setup
    wt new test-branch
    
    # Assertions
    assert_success "Should succeed"
    assert_dir_exists .worktrees/test-branch
    
    test_pass
end
```

## Pre-commit Hooks

The project uses pre-commit to maintain code quality. Hooks run automatically on commit, but you can also run them manually:

```bash
# Run on all files
pre-commit run --all-files

# Run on staged files
pre-commit run

# Update hooks to latest versions
pre-commit autoupdate
```

If a commit is rejected due to formatting:
1. The hooks will automatically fix most issues
2. Review the changes
3. Stage the fixed files
4. Commit again

## Pull Request Process

1. Ensure all tests pass
2. Update documentation if needed
3. Add tests for new functionality
4. Ensure your branch is up to date with main
5. Submit a PR with a clear description

### PR Title Format

Use conventional commit format:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `test:` Test additions/changes
- `chore:` Maintenance tasks
- `refactor:` Code refactoring

Example: `feat: add support for creating worktrees from tags`

## Running CI Locally

To simulate the CI environment:

```fish
# Run syntax checks
for file in *.fish tests/*.fish
    fish -n $file
end

# Run formatting checks
for file in *.fish tests/*.fish
    fish_indent --check $file
end

# Run tests
./run_tests.fish
```

## Questions?

If you have questions or need help:
1. Check existing issues and PRs
2. Open a new issue for discussion
3. Ask in PR comments

Thank you for contributing! 🎉