# wt - Git Worktree Manager 🌿

> Streamlined git worktree management for Fish shell with intelligent dependency handling

**Author:** [@r0derik](https://x.com/r0derik) on X

[![Fish Shell](https://img.shields.io/badge/Fish_Shell-4.0+-blue.svg)](https://fishshell.com/)
[![Git](https://img.shields.io/badge/Git-2.5+-red.svg)](https://git-scm.com/)
[![Multi Package Manager](https://img.shields.io/badge/Package_Manager-Bun|NPM|Yarn|PNPM-orange.svg)](https://bun.sh/)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black.svg)](https://github.com/roderik/wt)

## What is wt?

`wt` is a Fish shell function that makes working with git worktrees effortless. It automates the creation, management, and cleanup of git worktrees while intelligently handling your project's dependencies.

### Why Use Git Worktrees?

- **🔄 No Context Switching**: Work on multiple features without stashing or committing WIP
- **⚡ Instant Branch Switching**: Each worktree is a separate directory with its own state
- **📦 Isolated Dependencies**: Each worktree maintains its own `node_modules`
- **🚀 Parallel Development**: Run tests on one branch while coding on another
- **🛡️ Safe Experimentation**: Break things without affecting your main workspace

## Quick Start

### Installation

```fish
# Option 1: Quick install (Fish only)
mkdir -p ~/.config/fish/functions && \
curl -s https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish && \
source ~/.config/fish/config.fish

# Option 2: Full install with Fish & Zsh support
git clone https://github.com/roderik/wt.git && \
cd wt && \
./install.fish

# Option 3: Full install with dev tools
git clone https://github.com/roderik/wt.git && \
cd wt && \
./install.fish --with-dev

# Verify installation
wt help
```

The full install script (`install.fish`) will:
- Install wt for both Fish and Zsh shells
- Set up consistent aliases and paths across both shells
- Configure modern shell enhancements (if installed): starship, direnv, zoxide, atuin
- Create a zsh wrapper function that calls the Fish implementation

### Basic Usage

```fish
# Create a new worktree for a feature
wt new feature-auth

# Switch between worktrees
wt switch feature-auth

# List all worktrees
wt list

# Remove a worktree when done
wt remove feature-auth
```

## Features

- ✨ **Simple Commands** - Intuitive command structure (`new`, `switch`, `list`, `remove`)
- 📦 **Auto Package Install** - Detects and runs the right package manager (Bun/NPM/Yarn/PNPM)
- 🎯 **Flexible Creation** - Create worktrees from any branch, tag, or commit
- 🗂️ **Clean Organization** - Stores worktrees in `~/.wt/<repo-name>/` for global organization
- 📊 **Rich Status Info** - See branch status, changes, and tracking info
- 🧹 **Safe Cleanup** - Remove worktrees with confirmation prompts
- ⌨️ **Tab Completion** - Full Fish shell completion support
- 🚨 **Smart Validation** - Prevents common errors with helpful messages

## Commands

```fish
wt new <branch> [--from <ref>]  # Create new worktree
wt switch <branch>              # Switch to worktree (alias: s)
wt list                         # List worktrees (alias: ls)
wt status                       # Show current status (alias: st)
wt remove <branch>              # Remove worktree (alias: rm)
wt clean [--all]                # Clean up worktrees
wt help                         # Show help (alias: h)

# Editor launch options
wt --claude                     # Open in Claude
wt --cursor                     # Open in Cursor
wt --all                        # Open in all editors
```

## How It Works

### Directory Structure

```
~/.wt/
├── my-project/             # Repository-specific worktrees
│   ├── feature-auth/      # Independent workspace
│   │   ├── src/          # Same structure as main
│   │   └── node_modules/ # Separate deps
│   └── bugfix-login/
└── another-project/       # Different repo's worktrees
    └── new-feature/

my-project/                 # Main repository
├── .git/                  # Shared repository
├── src/                   # Main workspace
├── package.json
└── bun.lockb             # Detected → uses bun
```

### Package Manager Detection

| Lock File | Package Manager | Command |
|-----------|----------------|---------|
| `bun.lock`/`bun.lockb` | Bun | `bun install` |
| `package-lock.json` | NPM | `npm install` |
| `yarn.lock` | Yarn | `yarn install` |
| `pnpm-lock.yaml` | PNPM | `pnpm install` |
| None (default) | Bun | `bun install` |

## Examples

### Feature Development Workflow

```fish
# Start a new feature from main
wt new feature-user-dashboard --from main

# Work on your feature...
# Need to check something on main?
wt switch main

# Back to your feature
wt s feature-user-dashboard

# Feature complete, clean up
wt remove feature-user-dashboard
```

### Hotfix Workflow

```fish
# Create hotfix from production tag
wt new hotfix-security --from v2.1.0

# Fix the issue...
# Deploy and cleanup
wt remove hotfix-security --force
```

### Parallel Testing

```fish
# Test different approaches
wt new approach-1 --from feature-branch
wt new approach-2 --from feature-branch

# Switch between them instantly
wt list  # See all worktrees
wt switch approach-1
```

## Requirements

- [Fish Shell](https://fishshell.com/) 4.0+
- [Git](https://git-scm.com/) 2.5+ (with worktree support)
- Package manager: [Bun](https://bun.sh/), NPM, [Yarn](https://yarnpkg.com/), or [PNPM](https://pnpm.io/)

### Don't have Fish shell?

Check out our [Fish Shell Setup Guide](FISH_SETUP.md) for a complete modern terminal setup with Fish and powerful development tools.

## Advanced Usage

### Integration with Git Aliases

```fish
# In your Fish config
alias gw="git worktree"
alias gwl="git worktree list"
alias gwp="git worktree prune"
```

### Custom Workflows

```fish
# Function for complete feature setup
function feature
    wt new feature-$argv[1] --from main
    code .  # Open in VS Code
    echo "🚀 Started feature: $argv[1]"
end

# Usage: feature user-auth
```

### Project-Specific Setup

```fish
# After worktree creation hook
function _wt_post_create
    # Run project-specific setup
    if test -f .env.example
        cp .env.example .env
    end
end
```

## Testing

```fish
# Run all tests
./run_tests.fish

# Run specific test
./tests/test_runner.fish tests/test_wt_new.fish
```

See [Testing Documentation](tests/README.md) for more details.

## Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch: `wt new feature-your-feature`
3. Make your changes
4. Run tests: `./run_tests.fish`
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Troubleshooting

### Common Issues

**"Not in a git repository"**
- Ensure you're inside a git repository
- Run `git status` to verify

**"Branch already exists"**
- Use `wt switch <branch>` instead
- Or remove it first: `wt remove <branch>`

**Package installation fails**
- Check your package manager is installed
- Verify lock files aren't corrupted
- Try removing `node_modules` and reinstalling

### Debug Mode

```fish
set -x WT_DEBUG 1
wt new test-branch  # Shows detailed output
```

## Credits

- Inspired by [Kieran Klaassen's workflow](https://x.com/kieranklaassen/status/1930040623643668552)
- Built for the Fish shell community
- Leverages git's powerful worktree feature

## License

MIT License - See [LICENSE](LICENSE) file for details.

---

**⭐ Star this repository if it helps your workflow!**

[Open an Issue](https://github.com/roderik/wt/issues) | [Submit a PR](https://github.com/roderik/wt/pulls) | [Fish Setup Guide](FISH_SETUP.md)
