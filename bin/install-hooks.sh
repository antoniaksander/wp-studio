#!/bin/bash

# Install Git hooks for team workflow

echo "Installing Git hooks..."

# Pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running pre-commit checks..."

# Run PHP linting
echo "→ Checking PHP code standards..."
docker-compose run --rm composer phpcs --standard=WordPress wp-content/plugins wp-content/themes
if [ $? -ne 0 ]; then
    echo "❌ PHP code standards check failed!"
    echo "Run 'make lint-fix' to auto-fix issues."
    exit 1
fi

# Run JS linting (if package.json exists)
if [ -f "package.json" ]; then
    echo "→ Checking JavaScript code..."
    npm run lint
    if [ $? -ne 0 ]; then
        echo "❌ JavaScript linting failed!"
        exit 1
    fi
fi

echo "✅ All checks passed!"
EOF

# Commit message hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

commit_msg=$(cat "$1")

# Check commit message format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Format: <type>(<scope>): <subject>"
    echo ""
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo ""
    echo "Example: feat(woo): add PayPal gateway"
    exit 1
fi
EOF

# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

echo "✅ Git hooks installed successfully!"