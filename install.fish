#!/usr/bin/env fish
# Install script for wt with full environment setup for both fish and zsh

set -l script_dir (dirname (status -f))
set -l script_name (basename (status -f))
set -l config_dir "$HOME/.config"
set -l zshrc "$HOME/.zshrc"
set -l zshenv "$HOME/.zshenv"

echo "🚀 Installing wt - Git Worktree Manager"
echo ""

# Ensure config directories exist
mkdir -p "$config_dir/fish/functions"
mkdir -p "$config_dir/fish/completions"

# Check if wt.fish exists
if not test -f "$script_dir/wt.fish"
    echo "❌ Error: wt.fish not found in $script_dir"
    echo "Please run this script from the wt repository directory."
    exit 1
end

# Install wt.fish to fish functions
echo "📦 Installing wt function for fish..."
cp "$script_dir/wt.fish" "$config_dir/fish/functions/wt.fish"

# Create fish config if it doesn't exist
if not test -f "$config_dir/fish/config.fish"
    echo "📝 Creating fish config..."
    touch "$config_dir/fish/config.fish"
end

# Install fish configuration
echo "🐟 Setting up fish shell configuration..."
if test -f "$script_dir/config/fish/config.fish"
    # Back up existing config
    if test -f "$config_dir/fish/config.fish"
        cp "$config_dir/fish/config.fish" "$config_dir/fish/config.fish.backup"
        echo "   Backed up existing config to config.fish.backup"
    end

    # Install new config
    cp "$script_dir/config/fish/config.fish" "$config_dir/fish/config.fish"
    echo "   ✅ Installed fish configuration"
else
    echo "   ⚠️  No fish config found in repo, skipping..."
end

# Create zsh configuration files
echo ""
echo "🐚 Setting up zsh shell configuration..."

# Create zshenv file
echo "📝 Creating .zshenv..."
if test -f "$zshenv"
    cp "$zshenv" "$zshenv.backup"
    echo "   Backed up existing .zshenv to .zshenv.backup"
end

# Write zshenv content
printf '%s\n' \
    '# Zsh Environment Configuration' \
    '# This file is sourced for all zsh instances (login and non-login)' \
    '' \
    '# Homebrew setup (detects M-series vs Intel Macs)' \
    'if [[ -e /opt/homebrew/bin/brew ]]; then' \
    '    eval "$(/opt/homebrew/bin/brew shellenv)"' \
    'elif [[ -e /usr/local/bin/brew ]]; then' \
    '    eval "$(/usr/local/bin/brew shellenv)"' \
    'fi' \
    '' \
    '# Environment variables' \
    'export NODE_NO_WARNINGS=1' \
    'export ENABLE_BACKGROUND_TASKS=1' \
    'export EDITOR=nvim' \
    'export VISUAL=nvim' \
    '' \
    '# FZF configuration' \
    'if command -v fzf &> /dev/null; then' \
    '    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"' \
    '    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"' \
    '    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview \"bat --style=numbers --color=always --line-range :500 {}\""' \
    'fi' \
    '' \
    '# Bun' \
    'if [[ -d "$HOME/.bun" ]]; then' \
    '    export BUN_INSTALL="$HOME/.bun"' \
    '    export PATH="$BUN_INSTALL/bin:$PATH"' \
    'fi' \
    '' \
    '# Foundry' \
    'if [[ -d "$HOME/.foundry/bin" ]]; then' \
    '    export PATH="$HOME/.foundry/bin:$PATH"' \
    'fi' \
    '' \
    '# pnpm' \
    'if [[ -d "$HOME/Library/pnpm" ]]; then' \
    '    export PNPM_HOME="$HOME/Library/pnpm"' \
    '    export PATH="$PNPM_HOME:$PATH"' \
    'fi' \
    '' \
    '# Kubernetes krew' \
    'if [[ -d "$HOME/.krew/bin" ]]; then' \
    '    export PATH="$HOME/.krew/bin:$PATH"' \
    'fi' \
    '' \
    '# Ensure wt function is available' \
    'if [[ -f "$HOME/.config/fish/functions/wt.fish" ]]; then' \
    '    # Create a wrapper function for zsh' \
    '    wt() {' \
    '        fish -c "wt $*"' \
    '    }' \
    'fi' > "$zshenv"

