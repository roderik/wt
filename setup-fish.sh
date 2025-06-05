#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐟 Fish Shell Setup Script${NC}"
echo -e "${BLUE}=========================${NC}"
echo ""

# Detect OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS" != "Darwin" ]]; then
    echo -e "${RED}Error: This script is designed for macOS only.${NC}"
    exit 1
fi

# Detect Homebrew path based on architecture
if [[ "$ARCH" == "arm64" ]]; then
    BREW_PATH="/opt/homebrew/bin/brew"
    FISH_PATH="/opt/homebrew/bin/fish"
else
    BREW_PATH="/usr/local/bin/brew"
    FISH_PATH="/usr/local/bin/fish"
fi

# Install or update Homebrew
echo -e "${YELLOW}📦 Checking Homebrew installation...${NC}"
if ! command -v "$BREW_PATH" &> /dev/null; then
    echo -e "${YELLOW}Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo -e "${GREEN}✓ Homebrew is already installed${NC}"
    echo -e "${YELLOW}Updating Homebrew...${NC}"
    "$BREW_PATH" update
fi

# Install modern tools
echo -e "${YELLOW}📦 Installing modern development tools...${NC}"
TOOLS=(
    "fish"      # Fish shell
    "starship"  # Modern prompt
    "bat"       # Better cat
    "chafa"     # Terminal graphics
    "hexyl"     # Hex viewer
    "fd"        # Better find
    "ripgrep"   # Better grep
    "git-delta" # Better git diff
    "procs"     # Better ps
    "broot"     # Better tree
    "nvim"      # Neovim
    "eza"       # Better ls (exa replacement)
    "fnm"       # Fast Node.js version manager
    "1password-cli" # 1Password CLI
    "lazygit"   # Terminal UI for git
    "lazydocker" # Terminal UI for docker
    "fzf"       # Fuzzy finder
    "direnv"    # Per-project environment variables
    "zoxide"    # Smarter cd command
    "atuin"     # Better shell history
)

for tool in "${TOOLS[@]}"; do
    if "$BREW_PATH" list --versions "$tool" &> /dev/null; then
        echo -e "${GREEN}✓ $tool is already installed${NC}"
    else
        echo -e "${YELLOW}Installing $tool...${NC}"
        "$BREW_PATH" install "$tool"
    fi
done

# Start atuin service
echo -e "${YELLOW}🚀 Starting atuin service...${NC}"
if "$BREW_PATH" services list | grep -q "atuin.*started"; then
    echo -e "${GREEN}✓ atuin service is already running${NC}"
else
    "$BREW_PATH" services start atuin
    echo -e "${GREEN}✓ atuin service started${NC}"
fi

# Add Fish to allowed shells
echo -e "${YELLOW}🐟 Configuring Fish shell...${NC}"
if grep -q "$FISH_PATH" /etc/shells; then
    echo -e "${GREEN}✓ Fish shell is already in /etc/shells${NC}"
else
    echo -e "${YELLOW}Adding Fish to allowed shells (requires sudo)...${NC}"
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    echo -e "${GREEN}✓ Fish shell added to /etc/shells${NC}"
fi

# Create config directories
echo -e "${YELLOW}📁 Creating configuration directories...${NC}"
mkdir -p ~/.config/fish
mkdir -p ~/.config/starship

# Detect if running from local directory or curl
if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "$(dirname "${BASH_SOURCE[0]:-}")/config/fish/config.fish" ]]; then
    # Local installation
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo -e "${YELLOW}📁 Local installation detected${NC}"

    # Copy Fish configuration
    echo -e "${YELLOW}🐟 Installing Fish configuration...${NC}"
    cp "$SCRIPT_DIR/config/fish/config.fish" ~/.config/fish/config.fish
    echo -e "${GREEN}✓ Fish configuration installed${NC}"

    # Copy Starship configuration
    echo -e "${YELLOW}⭐ Installing Starship configuration...${NC}"
    cp "$SCRIPT_DIR/config/starship/starship.toml" ~/.config/starship.toml
    echo -e "${GREEN}✓ Starship configuration installed${NC}"

    # Install wt if available
    if [[ -f "$SCRIPT_DIR/wt.fish" ]]; then
        echo -e "${YELLOW}🔧 Installing wt (git worktree manager)...${NC}"
        mkdir -p ~/.config/fish/functions
        cp "$SCRIPT_DIR/wt.fish" ~/.config/fish/functions/wt.fish
        echo -e "${GREEN}✓ wt installed${NC}"
    fi
else
    # Remote installation via curl
    echo -e "${YELLOW}🌐 Remote installation - downloading configurations...${NC}"

    # Base URL for raw GitHub content
    GITHUB_BASE="https://raw.githubusercontent.com/roderik/wt/main"

    # Download Fish configuration
    echo -e "${YELLOW}🐟 Downloading Fish configuration...${NC}"
    if curl -sL "$GITHUB_BASE/config/fish/config.fish" -o ~/.config/fish/config.fish; then
        echo -e "${GREEN}✓ Fish configuration installed${NC}"
    else
        echo -e "${RED}Error: Failed to download Fish configuration${NC}"
        exit 1
    fi

    # Download Starship configuration
    echo -e "${YELLOW}⭐ Downloading Starship configuration...${NC}"
    if curl -sL "$GITHUB_BASE/config/starship/starship.toml" -o ~/.config/starship.toml; then
        echo -e "${GREEN}✓ Starship configuration installed${NC}"
    else
        echo -e "${RED}Error: Failed to download Starship configuration${NC}"
        exit 1
    fi

    # Download and install wt
    echo -e "${YELLOW}🔧 Downloading wt (git worktree manager)...${NC}"
    mkdir -p ~/.config/fish/functions
    if curl -sL "$GITHUB_BASE/wt.fish" -o ~/.config/fish/functions/wt.fish; then
        echo -e "${GREEN}✓ wt installed${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not install wt (optional)${NC}"
        rm -f ~/.config/fish/functions/wt.fish
    fi
fi

# Final instructions
echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${BLUE}To start using Fish shell:${NC}"
echo "  1. Change your default shell:"
echo "     ${YELLOW}chsh -s $FISH_PATH${NC}"
echo ""
echo "  2. Start a new Fish shell session:"
echo "     ${YELLOW}$FISH_PATH${NC}"
echo ""
echo -e "${BLUE}Installed tools:${NC}"
echo "  • fish      - Friendly interactive shell"
echo "  • starship  - Cross-shell prompt"
echo "  • bat       - Cat with syntax highlighting"
echo "  • eza       - Modern replacement for ls"
echo "  • ripgrep   - Fast grep alternative"
echo "  • fd        - Fast find alternative"
echo "  • fzf       - Fuzzy finder"
echo "  • lazygit   - Terminal UI for git"
echo "  • lazydocker - Terminal UI for docker"
echo "  • fnm       - Fast Node.js version manager"
echo "  • direnv    - Per-project environment variables"
echo "  • zoxide    - Smarter cd command (z/zi)"
echo "  • atuin     - Better shell history with sync"
echo "  • And more!"
echo ""
echo -e "${BLUE}Configuration files installed:${NC}"
echo "  • ~/.config/fish/config.fish"
echo "  • ~/.config/starship.toml"
if [[ -f "$SCRIPT_DIR/wt.fish" ]]; then
    echo "  • ~/.config/fish/functions/wt.fish"
fi
