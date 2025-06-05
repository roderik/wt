#!/usr/bin/env fish
# Development environment setup script

echo "🔧 Setting up development environment for wt..."

# Check if pre-commit is installed
if not command -q pre-commit
    echo "📦 Installing pre-commit..."

    # Try different installation methods
    if command -q pip
        pip install pre-commit
    else if command -q pip3
        pip3 install pre-commit
    else if command -q brew
        brew install pre-commit
    else if command -q apt-get
        sudo apt-get update && sudo apt-get install -y pre-commit
    else
        echo "❌ Error: Could not find a suitable package manager to install pre-commit"
        echo "Please install pre-commit manually: https://pre-commit.com/#install"
        exit 1
    end
end

# Install pre-commit hooks
echo "🪝 Installing pre-commit hooks..."
pre-commit install
pre-commit install --hook-type commit-msg

# Run pre-commit on all files to check current state
echo "🔍 Checking existing files..."
pre-commit run --all-files || true

echo "✅ Development environment setup complete!"
echo ""
echo "Pre-commit hooks will now run automatically before each commit."
echo "To manually run hooks: pre-commit run --all-files"
echo "To update hooks: pre-commit autoupdate"
