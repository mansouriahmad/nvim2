#!/usr/bin/env bash
#
# bootstrap.sh — provision a fresh Debian/Ubuntu box for this Neovim config.
#
# Installs: build toolchain, Neovim (>=0.11), ripgrep, fd, Node.js (nvm),
# Rust (rustup), .NET SDK, Python, Zellij, lazygit, JetBrainsMono Nerd Font,
# zsh + starship (set as default shell), then clones this config and runs a
# headless plugin / LSP / formatter / debugger install.
#
# Safe to re-run: every step checks before it acts.
#
# Usage:
#   ./bootstrap.sh                  # full run
#   NVIM_BRANCH=main ./bootstrap.sh # clone a different branch of the config
#   SKIP_DOTNET=1 ./bootstrap.sh    # skip a component (SKIP_<NODE|RUST|DOTNET|
#                                   #   ZELLIJ|FONT|ZSH|NVIM_SYNC>)
#
set -euo pipefail

# ----------------------------------------------------------------------------
# Config (override via environment)
# ----------------------------------------------------------------------------
NVIM_REPO="${NVIM_REPO:-https://github.com/mansouriahmad/nvim2.git}"
NVIM_BRANCH="${NVIM_BRANCH:-dev_stable}"   # the branch you actually run
NERD_FONT_VERSION="${NERD_FONT_VERSION:-v3.4.0}"
NODE_VERSION="${NODE_VERSION:---lts}"
DOTNET_CHANNEL="${DOTNET_CHANNEL:-LTS}"

LOCAL_BIN="${HOME}/.local/bin"
FONT_DIR="${HOME}/.local/share/fonts"

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
c_blue='\033[1;34m'; c_green='\033[1;32m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'; c_off='\033[0m'
log()   { printf "${c_blue}==>${c_off} %s\n" "$*"; }
ok()    { printf "${c_green}  ok${c_off} %s\n" "$*"; }
warn()  { printf "${c_yellow}  !!${c_off} %s\n" "$*"; }
die()   { printf "${c_red}error:${c_off} %s\n" "$*" >&2; exit 1; }
have()  { command -v "$1" >/dev/null 2>&1; }
skip()  { local v="SKIP_$1"; [ "${!v:-0}" = "1" ]; }

# Append a line to a file only if it is not already present.
ensure_line() {
  local line="$1" file="$2"
  touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >>"$file"
}

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  NVIM_ARCH="x86_64";  ZELLIJ_ARCH="x86_64";  LG_ARCH="x86_64" ;;
  aarch64|arm64) NVIM_ARCH="arm64"; ZELLIJ_ARCH="aarch64"; LG_ARCH="arm64" ;;
  *) die "unsupported architecture: $ARCH" ;;
esac

[ "$(id -u)" -eq 0 ] && SUDO="" || SUDO="sudo"
have apt-get || die "this script targets Debian/Ubuntu (apt-get not found)"

mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# ----------------------------------------------------------------------------
# 1. APT packages
# ----------------------------------------------------------------------------
log "Installing base packages via apt"
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  build-essential cmake pkg-config \
  git curl wget unzip tar ca-certificates gnupg \
  ripgrep fd-find \
  xclip wl-clipboard \
  python3 python3-pip python3-venv \
  zsh fontconfig
ok "apt packages installed"

# Debian ships fd as 'fdfind'; Telescope expects 'fd'.
if have fdfind && ! have fd; then
  ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
  ok "linked fdfind -> fd"
fi

# ----------------------------------------------------------------------------
# 2. Neovim (>= 0.11 — required by the LSP config's vim.lsp.config/enable API)
# ----------------------------------------------------------------------------
install_neovim() {
  if have nvim && nvim --version | head -1 | grep -qE 'v0\.(1[1-9]|[2-9][0-9])'; then
    ok "neovim $(nvim --version | head -1) already present"
    return
  fi
  log "Installing latest stable Neovim"
  local tarball="nvim-linux-${NVIM_ARCH}.tar.gz"
  local url="https://github.com/neovim/neovim/releases/latest/download/${tarball}"
  local tmp; tmp="$(mktemp -d)"
  curl -fL "$url" -o "$tmp/$tarball"
  $SUDO rm -rf /opt/nvim
  $SUDO mkdir -p /opt/nvim
  $SUDO tar -xzf "$tmp/$tarball" -C /opt/nvim --strip-components=1
  $SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmp"
  ok "neovim $(nvim --version | head -1) installed"
}
install_neovim

