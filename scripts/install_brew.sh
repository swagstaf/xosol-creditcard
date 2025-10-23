#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "Homebrew already installed: $(brew --version | head -n1)"
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure PATH for Apple Silicon
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! grep -q 'brew shellenv' ~/.zprofile 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  if ! grep -q 'brew shellenv' ~/.bash_profile 2>/dev/null; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
  fi
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew --version
echo "Homebrew installation completed."
