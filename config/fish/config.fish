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
    fnm env --use-on-cd | source
end

# 1Password CLI completion
if command -q op
    op completion fish | source
end

# Environment variables
set -gx NODE_NO_WARNINGS 1

# Claude Code background tasks
set -gx FORCE_AUTO_BACKGROUND_TASKS 1
set -gx ENABLE_BACKGROUND_TASKS 1

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# FZF configuration
if command -q fzf
    # Set up fzf key bindings and fuzzy completion
    fzf --fish | source

    # Custom FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
end

# Homebrew completions
if command -q brew
    if test -d (brew --prefix)"/share/fish/completions"
        set -p fish_complete_path (brew --prefix)/share/fish/completions
    end

    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end

# Modern command aliases and functions
function dockerclean --description 'Clean up Docker containers, images, and volumes'
    # Remove stopped containers
    set -l containers (docker ps -a -q)
    if test -n "$containers"
        docker rm $containers
    end

    # Remove unused images
    set -l images (docker images -q)
    if test -n "$images"
        docker rmi $images
    end

    # Remove dangling volumes
    set -l volumes (docker volume ls -f dangling=true -q)
    if test -n "$volumes"
        docker volume rm $volumes
    end
end

# Git functions
function gclean --description 'Remove local branches that have been merged'
    git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
end

function gbda --description 'Delete all branches that have been merged into main/master'
    git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*\$)" | command xargs git branch -d 2>/dev/null
end

function gfg --description 'Fuzzy find and checkout git branch'
    if not command -q fzf
        echo "fzf is required for this function"
        return 1
    end

    set -l branch (git branch -a | grep -v HEAD | string trim | fzf --height 20% --reverse --info=inline)
    if test -n "$branch"
        git checkout (echo $branch | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    end
end

function glog --description 'Pretty git log with graph'
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
end

# Aliases for complex commands (these need to stay as aliases due to quotes/complexity)
alias ls='eza -lh --group-directories-first'
alias l='eza --git-ignore --group-directories-first'
alias ll='eza --all --header --long --group-directories-first'
alias llm='eza --all --header --long --sort=modified --group-directories-first'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias n='nvim'
alias vim='nvim'
alias exa='eza'
alias claude='claude --dangerously-skip-permissions'

# Interactive session configuration
if status is-interactive
    # Initialize Starship prompt
    if command -q starship
        starship init fish | source
    end

    # Modern Fish abbreviations (expand on space)
    # Git abbreviations
    abbr --add g git
    abbr --add ga 'git add'
    abbr --add gaa 'git add --all'
    abbr --add gap 'git add --patch'
    abbr --add gb 'git branch'
    abbr --add gba 'git branch --all'
    abbr --add gbd 'git branch --delete'
    abbr --add gc 'git commit --verbose'
    abbr --add gca 'git commit --verbose --all'
    abbr --add gcam 'git commit --all --message'
    abbr --add gcm 'git commit --message'
    abbr --add gco 'git checkout'
    abbr --add gcob 'git checkout -b'
    abbr --add gcp 'git cherry-pick'
    abbr --add gd 'git diff'
    abbr --add gds 'git diff --staged'
    abbr --add gf 'git fetch'
    abbr --add gfa 'git fetch --all --prune'
    abbr --add gl 'git pull'
    abbr --add glg 'git log --stat'
    abbr --add glgg 'git log --graph'
    abbr --add glgga 'git log --graph --decorate --all'
    abbr --add glo 'git log --oneline --decorate'
    abbr --add gp 'git push'
    abbr --add gpf 'git push --force-with-lease'
    abbr --add gpr 'git pull --rebase'
    abbr --add gr 'git remote'
    abbr --add gra 'git remote add'
    abbr --add grb 'git rebase'
    abbr --add grbi 'git rebase --interactive'
    abbr --add grh 'git reset HEAD'
    abbr --add grhh 'git reset HEAD --hard'
    abbr --add grs 'git restore'
    abbr --add grss 'git restore --staged'
    abbr --add gs 'git status'
    abbr --add gss 'git status --short'
    abbr --add gst 'git stash'
    abbr --add gsta 'git stash apply'
    abbr --add gstd 'git stash drop'
    abbr --add gstl 'git stash list'
    abbr --add gstp 'git stash pop'
    abbr --add gsts 'git stash show --text'
    abbr --add gsw 'git switch'
    abbr --add gswc 'git switch --create'

    # Other useful abbreviations
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'
    abbr --add ..... 'cd ../../../..'

    # Docker abbreviations
    abbr --add d docker
    abbr --add dc 'docker compose'
    abbr --add lzd lazydocker

    # Other tool abbreviations
    abbr --add lzg lazygit

    # Additional git abbreviation
    abbr --add gcad 'git commit --all --amend'
end

# Bun
if test -d "$HOME/.bun"
    set -gx BUN_INSTALL "$HOME/.bun"
    fish_add_path -a "$BUN_INSTALL/bin"
end

# Foundry
if test -d "$HOME/.foundry/bin"
    fish_add_path -a "$HOME/.foundry/bin"
end

# pnpm
if test -d "$HOME/Library/pnpm"
    set -gx PNPM_HOME "$HOME/Library/pnpm"
    fish_add_path -p "$PNPM_HOME"
end

# Kubernetes krew
if test -d "$HOME/.krew/bin"
    fish_add_path -a "$HOME/.krew/bin"
end

# User-specific configuration
if test -f ~/.config/fish/user_config.fish
    source ~/.config/fish/user_config.fish
end

# Modern shell enhancements (install with: brew install direnv zoxide atuin)
# direnv - Per-project environment variables
if command -q direnv
    direnv hook fish | source
end

# zoxide - Smarter cd command
if command -q zoxide
    zoxide init fish | source
    alias cd='z'
    alias cdi='zi' # interactive selection
end

# atuin - Better shell history
if command -q atuin
    atuin init fish | source
end
