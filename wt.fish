# Git Worktree Management 🌿
# Professional git worktree management for parallel development workflows
#
# INSTALLATION (Recommended):
# Install as a separate Fish function file from GitHub gist:
#
#   mkdir -p ~/.config/fish/functions && curl -s https://gist.githubusercontent.com/roderik/2e97e8149f632c249631899c8c1d090e/raw/config.fish > ~/.config/fish/functions/wt.fish && source ~/.config/fish/config.fish
#
# ALTERNATIVE INSTALLATION:
# You can also add this function directly to your Fish configuration file,
# but the separate file approach is cleaner and more maintainable.
#
# USAGE:
#   wt new <branch> [--from <ref>]  - Create worktree from ref (default: HEAD)
#   wt switch <branch>              - Switch to existing worktree
#   wt list                         - List all worktrees with status
#   wt clean [--all]                - Clean up worktrees (--all includes non-.worktrees)
#   wt remove <branch>              - Remove specific worktree
#   wt status                       - Show current worktree status
#   wt help                         - Show detailed help
#
# EXAMPLES:
#   wt new feature-auth             # Create from HEAD
#   wt new hotfix --from main       # Create from main branch
#   wt switch feature-auth          # Switch to worktree
#   wt remove api-fix               # Remove specific worktree
#   wt status                       # Show current status
#
# GIST: https://gist.github.com/roderik/2e97e8149f632c249631899c8c1d090e

function wt --description "Git worktree management"
    # Check if we have any arguments
    if test (count $argv) -eq 0
        _wt_help
        return 1
    end

    set subcommand $argv[1]
    set remaining_args $argv[2..-1]

    switch $subcommand
        case new
            _wt_new $remaining_args
        case switch s
            _wt_switch $remaining_args
        case list ls
            _wt_list $remaining_args
        case clean
            _wt_clean $remaining_args
        case remove rm
            _wt_remove $remaining_args
        case status st
            _wt_status
        case help h
            _wt_help
        case '*'
            echo "Error: Unknown subcommand '$subcommand'"
            echo "Run 'wt help' for usage information"
            return 1
    end
end

function _wt_help --description "Show wt help information"
    echo "🌿 Git Worktree Manager"
    echo ""
    echo "USAGE:"
    echo "  wt <subcommand> [arguments]"
    echo ""
    echo "SUBCOMMANDS:"
    echo "  new <branch> [--from <ref>]  Create new worktree from ref (default: HEAD)"
    echo "  switch, s <branch>           Switch to existing worktree"
    echo "  list, ls                     List all worktrees with status"
    echo "  clean [--all]                Clean up worktrees (--all includes all)"
    echo "  remove, rm <branch>          Remove specific worktree"
    echo "  status, st                   Show current worktree status"
    echo "  help, h                      Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  wt new feature-auth          Create from current HEAD"
    echo "  wt new hotfix --from main    Create from main branch"
    echo "  wt switch feature-auth       Switch to worktree"
    echo "  wt remove api-fix            Remove specific worktree"
    echo "  wt status                    Show current status"
    echo ""
    echo "TIPS:"
    echo "  • Worktrees are created in .worktrees/ directory"
    echo "  • Each worktree has its own node_modules"
    echo "  • Use 'wt clean' to remove all worktrees safely"
end