# ----------------------------------------------------------------------------
# 3. Node.js via nvm (prettier/prettierd, pyright, ts-node, some Mason tools)
# ----------------------------------------------------------------------------
if ! skip NODE; then
  export NVM_DIR="${HOME}/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    log "Installing nvm"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  if ! have node; then
    log "Installing Node.js (${NODE_VERSION})"
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
  fi
  ok "node $(node --version 2>/dev/null || echo '?'), npm $(npm --version 2>/dev/null || echo '?')"
else
  warn "skipping Node.js"
fi

# ----------------------------------------------------------------------------
# 4. Rust via rustup (cargo, rustfmt, clippy, rust-analyzer)
# ----------------------------------------------------------------------------
if ! skip RUST; then
  if ! have rustup; then
    log "Installing Rust toolchain via rustup"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  # shellcheck disable=SC1091
  . "${HOME}/.cargo/env"
  rustup component add rustfmt clippy rust-analyzer 2>/dev/null || true
  ok "rust $(rustc --version 2>/dev/null || echo '?')"
else
  warn "skipping Rust"
fi

# ----------------------------------------------------------------------------
# 5. .NET SDK (omnisharp LSP + C# build/debug)
# ----------------------------------------------------------------------------
if ! skip DOTNET; then
  export DOTNET_ROOT="${HOME}/.dotnet"
  if ! have dotnet && [ ! -x "${DOTNET_ROOT}/dotnet" ]; then
    log "Installing .NET SDK (${DOTNET_CHANNEL})"
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
    bash /tmp/dotnet-install.sh --channel "$DOTNET_CHANNEL" --install-dir "$DOTNET_ROOT"
    rm -f /tmp/dotnet-install.sh
  fi
  export PATH="${DOTNET_ROOT}:$PATH"
  ok ".NET $(${DOTNET_ROOT}/dotnet --version 2>/dev/null || dotnet --version 2>/dev/null || echo '?')"
else
  warn "skipping .NET"
fi

# ----------------------------------------------------------------------------
# 6. Zellij (prebuilt musl binary)
# ----------------------------------------------------------------------------
if ! skip ZELLIJ; then
  if ! have zellij; then
    log "Installing Zellij"
    local_url="https://github.com/zellij-org/zellij/releases/latest/download/zellij-${ZELLIJ_ARCH}-unknown-linux-musl.tar.gz"
    tmp="$(mktemp -d)"
    curl -fL "$local_url" -o "$tmp/zellij.tar.gz"
    tar -xzf "$tmp/zellij.tar.gz" -C "$tmp"
    install -m755 "$tmp/zellij" "$LOCAL_BIN/zellij"
    rm -rf "$tmp"
  fi
  ok "zellij $(zellij --version 2>/dev/null || echo '?')"
else
  warn "skipping Zellij"
fi

# ----------------------------------------------------------------------------
# 7. lazygit (bound to <leader>tg in the config)
# ----------------------------------------------------------------------------
if ! have lazygit; then
  log "Installing lazygit"
  lg_ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+' || true)"
  if [ -n "${lg_ver:-}" ]; then
    tmp="$(mktemp -d)"
    curl -fL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lg_ver}_Linux_${LG_ARCH}.tar.gz" -o "$tmp/lazygit.tar.gz"
    tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp" lazygit
    install -m755 "$tmp/lazygit" "$LOCAL_BIN/lazygit"
    rm -rf "$tmp"
  else
    warn "could not resolve lazygit version; skipping"
  fi
fi
have lazygit && ok "lazygit $(lazygit --version 2>/dev/null | head -1 || echo '?')"

# ----------------------------------------------------------------------------
# 8. JetBrainsMono Nerd Font (config sets have_nerd_fonts = true)
# ----------------------------------------------------------------------------
if ! skip FONT; then
  if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    log "Installing JetBrainsMono Nerd Font ${NERD_FONT_VERSION}"
    mkdir -p "$FONT_DIR"
    tmp="$(mktemp -d)"
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/JetBrainsMono.zip" -o "$tmp/JetBrainsMono.zip"
    unzip -o -q "$tmp/JetBrainsMono.zip" -d "$FONT_DIR/JetBrainsMono"
    rm -rf "$tmp"
    fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
  fi
  ok "JetBrainsMono Nerd Font present (set it in your terminal profile)"
