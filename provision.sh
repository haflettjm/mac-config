#!/bin/zsh

set -euo pipefail

echo "🚀 Starting macOS Dev Bootstrap..."

### Load config from .env
ENV_FILE="$(dirname "$0")/.env"
if [[ -f "$ENV_FILE" ]]; then
  echo "📄 Loading environment variables..."
  source "$ENV_FILE"
else
  echo "❌ .env file not found. Please create one with your git/email config."
  exit 1
fi

### 1. Install Xcode CLI tools
echo "🛠️ Installing Xcode Command Line Tools..."
xcode-select --install 2>/dev/null || echo "✅ Xcode CLI tools already installed"

### 2. Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing from Brewfile..."
brew update
brew bundle --file="$(dirname "$0")/Brewfile"

### 3. Set up Git
echo "🔐 Setting up Git..."
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor "nvim"

### 4. Install NVM and Node
echo "🟢 Setting up NVM and Node..."
export NVM_DIR="$HOME/.nvm"
source "/opt/homebrew/opt/nvm/nvm.sh"

nvm install "${node_version:-lts/*}"
nvm use "${node_version:-lts/*}"
nvm alias default "${node_version:-lts/*}"

### 5. Install global NPM packages
NPM_GLOBALS_FILE="$(dirname "$0")/npm-globals.txt"
if [[ -f "$NPM_GLOBALS_FILE" ]]; then
  echo "📦 Installing global NPM packages..."
  cat "$NPM_GLOBALS_FILE" | xargs npm install -g
else
  echo "⚠️ No npm-globals.txt found. Skipping NPM global install."
fi

### 6. Shell + Neovim config
DOTFILES="$(dirname "$0")/dotfiles"

echo "🧪 Installing dotfiles..."
cp "$DOTFILES/.zshrc" ~/.zshrc
cp "$DOTFILES/.zprofile" ~/.zprofile
cp "$DOTFILES/starship.toml" ~/.config/starship.toml
cp "$DOTFILES/.p10k.zsh" ~/.p10k.zsh

echo "📝 Setting Neovim as default editor..."
echo 'export EDITOR=nvim' >> ~/.zshrc

### 7. Starship & Powerlevel10k
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
echo 'source ~/.p10k.zsh' >> ~/.zshrc

### 8. Setup ~/git folder structure
echo "📁 Creating ~/git workspace folders..."
mkdir -p ~/git/{personal,work,demos}

### 9. Clone important repos
IMPORTANT_REPOS="$(dirname "$0")/important-repos.txt"
if [[ -f "$IMPORTANT_REPOS" ]]; then
  echo "📥 Cloning important repositories..."
  while read -r repo; do
    git clone "$repo" ~/git/personal/
  done < "$IMPORTANT_REPOS"
else
  echo "⚠️ No important-repos.txt found. Skipping repo cloning."
fi

### 10. Set background image
echo "🖼️ Setting wallpaper..."
WALLPAPER_PATH="$(dirname "$0")/backgrounds/wallpaper.jpg"
if [[ -f "$WALLPAPER_PATH" ]]; then
  osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\""
else
  echo "⚠️ No wallpaper.jpg found, skipping background setting."
fi

echo "✅ All done. Restart your terminal to apply settings."
"

