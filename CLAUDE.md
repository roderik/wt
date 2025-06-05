# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Setup
```fish
./setup-dev.fish        # Set up pre-commit hooks and development environment
source wt.fish          # Load wt function into current Fish shell
```

### Testing
```fish
./run_tests.fish                                    # Run complete test suite
./tests/test_runner.fish tests/test_wt_new.fish    # Run specific test file
./tests/test_runner.fish tests/test_*.fish         # Run multiple test files
fish -n wt.fish                                     # Check Fish syntax
fish_indent --check wt.fish                         # Check formatting
```

### Code Quality
```fish
pre-commit run --all-files      # Run all pre-commit hooks manually
fish_indent -w wt.fish          # Format Fish script
pre-commit autoupdate           # Update pre-commit hooks
```

## Important Notes
- run pre-commit before committing and fix all issues
- always run pre-commit and the tests before committing, they should all pass

## Architecture

The codebase implements a git worktree manager as a single Fish shell function with modular subcommands:

### Core Structure
- **wt.fish**: Main entry point containing all functionality
  - Main `wt` function routes to subcommand functions
  - Subcommand functions prefixed with `_wt_` (e.g., `_wt_new`, `_wt_switch`)
  - Utility function `_wt_get_repo_root` handles repository detection across worktrees
  - Fish completions defined at end of file

### Key Design Decisions
1. **Single File Design**: All functionality in wt.fish for easy distribution
2. **Worktree Location**: Creates worktrees in `.worktrees/` directory at repository root
3. **Package Manager Detection**: Auto-detects Bun/NPM/Yarn/PNPM based on lockfiles
4. **Safety**: Requires confirmation for destructive operations (remove, clean)
5. **Error Handling**: Validates git repository status before all operations

### Testing Infrastructure
- **tests/test_runner.fish**: Custom test framework with assertions
- **tests/test_wt_*.fish**: Unit tests for each command
- **tests/test_integration.fish**: End-to-end workflow tests
- Tests run in isolated temporary git repositories

### CI/CD Pipeline
- GitHub Actions workflow (`.github/workflows/ci.yml`)
- Tests on Ubuntu and macOS with Fish 4.0+
- Includes linting, security scanning, and performance testing
- Pre-commit hooks enforce formatting with fish_indent

## Important Patterns

### Function Flow
```
wt <command> → main router → _wt_<command> → validate repo → execute → feedback
```

### Path Resolution
Always use `_wt_get_repo_root` to find repository root, as it handles:
- Main repository detection
- Worktree to main repository resolution
- Nested directory traversal

### Package Manager Priority
1. bun.lock/bun.lockb/bunfig.toml → Bun
2. package-lock.json → NPM
3. yarn.lock → Yarn
4. pnpm-lock.yaml → PNPM
5. Default → Bun

### Testing New Features
1. Add unit tests in `tests/test_wt_<command>.fish`
2. Use test framework assertions (`assert_success`, `assert_equal`, etc.)
3. Add integration test scenarios if needed
4. Run `./run_tests.fish` to verify
