# Git Worktree Manager 🌿

> Professional git worktree management for parallel development workflows

**Author:** [@r0derik](https://x.com/r0derik) on X

[![Fish Shell](https://img.shields.io/badge/Fish_Shell-4.0+-blue.svg)](https://fishshell.com/)
[![Git](https://img.shields.io/badge/Git-2.5+-red.svg)](https://git-scm.com/)
[![Multi Package Manager](https://img.shields.io/badge/Package_Manager-Bun|NPM|Yarn|PNPM-orange.svg)](https://bun.sh/)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black.svg)](https://github.com/roderik/wt)

## Overview

Git Worktree Manager (`wt`) is a comprehensive Fish shell function for managing git worktrees with intelligent dependency management. Perfect for parallel development, feature isolation, and testing multiple approaches simultaneously without context switching.

### Why Git Worktrees?

- **🔄 No Context Switching**: Each worktree maintains its own working directory and branch state
- **🚀 Parallel Development**: Work on multiple features simultaneously
- **⚡ Zero Overhead**: Same `.git` repository, completely isolated working files
- **📦 Smart Dependencies**: Auto-detects and uses the right package manager (Bun/NPM/Yarn/PNPM)
- **🎯 Flexible Creation**: Create worktrees from any branch, tag, or commit
- **🛡️ Risk-Free Experimentation**: Test breaking changes without affecting main workspace

## Features

- ✨ **Comprehensive Command Set** - Full lifecycle management with intuitive subcommands
- 📦 **Smart Package Manager Detection** - Auto-detects Bun, NPM, Yarn, or PNPM based on lockfiles
- 🎯 **Flexible Branch Creation** - Create worktrees from any ref with `--from` option
- 🗂️ **Intelligent Organization** - Uses `.worktrees` directory with robust path resolution
- 📊 **Rich Status Information** - Detailed worktree status and git information
- 🧹 **Granular Cleanup** - Remove individual worktrees or clean all at once
- ⌨️ **Tab Completion** - Full Fish shell completion support for all commands
- 🛡️ **Safety First** - Confirmation prompts and comprehensive validation

## Installation

### Prerequisites

- [Fish Shell](https://fishshell.com/) 4.0+
- [Git](https://git-scm.com/) 2.5+ (with worktree support)
- At least one package manager: [Bun](https://bun.sh/), NPM, [Yarn](https://yarnpkg.com/), or [PNPM](https://pnpm.io/)

### Recommended Installation

Install as a separate Fish function file for better organization:

```fish
# One-liner installation
mkdir -p ~/.config/fish/functions && curl -s https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish && source ~/.config/fish/config.fish

# Verify installation
wt help
```

### Alternative Installation

Add directly to your Fish config:

```fish
# Download and add to your Fish config
curl -s https://raw.githubusercontent.com/roderik/wt/main/wt.fish >> ~/.config/fish/config.fish

# Reload your config
source ~/.config/fish/config.fish
```

## Usage

### Core Commands

```fish
wt new <branch> [--from <ref>]  # Create worktree from ref (default: HEAD)
wt switch <branch>              # Switch to existing worktree (alias: s)
wt list                         # List all worktrees with status (alias: ls)
wt clean [--all]                # Clean up worktrees (alias for --all includes all)
wt remove <branch>              # Remove specific worktree (alias: rm)
wt status                       # Show current worktree status (alias: st)
wt help                         # Show detailed help (alias: h)
```

### Quick Start Examples

```fish
# Create worktrees with smart dependency installation
wt new feature-auth             # Create from current HEAD
wt new hotfix --from main       # Create from main branch
wt new experiment --from v1.2.3 # Create from specific tag

# Navigate between workspaces
wt switch feature-auth          # Jump to auth feature work
wt s api-refactor              # Use short alias

# Manage your worktrees
wt list                        # See all worktrees with status
wt status                      # Detailed info about current worktree
wt remove old-feature          # Remove specific worktree
wt clean                       # Remove all .worktrees/ worktrees
wt clean --all                 # Remove ALL worktrees
```

### Command Reference

| Command | Alias | Description | Example |
|---------|-------|-------------|---------|
| `wt new <branch> [--from <ref>]` | - | Create worktree from ref | `wt new feature-auth --from main` |
| `wt switch <branch>` | `s` | Switch to existing worktree | `wt s feature-auth` |
| `wt list` | `ls` | List all worktrees with status | `wt ls` |
| `wt clean [--all]` | - | Remove worktrees (--all for all) | `wt clean --all` |
| `wt remove <branch>` | `rm` | Remove specific worktree | `wt rm old-feature` |
| `wt status` | `st` | Show current worktree status | `wt st` |
| `wt help` | `h` | Show detailed help | `wt h` |

## How It Works

### Directory Structure

```
my-project/
├── .git/                    # Shared repository
├── src/                     # Main workspace files
├── package.json
├── bun.lockb               # Auto-detected: uses bun install
└── .worktrees/            # Isolated worktrees
    ├── feature-auth/      # Independent working directory
    │   ├── src/          # Same structure, different state
    │   ├── package.json  # Shared from main repo
    │   └── node_modules/ # Separate dependencies
    ├── api-refactor/
    └── hotfix-login/
```

### Smart Package Manager Detection

The tool automatically detects and uses the appropriate package manager:

| Detected File | Package Manager Used | Command Run |
|---------------|---------------------|-------------|
| `bun.lockb` or `bunfig.toml` | Bun | `bun install` |
| `package-lock.json` | NPM | `npm install` |
| `yarn.lock` | Yarn | `yarn install` |
| `pnpm-lock.yaml` | PNPM | `pnpm install` |
| `package.json` only | Bun (default) | `bun install` |

### What Happens When You Run `wt new`

1. **Validates** you're in a git repository and finds the repo root
2. **Verifies** the source reference exists (HEAD, branch, tag, or commit)
3. **Creates** `.worktrees` directory if it doesn't exist
4. **Creates** new worktree with fresh branch using `git worktree add -b`
5. **Switches** to the new worktree directory
6. **Detects** package manager and installs dependencies appropriately
7. **Reports** success with detailed information

## Workflow Examples

### Parallel Feature Development

```fish
# Start multiple features from different bases
wt new feature-user-profile           # From current HEAD
wt new feature-payments --from main   # From main branch
wt new hotfix-security --from v2.1.0  # From specific version

# Each gets its own:
# - Branch and commit history
# - Package manager dependencies (auto-detected)
# - Working directory state
# - No interference between features
```

### Advanced Branch Management

```fish
# Create experimental branches from different points
wt new experiment-ui --from feature-payments    # Branch from another feature
wt new prototype-v3 --from development         # Branch from dev branch
wt new rollback-test --from HEAD~10           # Branch from 10 commits ago

# Work with releases
wt new hotfix-critical --from v2.0.1          # Hotfix from specific release
wt new backport-feature --from release-branch # Backport to older release
```

### Enhanced Workflow Management

```fish
# Check current status
wt status                           # See where you are and what's changed
wt list                            # Overview of all worktrees

# Selective cleanup
wt remove old-experiment           # Remove specific worktree
wt remove hotfix-applied          # Clean up completed work

# Complete cleanup
wt clean                          # Remove all .worktrees/
wt clean --all                    # Remove ALL worktrees (including custom locations)
```

### Tab Completion Support

The tool includes comprehensive Fish shell completion:

```fish
wt <TAB>          # Shows all available subcommands
wt s <TAB>        # Shows all available branches for switching
wt rm <TAB>       # Shows branches that can be removed
wt new feat<TAB>  # Standard branch name completion
```

## Advanced Usage

### Integration with Development Workflow

```fish
# Create project-specific aliases
alias wtf="wt new feature-"
alias wth="wt new hotfix-"
alias wte="wt new experiment-"

# Usage
wtf user-dashboard --from main     # Creates "feature-user-dashboard" from main
wth login-bug --from production   # Creates "hotfix-login-bug" from production
```

### Custom Development Scripts

```fish
# Function for complete feature setup
function start_feature
    set feature_name $argv[1]
    set base_branch $argv[2]

    wt new feature-$feature_name --from $base_branch
    code .                         # Open in VS Code
    echo "🚀 Started feature: $feature_name"
end

# Usage
start_feature user-auth main      # Complete setup in one command
```

### Combine with Git Hooks

```fish
# .git/hooks/post-checkout (make executable)
#!/usr/bin/env fish
if test -f package.json
    echo "📦 Installing dependencies in new worktree..."
    # Dependencies are already handled by wt, but you can add other setup
    echo "🎉 Worktree ready for development!"
end
```

## Status and Information Commands

### Detailed Status Information

```fish
# Get comprehensive status
wt status
# Shows:
# - Current location and branch
# - Worktree type (main repo or worktree)
# - File change summary (staged, modified, untracked)
# - Upstream tracking information (ahead/behind)
```

### Enhanced Listing

```fish
# Rich worktree listing
wt list
# Shows:
# - Current worktree highlighted with arrow (→)
# - Branch names with commit hashes
# - Main repo vs worktree icons
# - Full paths for each worktree
```

## Troubleshooting

### Common Issues

**Worktree creation fails:**
```fish
# Ensure you're in a git repository
git status

# Check if reference exists
git show main  # or whatever ref you're using

# Verify branch doesn't already exist
git branch -a
```

**Package manager detection issues:**
```fish
# Check what package manager files exist
ls -la *.lock* *.json bunfig.toml

# Force specific package manager
rm other-lockfiles  # Remove conflicting lockfiles
```

**Cannot switch to worktree:**
```fish
# List available worktrees
wt list

# Check if worktree path exists
ls .worktrees/

# Recreate if necessary
wt remove broken-worktree
wt new fixed-worktree --from main
```

### Recovery Operations

```fish
# Clean up broken worktrees
git worktree prune                 # Remove stale references
wt clean --all                     # Nuclear option: remove all

# Fix repository issues
cd $(git rev-parse --show-toplevel) # Go to repo root
wt status                          # Check current state
```

## Testing

The project includes a comprehensive test suite to ensure reliability and prevent regressions.

### Running Tests

```fish
# Run all tests
./run_tests.fish

# Run specific test file
./tests/test_runner.fish tests/test_wt_new.fish

# Run multiple test files
./tests/test_runner.fish tests/test_wt_new.fish tests/test_wt_switch.fish
```

### Test Structure

```
tests/
├── test_runner.fish      # Test framework with assertions
├── test_wt_new.fish      # Tests for wt new command
├── test_wt_switch.fish   # Tests for wt switch command
├── test_wt_list.fish     # Tests for wt list command
├── test_wt_remove.fish   # Tests for wt remove command
├── test_wt_status.fish   # Tests for wt status command
├── test_wt_clean.fish    # Tests for wt clean command
├── test_wt_help.fish     # Tests for wt help command
├── test_utilities.fish   # Tests for utility functions
└── test_integration.fish # End-to-end workflow tests
```

### Test Framework Features

The test framework provides:
- **Setup/Teardown**: Automatic test environment creation and cleanup
- **Assertions**: `assert_equal`, `assert_contains`, `assert_dir_exists`, etc.
- **Colored Output**: Green for passed, red for failed tests
- **Test Summary**: Total passed/failed counts
- **Isolated Testing**: Each test runs in a temporary git repository

### Writing Tests

```fish
function test_my_feature
    test_case "Feature description"

    # Your test code here
    wt new test-branch
    assert_success "Should create worktree"

    # More assertions
    assert_dir_exists .worktrees/test-branch
    assert_branch_exists test-branch

    test_pass
end
```

### CI/CD Integration

The project uses GitHub Actions for continuous integration:

- **Test Matrix**: Tests run on Ubuntu and macOS with Fish 4.0+
- **Linting**: Fish syntax checking and formatting validation
- **Installation Tests**: Verifies curl and manual installation methods
- **Performance Tests**: Monitors operation performance
- **Security Scans**: Checks for hardcoded secrets and unsafe operations

## Contributing

This is a GitHub repository! Here's how you can contribute:

- **🌟 Star this repository** if you find it useful
- **🍴 Fork this repository** to create your own version
- **🎯 Submit a Pull Request** with your improvements
- **🐛 Open an Issue** for bugs or feature requests
- **📤 Share** the repository with others who might benefit

### Development Workflow

1. Fork the repository
2. Create a feature branch: `wt new feature-your-feature`
3. Set up development environment: `./setup-dev.fish`
4. Make your changes
5. Run tests: `./run_tests.fish`
6. Commit your changes (pre-commit hooks will auto-format)
7. Push to your fork
8. Create a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed development guidelines.

### Reporting Issues

Please open an issue on the repository with:
- Fish shell version (`fish --version`)
- Git version (`git --version`)
- Package manager versions (e.g., `bun --version`)
- Operating system
- Complete error messages
- Steps to reproduce

### Customization Ideas

Some ideas for customizing this script:
- **Editor integration**: Add automatic editor opening after worktree creation
- **Project templates**: Copy template files to new worktrees
- **Environment setup**: Run additional setup commands for specific project types
- **Notification integration**: Add desktop notifications for long operations
- **Git hooks**: Integrate with pre-commit hooks or other git automation

## Credits & Inspiration

- **Original concept**: Inspired by the [X post](https://x.com/kieranklaassen/status/1930040623643668552) by [Kieran Klaassen](https://x.com/kieranklaassen)
- **Git worktrees**: Leveraging the power of git's built-in worktree functionality
- **Fish shell**: Taking advantage of Fish's excellent scripting and completion capabilities
- **Modern tooling**: Built for projects using modern JavaScript package managers

## License

This project is released under the MIT License. Feel free to use, modify, and distribute.

---

**⭐ Star this repository if it helps streamline your development workflow!**

🐛 **Have improvements or found a bug?** Open an issue or submit a PR!
🍴 **Want to customize it?** Fork this repository and make it your own!
📤 **Found it useful?** Share it with your team!
