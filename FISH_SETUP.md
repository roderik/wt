# Fish Shell Setup Guide 🐟

> Modern terminal setup with Fish shell and powerful development tools

This guide will help you set up Fish shell with a curated collection of modern CLI tools and configurations for an enhanced development experience.

## Quick Install (One-liner)

```bash
# Download and run the Fish setup (fetches configs from GitHub)
curl -sL https://raw.githubusercontent.com/roderik/wt/main/setup-fish.sh | bash
```

This will download all configurations directly from the GitHub repository and set up your Fish shell environment.

## Manual Setup

If you prefer to set things up manually:

```bash
# Clone the repository
git clone https://github.com/roderik/wt.git
cd wt

# Run the setup script
./setup-fish.sh

# Change your default shell to Fish
chsh -s $(which fish)
```

## What Gets Installed

The setup script installs and configures:

### 🐚 Fish Shell
- **Why:** User-friendly interactive shell with powerful features like autosuggestions, web-based configuration, and excellent tab completion
- **What:** Smart command-line shell that's easier to use than bash/zsh

### ⭐ Starship Prompt
- **Why:** Fast, customizable, and intelligent prompt that shows relevant information about your current directory
- **What:** Cross-shell prompt with git status, package versions, execution time, and more
- **Config:** Beautiful Catppuccin Macchiato theme pre-configured

### 🛠️ Modern CLI Tools

| Tool | Description | Replaces |
|------|-------------|----------|
| **bat** | `cat` with syntax highlighting and Git integration | `cat` |
| **eza** | Modern `ls` with icons and git status | `ls` |
| **ripgrep** | Ultra-fast text search | `grep` |
| **fd** | User-friendly file finder | `find` |
| **fzf** | Fuzzy finder for files, command history, and more | - |
| **lazygit** | Terminal UI for git commands | - |
| **lazydocker** | Terminal UI for docker management | - |
| **fnm** | Fast Node.js version manager | `nvm` |
| **git-delta** | Beautiful git diffs with syntax highlighting | - |
| **hexyl** | Hex viewer with colored output | `hexdump` |
| **procs** | Modern process viewer | `ps` |
| **broot** | Interactive tree view with search | `tree` |
| **zoxide** | Smarter directory navigation | `cd` |
| **atuin** | Better shell history with sync capabilities | - |
| **direnv** | Per-project environment variables | - |

### 🎯 Smart Aliases

Pre-configured aliases for common tasks:

- `ls`, `ll`, `la` → Enhanced directory listings with eza
- `cat` → Syntax highlighted file viewing with bat
- `g` → git shorthand
- `ga` → git add
- `gcm` → git commit -m
- `gp` → git push
- `gpu` → git pull
- `gst` → git status
- `lzg` → lazygit
- `lzd` → lazydocker
- `ff` → fzf with file preview
- `cd` → zoxide (smarter cd)
- `cdi` → zoxide interactive

### 📝 Git Abbreviations

Fish abbreviations that expand on space:

- `g` → `git`
- `ga` → `git add`
- `gaa` → `git add --all`
- `gb` → `git branch`
- `gco` → `git checkout`
- `gcm` → `git commit -m`
- `gd` → `git diff`
- `gp` → `git push`
- `gpu` → `git pull`
- `gst` → `git status`
- And many more...

## What the Setup Does

1. **Installs Homebrew** (if not present) - macOS package manager
2. **Installs Fish shell** and adds it to allowed shells
3. **Installs modern development tools** via Homebrew
4. **Configures Fish** with aliases, completions, and environment setup
5. **Configures Starship** with a beautiful, informative prompt
6. **Installs wt** (git worktree manager) automatically

The script is idempotent - you can run it multiple times to update your setup.

## Configuration Files

The setup creates:
- `~/.config/fish/config.fish` - Fish shell configuration
- `~/.config/starship.toml` - Starship prompt theme
- `~/.config/fish/functions/wt.fish` - Git worktree manager (if installed)

## System Requirements

- **macOS** (Intel or Apple Silicon)
- **Internet connection** for downloading tools
- **Admin privileges** for changing shell (optional)

## Post-Installation

After installation:

1. **Change your default shell** (optional):
   ```bash
   chsh -s $(which fish)
   ```

2. **Start a new Fish shell session**:
   ```bash
   fish
   ```

3. **Explore the features**:
   - Try typing a command and pressing Tab for completions
   - Use up/down arrows to search command history
   - Type `help` to open Fish documentation
   - Run `fish_config` to customize your setup

## Customization

### Modifying Configuration

Edit your Fish configuration:
```fish
nano ~/.config/fish/config.fish
```

Edit your Starship prompt:
```fish
nano ~/.config/starship.toml
```

### Adding Custom Functions

Create custom Fish functions:
```fish
# Create a new function
function myfunction
    echo "Hello from my function!"
end

# Save it permanently
funcsave myfunction
```

### Updating Tools

Update all installed tools:
```bash
brew update && brew upgrade
```

## Troubleshooting

### Fish not found after installation

Make sure Homebrew's bin directory is in your PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Permission issues

If you get permission errors when changing your shell:
```bash
# Add Fish to allowed shells manually
sudo sh -c "echo $(which fish) >> /etc/shells"
```

### Tools not working

Ensure Fish is loading the configuration:
```fish
source ~/.config/fish/config.fish
```

## Uninstalling

To remove Fish shell and revert to your previous shell:

```bash
# Change back to bash or zsh
chsh -s /bin/bash  # or /bin/zsh

# Remove Fish configuration
rm -rf ~/.config/fish

# Uninstall Fish (optional)
brew uninstall fish

# Remove other tools (optional)
brew uninstall starship bat eza ripgrep fd fzf # etc...
```

## Contributing

Found an issue or have a suggestion? Please open an issue or submit a PR on the [GitHub repository](https://github.com/roderik/wt).

## License

This setup script is part of the wt project and is released under the MIT License.
