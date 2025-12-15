# 🚀 WP-Studio - Ultimate WordPress Development Environment

**Team:** 2 Developers  
**Purpose:** Commercial WordPress theme & plugin development  
**Tech Stack:** Docker, PHP 8.2, MySQL 8.0, Node 20, Redis, WP-CLI

---

## 🎯 Quick Start (5 Minutes)

### 1. First Time Setup
```bash
# Clone the repository
git clone <your-repo-url> WP-Studio
cd WP-Studio

# Copy environment file
cp .env.example .env

# Generate WordPress salts
curl https://api.wordpress.org/secret-key/1.1/salt/ >> .env

# Start the studio
make up

# Install WordPress (wait 15 seconds after 'make up')
make fresh
```

### 2. Access Points
- **WordPress:** http://localhost:8000
- **Admin:** http://localhost:8000/wp-admin (admin/admin)
- **Database:** http://localhost:8080
- **Emails:** http://localhost:8025
- **Redis:** localhost:6379

---

## 📚 Common Commands
```bash
make help              # Show all commands
make up                # Start studio
make down              # Stop studio
make fresh             # Fresh WordPress install
make logs              # View logs
make shell             # Open WordPress shell

# WP-CLI
make wp CMD="plugin list"
make wp CMD="theme list"

# WooCommerce
make install-woo       # Install WooCommerce

# Development
make build-theme NAME=my-theme
make watch-theme NAME=my-theme
make build-plugin NAME=my-plugin

# Testing
make lint              # Check code standards
make lint-fix          # Auto-fix code style
```

---

## 🎨 Project Structure

### Themes
- `_boilerplate-classic/` - Traditional PHP theme starter
- `_boilerplate-woo/` - UnderscoreTW for WooCommerce
- `_boilerplate-block/` - Frost FSE theme starter

### Plugins
- `_boilerplate-plugin/` - Standard plugin boilerplate

### Workflow
1. Copy a boilerplate folder
2. Rename to your project
3. Activate in WP Admin
4. Start developing

---

## 👥 Team Workflow

### Git Branches
- `main` - Production-ready code
- `develop` - Active development
- `feature/*` - New features
- `fix/*` - Bug fixes

### Before Committing
```bash
make lint              # Check coding standards
make test              # Run tests (if configured)
```

### Code Reviews
- All changes require review from the other team member
- Use Pull Requests for all merges to `main`

---

## 🛠️ Development Scenarios

### Scenario 1: New Plugin
```bash
# Copy boilerplate
cp -r wp-content/plugins/_boilerplate-plugin wp-content/plugins/my-new-plugin

# Build assets
make build-plugin NAME=my-new-plugin

# Activate in WP Admin
make wp CMD="plugin activate my-new-plugin"
```

### Scenario 2: WooCommerce Theme
```bash
# Copy WooCommerce boilerplate
cp -r wp-content/themes/_boilerplate-woo wp-content/themes/my-woo-theme

# Install WooCommerce
make install-woo

# Build and watch
make watch-theme NAME=my-woo-theme
```

### Scenario 3: Block Theme
```bash
# Copy block theme boilerplate
cp -r wp-content/themes/_boilerplate-block wp-content/themes/my-block-theme

# Activate (no build needed for JSON-based themes)
# Activate in WP Admin
```

---

## 🔒 Security Notes

- **Never commit `.env` file**
- Generate unique salts for each environment
- Use strong passwords in production
- Keep WordPress and plugins updated

---

## 🐛 Debugging

### Enable Xdebug in VS Code
1. Install "PHP Debug" extension
2. Use the provided `.vscode/launch.json`
3. Set breakpoints in your code
4. Start debugging (F5)

### View Logs
```bash
make logs              # WordPress container logs
docker-compose logs db # Database logs
```

---

## 📦 Deployment

### Export for Sale
```bash
# For plugins
cd wp-content/plugins/my-plugin
zip -r my-plugin.zip . -x "node_modules/*" "*.git/*" "*.md"

# For themes
cd wp-content/themes/my-theme
zip -r my-theme.zip . -x "node_modules/*" "*.git/*" "*.md"
```

---

## 🆘 Troubleshooting

### "Cannot connect to database"
```bash
make down
make up
# Wait 20 seconds for MySQL to start
```

### "Port already in use"
Change ports in `docker-compose.yml`:
- 8000 → 8001 (WordPress)
- 8080 → 8081 (PHPMyAdmin)
- 8025 → 8026 (MailHog)

### "Permission denied"
```bash
# Fix file permissions
docker-compose exec wordpress chown -R www-data:www-data /var/www/html/wp-content
```

---

## 📞 Support

Team Member 1: [Name] - [Email]
Team Member 2: [Name] - [Email]

---

**Last Updated:** $(date +%Y-%m-%d)