echo "   ✅ Created .zshenv"

# Create zshrc file
echo "📝 Creating .zshrc..."
if test -f "$zshrc"
    cp "$zshrc" "$zshrc.backup"
    echo "   Backed up existing .zshrc to .zshrc.backup"
end

# Write zshrc content
printf '%s\n' \
    '# Zsh Configuration' \
    '' \
    '# Fast Node Manager' \
    'if command -v fnm &> /dev/null; then' \
    '    eval "$(fnm env --use-on-cd)"' \
    'fi' \
    '' \
    '# 1Password CLI completion' \
    'if command -v op &> /dev/null; then' \
    '    eval "$(op completion zsh)"' \
    '    compdef _op op' \
    'fi' \
    '' \
    '# Modern command aliases' \
    'alias ls="eza -lh --group-directories-first"' \
    'alias l="eza --git-ignore --group-directories-first"' \
    'alias ll="eza --all --header --long --group-directories-first"' \
    'alias llm="eza --all --header --long --sort=modified --group-directories-first"' \
    'alias la="eza -lbhHigUmuSa"' \
    'alias lx="eza -lbhHigUmuSa@"' \
    'alias lt="eza --tree"' \
    'alias tree="eza --tree"' \
    'alias ff="fzf --preview \"bat --style=numbers --color=always {}\""' \
    'alias n="nvim"' \
    'alias vim="nvim"' \
    'alias exa="eza"' \
    '' \
    '# Claude function' \
    'claude() {' \
    '    command claude --dangerously-skip-permissions "$@"' \
    '}' \
    '' \
    '# Docker functions' \
    'dockerclean() {' \
    '    # Remove stopped containers' \
    '    local containers=$(docker ps -a -q)' \
    '    if [[ -n "$containers" ]]; then' \
    '        docker rm $containers' \
    '    fi' \
    '' \
    '    # Remove unused images' \
    '    local images=$(docker images -q)' \
    '    if [[ -n "$images" ]]; then' \
    '        docker rmi $images' \
    '    fi' \
    '' \
    '    # Remove dangling volumes' \
    '    local volumes=$(docker volume ls -f dangling=true -q)' \
    '    if [[ -n "$volumes" ]]; then' \
    '        docker volume rm $volumes' \
    '    fi' \
    '}' \
    '' \
    '# Git functions' \
    'gclean() {' \
    '    git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d' \
    '}' \
    '' \
    'gbda() {' \
    '    git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*$)" | command xargs git branch -d 2>/dev/null' \
    '}' \
    '' \
    'gfg() {' \
    '    if ! command -v fzf &> /dev/null; then' \
    '        echo "fzf is required for this function"' \
    '        return 1' \
    '    fi' \
    '' \
    '    local branch=$(git branch -a | grep -v HEAD | sed "s/^[ \t]*//" | fzf --height 20% --reverse --info=inline)' \
    '    if [[ -n "$branch" ]]; then' \
    '        git checkout $(echo $branch | sed "s/.* //" | sed "s#remotes/[^/]*/##")' \
    '    fi' \
    '}' \
    '' \
    'glog() {' \
    '    git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit' \
    '}' \
    '' \
    '# Git aliases (matching fish abbreviations)' \
    'alias g="git"' \
    'alias ga="git add"' \
    'alias gaa="git add --all"' \
    'alias gap="git add --patch"' \
    'alias gb="git branch"' \
    'alias gba="git branch --all"' \
    'alias gbd="git branch --delete"' \
    'alias gc="git commit --verbose"' \
    'alias gca="git commit --verbose --all"' \
    'alias gcam="git commit --all --message"' \
    'alias gcm="git commit --message"' \
    'alias gco="git checkout"' \
    'alias gcob="git checkout -b"' \
    'alias gcp="git cherry-pick"' \
    'alias gd="git diff"' \
    'alias gds="git diff --staged"' \
    'alias gf="git fetch"' \
    'alias gfa="git fetch --all --prune"' \
    'alias gl="git pull"' \
    'alias glg="git log --stat"' \
    'alias glgg="git log --graph"' \
    'alias glgga="git log --graph --decorate --all"' \
    'alias glo="git log --oneline --decorate"' \
    'alias gp="git push"' \
    'alias gpf="git push --force-with-lease"' \
    'alias gpr="git pull --rebase"' \
    'alias gr="git remote"' \
    'alias gra="git remote add"' \
    'alias grb="git rebase"' \
    'alias grbi="git rebase --interactive"' \
    'alias grh="git reset HEAD"' \
    'alias grhh="git reset HEAD --hard"' \
    'alias grs="git restore"' \
    'alias grss="git restore --staged"' \
    'alias gs="git status"' \
    'alias gss="git status --short"' \
    'alias gst="git stash"' \
    'alias gsta="git stash apply"' \
    'alias gstd="git stash drop"' \
    'alias gstl="git stash list"' \
    'alias gstp="git stash pop"' \
    'alias gsts="git stash show --text"' \
    'alias gsw="git switch"' \
    'alias gswc="git switch --create"' \
    'alias gcad="git commit --all --amend"' \
    '' \
    '# Directory navigation aliases' \
    'alias ...="cd ../.."' \
    'alias ....="cd ../../.."' \
    'alias .....="cd ../../../.."' \
    '' \
    '# Docker aliases' \
    'alias d="docker"' \
    'alias dc="docker compose"' \
    'alias lzd="lazydocker"' \
    '' \
    '# Other tool aliases' \
    'alias lzg="lazygit"' \
    '' \
    '# Initialize Starship prompt' \
    'if command -v starship &> /dev/null; then' \
    '    eval "$(starship init zsh)"' \
    'fi' \
    '' \
    '# Modern shell enhancements' \
    '# direnv - Per-project environment variables' \
    'if command -v direnv &> /dev/null; then' \
    '    eval "$(direnv hook zsh)"' \
    'fi' \
    '' \
    '# zoxide - Smarter cd command' \
    'if command -v zoxide &> /dev/null; then' \
    '    eval "$(zoxide init zsh)"' \
    '    alias cd="z"' \
    '    alias cdi="zi" # interactive selection' \
    'fi' \
    '' \
    '# atuin - Better shell history' \
    'if command -v atuin &> /dev/null; then' \
    '    eval "$(atuin init zsh)"' \
    'fi' \
    '' \
    '# FZF keybindings and completions' \
    'if command -v fzf &> /dev/null; then' \
    '    # Check for fzf installation directory' \
    '    if [[ -f ~/.fzf.zsh ]]; then' \
    '        source ~/.fzf.zsh' \
    '    elif [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then' \
    '        source /opt/homebrew/opt/fzf/shell/completion.zsh' \
    '        source /opt/homebrew/opt/fzf/shell/key-bindings.zsh' \
    '    elif [[ -f /usr/local/opt/fzf/shell/completion.zsh ]]; then' \
    '        source /usr/local/opt/fzf/shell/completion.zsh' \
    '        source /usr/local/opt/fzf/shell/key-bindings.zsh' \
    '    fi' \
    'fi' \
    '' \
    '# Source user-specific configuration if it exists' \
    'if [[ -f ~/.zshrc.local ]]; then' \
    '    source ~/.zshrc.local' \
    'fi' > "$zshrc"

echo "   ✅ Created .zshrc"

# Install development tools if requested
if test "$argv[1]" = --with-dev
    echo ""
    echo "🔧 Setting up development environment..."
    fish "$script_dir/setup-dev.fish"
end

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 What was installed:"
echo "   • wt function → $config_dir/fish/functions/wt.fish"
echo "   • fish config → $config_dir/fish/config.fish"
echo "   • zsh environment → $zshenv"
echo "   • zsh config → $zshrc"
echo ""
echo "🔄 To use wt in your current session:"
echo "   • Fish: source $config_dir/fish/functions/wt.fish"
echo "   • Zsh: source $zshenv && source $zshrc"
echo ""
echo "💡 The wt command will be available in all new shell sessions."
echo ""
echo "🚀 Run 'wt --help' to get started!"

# Reload fish functions in current session if running in fish
if test -n "$FISH_VERSION"
    source "$config_dir/fish/functions/wt.fish"
    echo ""
    echo "✨ wt is now available in this fish session!"
end
