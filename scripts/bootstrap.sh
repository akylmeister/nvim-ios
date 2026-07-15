#!/usr/bin/env bash
#
# Bootstrap external tooling for Neovim iOS/Swift development.
# The Neovim plugins install themselves from lazy-lock.json on first launch;
# this script installs the command-line tools that live *outside* Neovim.
#
# Usage:  ./scripts/bootstrap.sh
#
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1"; }
ok() { printf '\033[1;32m[ok]\033[0m %s\n' "$1"; }

# --- Xcode -----------------------------------------------------------------
if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode command line tools not found. Install Xcode from the App Store,"
  warn "then run:  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
else
  ok "Xcode: $(xcodebuild -version 2>/dev/null | head -1)"
fi

if ! xcrun --find sourcekit-lsp >/dev/null 2>&1; then
  warn "sourcekit-lsp not found (it ships with Xcode). Check your Xcode install."
else
  ok "sourcekit-lsp: $(xcrun --find sourcekit-lsp)"
fi

# --- Homebrew --------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  warn "Homebrew not found. Install it from https://brew.sh and re-run."
  exit 1
fi

info "Installing Homebrew tools"
# xcode-build-server : lets sourcekit-lsp understand .xcodeproj/.xcworkspace (BSP)
# xcbeautify         : prettifies xcodebuild logs (used by xcodebuild.nvim)
# swiftformat        : formatting  (conform.nvim)
# swiftlint          : linting     (nvim-lint)
brew install xcode-build-server xcbeautify swiftformat swiftlint

# --- Ruby gem for Tuist / project management -------------------------------
if command -v gem >/dev/null 2>&1; then
  if ! gem list -i xcodeproj >/dev/null 2>&1; then
    info "Installing xcodeproj gem (xcodebuild.nvim project management)"
    gem install xcodeproj || warn "Could not install xcodeproj gem (try: sudo gem install xcodeproj)"
  else
    ok "xcodeproj gem present"
  fi
fi

# --- Optional: Tuist -------------------------------------------------------
if ! command -v tuist >/dev/null 2>&1; then
  warn "Tuist not installed (optional). Install with:  brew install --cask tuist"
  warn "or:  curl -Ls https://install.tuist.io | bash"
else
  ok "tuist: $(tuist version 2>/dev/null || echo installed)"
fi

info "Done. Open Neovim; lazy.nvim will install plugins from lazy-lock.json."
info "Then, in a Swift project:  :XcodebuildSetup  ->  <leader>X"