function _wt_get_repo_root --description "Get the repository root consistently"
    # Try to get the common git directory
    set git_common_dir (git rev-parse --git-common-dir 2>/dev/null)
    if test $status -eq 0
        # If we got a common dir, the repo root is its parent
        if string match -q "*/.git" $git_common_dir
            echo (dirname $git_common_dir)
            return 0
        end
    end

    # Fallback to show-toplevel
    set toplevel (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0
        # If we're in a worktree, go up to find the main repo
        if test -f "$toplevel/.git"
            # .git is a file in worktrees, read it to find the real git dir
            set gitfile_content (cat "$toplevel/.git")
            if string match -q "gitdir: *" $gitfile_content
                set git_dir (string replace "gitdir: " "" $gitfile_content)
                # Extract main repo path from worktree git dir
                if string match -q "*/.git/worktrees/*" $git_dir
                    echo (string replace -r "/.git/worktrees/.*" "" $git_dir)
                    return 0
                end
            end
        else
            echo $toplevel
            return 0
        end
    end

    return 1
end

function _wt_new --description "Create new worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt new <branch> [--from <ref>]"
        return 1
    end

    set branch_name $argv[1]
    set from_ref HEAD

    # Parse optional --from argument
    set i 2
    while test $i -le (count $argv)
        if test "$argv[$i]" = "--from"
            set i (math $i + 1)
            if test $i -le (count $argv)
                set from_ref $argv[$i]
            else
                echo "Error: --from requires a ref argument"
                return 1
            end
        end
        set i (math $i + 1)
    end

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not determine repository root"
        return 1
    end

    # Validate branch name format
    if string match -q "*/*" $branch_name; or string match -q "* *" $branch_name
        echo "Error: Branch name should not contain slashes or spaces"
        return 1
    end

    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/$branch_name
        echo "Error: Branch '$branch_name' already exists"
        echo "Tip: Use 'wt switch $branch_name' to switch to it"
        return 1
    end

    # Verify the from ref exists
    if not git rev-parse --verify $from_ref >/dev/null 2>&1
        echo "Error: Reference '$from_ref' does not exist"
        return 1
    end

    # Create worktrees directory in the repository root if it doesn't exist
    set worktree_dir "$repo_root/.worktrees"
    if not test -d $worktree_dir
        mkdir -p $worktree_dir
        echo "Created worktrees directory: $worktree_dir"
    end

    set worktree_path "$worktree_dir/$branch_name"

    # Check if worktree path already exists
    if test -d $worktree_path
        echo "Error: Worktree directory already exists: $worktree_path"
        return 1
    end

    # Create the worktree with the new branch from specified ref
    echo "Creating worktree from '$from_ref'..."
    if git worktree add -b $branch_name $worktree_path $from_ref
        echo "✅ Successfully created worktree and branch '$branch_name'"
        echo "📍 Based on: $from_ref"
        echo "Switching to worktree directory..."
        cd $worktree_path
        echo "📁 Location: "(pwd)
        echo "🌿 Branch: "(git branch --show-current)

        # Check for package manager files and run install
        if test -f "package.json"
            echo ""
            if test -f "bun.lockb" -o -f "bunfig.toml" -o -f "bun.lock"
                echo "📦 Running bun install..."
                if bun install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: bun install failed"
                end
            else if test -f "package-lock.json"
                echo "📦 Running npm install..."
                if npm install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: npm install failed"
                end
            else if test -f "yarn.lock"
                echo "📦 Running yarn install..."
                if yarn install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: yarn install failed"
                end
            else if test -f "pnpm-lock.yaml"
                echo "📦 Running pnpm install..."
                if pnpm install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: pnpm install failed"
                end
            else
                echo "📦 Running bun install (default)..."
                if bun install
                    echo "✅ Dependencies installed successfully"
                else
                    echo "⚠️  Warning: bun install failed"
                end
            end
        end
    else
        echo "Error: Failed to create worktree"
        return 1
    end
end

function _wt_switch --description "Switch to existing worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt switch <branch>"
        return 1
    end

    set branch_name $argv[1]

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not find git repository root"
        return 1
    end

    set worktree_path "$repo_root/.worktrees/$branch_name"

    if test -d $worktree_path
        cd $worktree_path
        echo "✅ Switched to worktree: $branch_name"
        echo "📁 Location: "(pwd)
        echo "🌿 Branch: "(git branch --show-current)

        # Show brief status
        set modified_count (git status --porcelain | wc -l | string trim)
        if test $modified_count -gt 0
            echo "📝 Modified files: $modified_count"
        end
    else
        echo "Error: Worktree not found: $worktree_path"
        echo ""
        echo "Available worktrees:"
        _wt_list
        return 1
    end
end

function _wt_list --description "List all git worktrees"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    echo "📋 Git Worktrees:"
    echo ""

    # Get current directory to highlight current worktree
    set current_dir (pwd)

    # Parse git worktree list output for better formatting
    set worktree_info (git worktree list --porcelain)
    set current_path ""
    set current_branch ""
    set current_commit ""

    for line in $worktree_info
        if string match -q "worktree *" $line
            set current_path (string sub -s 10 $line)
        else if string match -q "HEAD *" $line
            set current_commit (string sub -s 6 $line | string sub -l 7)
        else if string match -q "branch *" $line
            set current_branch (string sub -s 8 $line | string replace "refs/heads/" "")
        else if test -z "$line"
            # Empty line means end of current worktree info
            if test -n "$current_path"
                # Check if this is the current worktree
                if test "$current_dir" = "$current_path"
                    echo -n "→ "
                else
                    echo -n "  "
                end

                # Format the output
                if string match -q "*/.worktrees/*" $current_path
                    set display_path (basename $current_path)
                    echo -n "🌿 $current_branch"
                else
                    set display_path "main"
                    echo -n "🏠 $current_branch"
                end

                echo " ($current_commit) - $current_path"

                # Reset for next worktree
                set current_path ""
                set current_branch ""
                set current_commit ""
            end
        end
    end
end

function _wt_status --description "Show current worktree status"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    echo "📊 Current Worktree Status:"
    echo ""

    # Get current worktree info
    set current_branch (git branch --show-current)
    set current_dir (pwd)

    echo "📁 Location: $current_dir"
    echo "🌿 Branch: $current_branch"

    # Check if we're in a worktree or main repo
    if string match -q "*/.worktrees/*" $current_dir
        echo "📍 Type: Worktree"
    else
        echo "📍 Type: Main repository"
    end

    # Show git status summary
    echo ""
    set modified_count (git diff --name-only | wc -l | string trim)
    set staged_count (git diff --cached --name-only | wc -l | string trim)
    set untracked_count (git ls-files --others --exclude-standard | wc -l | string trim)

    echo "📝 Changes:"
    echo "  • Staged: $staged_count files"
    echo "  • Modified: $modified_count files"
    echo "  • Untracked: $untracked_count files"

    # Show ahead/behind status
    set upstream (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if test -n "$upstream"
        set ahead_behind (git rev-list --left-right --count $upstream...HEAD 2>/dev/null)
        if test -n "$ahead_behind"
            set behind (echo $ahead_behind | cut -f1)
            set ahead (echo $ahead_behind | cut -f2)
            echo ""
            echo "📊 Upstream: $upstream"
            echo "  • Ahead: $ahead commits"
            echo "  • Behind: $behind commits"
        end
    end
end

function _wt_remove --description "Remove specific worktree"
    if test (count $argv) -eq 0
        echo "Usage: wt remove <branch>"
        return 1
    end

    set branch_name $argv[1]

    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not find git repository root"
        return 1
    end

    set worktree_path "$repo_root/.worktrees/$branch_name"

    if not test -d $worktree_path
        echo "Error: Worktree not found: $worktree_path"
        return 1
    end

    # Check if we're currently in the worktree we're trying to remove
    set current_dir (pwd)
    if test "$current_dir" = "$worktree_path"
        echo "Error: Cannot remove the worktree you're currently in"
        echo "Please switch to another worktree first"
        return 1
    end

    # Confirm removal
    echo "About to remove worktree:"
    echo "  📁 Path: $worktree_path"
    echo "  🌿 Branch: $branch_name"

    read -l -P "Remove this worktree? [y/N]: " confirmation

    if test "$confirmation" = "y"; or test "$confirmation" = "Y"
        if git worktree remove $worktree_path --force
            echo "✅ Successfully removed worktree: $branch_name"

            # Ask if they want to delete the branch too
            read -l -P "Also delete the branch '$branch_name'? [y/N]: " delete_branch
            if test "$delete_branch" = "y"; or test "$delete_branch" = "Y"
                if git branch -D $branch_name
                    echo "✅ Successfully deleted branch: $branch_name"
                else
                    echo "⚠️  Failed to delete branch: $branch_name"
                end
            end
        else
            echo "❌ Failed to remove worktree"
            return 1
        end
    else
        echo "Removal cancelled"
    end
end

function _wt_clean --description "Clean up all git worktrees"
    # Validate we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: Not in a git repository"
        return 1
    end

    # Get repository root
    set repo_root (_wt_get_repo_root)
    if test $status -ne 0
        echo "Error: Could not determine repository root"
        return 1
    end

    # Check for --all flag
    set include_all 0
    if contains -- --all $argv
        set include_all 1
    end

    # Get list of worktrees
    set worktree_info (git worktree list --porcelain)
    set worktrees_to_remove

    # Parse worktree info to get worktree paths
    for line in $worktree_info
        if string match -q "worktree *" $line
            set current_worktree (string sub -s 10 $line)
            # Include worktrees based on flag
            if test $include_all -eq 1
                # Include all worktrees except the main one
                if test "$current_worktree" != "$repo_root"
                    set worktrees_to_remove $worktrees_to_remove $current_worktree
                end
            else
                # Only include worktrees in .worktrees directory
                if string match -q "*/.worktrees/*" $current_worktree
                    set worktrees_to_remove $worktrees_to_remove $current_worktree
                end
            end
        end
    end

    if test (count $worktrees_to_remove) -eq 0
        echo "No worktrees found to clean up"
        if test $include_all -eq 0
            echo "Tip: Use 'wt clean --all' to include all worktrees"
        end
        return 0
    end

    echo "Found "(count $worktrees_to_remove)" worktree(s) to remove:"
    for worktree in $worktrees_to_remove
        echo "  📁 $worktree"
    end

    # Confirm before deletion
    read -l -P "Remove all these worktrees? [y/N]: " confirmation

    if test "$confirmation" = "y"; or test "$confirmation" = "Y"
        set removed_count 0
        set failed_count 0

        for worktree in $worktrees_to_remove
            echo "Removing worktree: $worktree"
            if git worktree remove $worktree --force
                echo "✅ Removed worktree: $worktree"
                set removed_count (math $removed_count + 1)
            else
                echo "⚠️  Failed to remove worktree: $worktree"
                set failed_count (math $failed_count + 1)
            end
        end

        echo ""
        echo "Summary:"
        echo "  ✅ Successfully removed: $removed_count worktree(s)"
        if test $failed_count -gt 0
            echo "  ❌ Failed to remove: $failed_count worktree(s)"
        end

        # Always navigate back to repository root after cleaning
        echo ""
        echo "📁 Returning to repository root: $repo_root"
        cd $repo_root
    else
        echo "Cleanup cancelled"
    end
end

# Add completion support
complete -c wt -f
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "new" -d "Create new worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "switch s" -d "Switch to worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "list ls" -d "List worktrees"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "clean" -d "Clean up worktrees"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "remove rm" -d "Remove worktree"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "status st" -d "Show status"
complete -c wt -n "not __fish_seen_subcommand_from new switch s list ls clean remove rm status st help h" -a "help h" -d "Show help"

# Complete branch names for switch and remove commands
complete -c wt -n "__fish_seen_subcommand_from switch s remove rm" -a "(git branch --format='%(refname:short)')"
complete -c wt -n "__fish_seen_subcommand_from new" -l from -d "Create from specific ref"
complete -c wt -n "__fish_seen_subcommand_from clean" -l all -d "Include all worktrees"

