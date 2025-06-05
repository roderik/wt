# Fish Shell Configuration
# Location: ~/.config/fish/config.fish

# Homebrew setup (detects M-series vs Intel Macs)
if test -e /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
else if test -e /usr/local/bin/brew
    eval "$(/usr/local/bin/brew shellenv)"
end

# Fast Node Manager
if command -q fnm
    eval "$(fnm env --use-on-cd)"
end

# 1Password CLI completion
if command -q op
    op completion fish | source
end

# Environment variables
set -x NODE_NO_WARNINGS 1

# Modern command aliases
alias dockerclean='docker rm $(docker ps -a -q); docker rmi $(docker images -q); docker volume rm $(docker volume ls -f dangling=true -q)'
alias dc='docker compose'
alias ls='eza -lh --group-directories-first'
alias l='eza --git-ignore --group-directories-first'
alias ll='eza --all --header --long --group-directories-first'
alias llm='eza --all --header --long --sort=modified --group-directories-first'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'
alias g='git'
alias d='docker'
alias lzg='lazygit'
alias lzd='lazydocker'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias n='nvim'
alias vim='nvim'
alias exa='eza'

# Interactive session configuration
if status is-interactive
    # Initialize Starship prompt
    if command -q starship
        eval "$(starship init fish)"
    end
end

# Bun
if test -d "$HOME/.bun"
    set -x BUN_INSTALL "$HOME/.bun"
    set -x PATH $BUN_INSTALL/bin $PATH
end

# Foundry
if test -d "$HOME/.foundry/bin"
    fish_add_path -a "$HOME/.foundry/bin"
end

# pnpm
if test -d "$HOME/Library/pnpm"
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
    end
end

# Kubernetes krew
if test -d "$HOME/.krew/bin"
    set -gx PATH $PATH $HOME/.krew/bin
end

# User-specific configuration
if test -f ~/.config/fish/user_config.fish
    source ~/.config/fish/user_config.fish
end