else
  warn "skipping font"
fi

# ----------------------------------------------------------------------------
# 9. starship prompt
# ----------------------------------------------------------------------------
if ! have starship; then
  log "Installing starship"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$LOCAL_BIN"
fi
ok "starship $(starship --version 2>/dev/null | head -1 || echo '?')"

# ----------------------------------------------------------------------------
# 10. Shell wiring: PATH, env, starship init, default shell
# ----------------------------------------------------------------------------
log "Wiring up shell rc files"
ZSHRC="${HOME}/.zshrc"
for rc in "$ZSHRC" "${HOME}/.bashrc"; do
  ensure_line 'export PATH="$HOME/.local/bin:$PATH"' "$rc"
  ensure_line '[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"' "$rc"
  ensure_line 'export DOTNET_ROOT="$HOME/.dotnet"' "$rc"
  ensure_line 'export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"' "$rc"
  ensure_line 'export NVM_DIR="$HOME/.nvm"' "$rc"
  ensure_line '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' "$rc"
done
# starship init is shell-specific
ensure_line 'eval "$(starship init zsh)"'  "$ZSHRC"
ensure_line 'eval "$(starship init bash)"' "${HOME}/.bashrc"

if ! skip ZSH; then
  zsh_path="$(command -v zsh)"
  if [ "${SHELL:-}" != "$zsh_path" ]; then
    log "Setting zsh as default shell (may prompt for your password)"
    if chsh -s "$zsh_path" 2>/dev/null; then
      ok "default shell set to zsh (effective on next login)"
    else
      warn "chsh failed; run manually:  chsh -s $zsh_path"
    fi
  fi
fi

# ----------------------------------------------------------------------------
# 11. Clone the Neovim config
# ----------------------------------------------------------------------------
NVIM_CFG="${HOME}/.config/nvim"
log "Installing Neovim config from ${NVIM_REPO} (branch ${NVIM_BRANCH})"
mkdir -p "${HOME}/.config"
if [ -d "$NVIM_CFG/.git" ]; then
  git -C "$NVIM_CFG" fetch --all --prune
  git -C "$NVIM_CFG" checkout "$NVIM_BRANCH"
  git -C "$NVIM_CFG" pull --ff-only || warn "could not fast-forward; leaving local state"
  ok "updated existing config"
else
  if [ -e "$NVIM_CFG" ]; then
    backup="${NVIM_CFG}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$NVIM_CFG" "$backup"
    warn "existing config moved to $backup"
  fi
  git clone --branch "$NVIM_BRANCH" "$NVIM_REPO" "$NVIM_CFG"
  ok "config cloned"
fi

# ----------------------------------------------------------------------------
# 12. Headless plugin / LSP / formatter / debugger install
# ----------------------------------------------------------------------------
if ! skip NVIM_SYNC; then
  log "Syncing plugins (lazy.nvim) — first run compiles Treesitter parsers, be patient"
  nvim --headless "+Lazy! sync" +qa || warn "Lazy sync reported issues (often fine on first run)"

  log "Installing Mason tools not covered by ensure_installed"
  # LSPs (lua_ls, ruff, omnisharp, pyright, taplo) auto-install via mason-lspconfig.
  # These formatters/debuggers are referenced by conform.nvim / nvim-dap and must
  # be installed explicitly:
  nvim --headless "+MasonInstall stylua debugpy netcoredbg codelldb" +qa \
    || warn "some Mason tools failed; open nvim and run :Mason to retry"

  log "Updating Treesitter parsers"
  nvim --headless "+TSUpdateSync" +qa || warn "TSUpdate reported issues"
else
  warn "skipping headless nvim sync"
fi

# ----------------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------------
printf "\n${c_green}Bootstrap complete.${c_off}\n"
cat <<'EOF'

Next steps:
  1. Open a new terminal (or run: exec zsh) to pick up PATH + starship.
  2. Set your terminal font to "JetBrainsMono Nerd Font".
  3. Launch: nvim   (run :checkhealth to confirm providers/tools).
  4. Python testing/debugging: install pytest + debugpy inside each project's
     venv (this config resolves the interpreter per-project).

Notes:
  - vim-tmux-navigator is a tmux plugin and won't integrate with Zellij; harmless.
  - The config references a conda path (/data/miniconda3); optional, it falls
    back to system python3 automatically.
EOF
