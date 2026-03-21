#!/usr/bin/env bash
# Bootstrap a bare CUDA kubernetes pod with dev tools.
# Usage: curl -fsSL https://raw.githubusercontent.com/linyuhongg/dotfiles/main/setup-k8s-pod.sh | bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: run as root (apt-get needs it)." >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# ─── System packages (~2 min) ────────────────────────────────────
apt-get update
apt-get install -y --no-install-recommends \
    build-essential ccache cmake curl git jq \
    libnuma-dev libopenmpi-dev libprotobuf-dev libssl-dev libzmq3-dev \
    ninja-build openmpi-bin pkg-config protobuf-compiler ripgrep \
    software-properties-common tmux wget zsh \
    ca-certificates gnupg python3 python3-dev python3-pip python3-venv
rm -rf /var/lib/apt/lists/*

# ─── Node.js + Claude Code ───────────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs
    rm -rf /var/lib/apt/lists/*
fi
npm install -g @anthropic-ai/claude-code

# ─── Dotfiles ────────────────────────────────────────────────────
git clone https://github.com/linyuhongg/dotfiles.git ~/dotfiles
mkdir -p ~/.config
ln -s ~/dotfiles/nvim ~/.config/nvim

# ─── Zsh ─────────────────────────────────────────────────────────
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

rm -f ~/.zshrc
ln -s ~/dotfiles/zshrc ~/.zshrc
chsh -s /usr/bin/zsh 2>/dev/null || true

# ─── Tmux ────────────────────────────────────────────────────────
git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
~/.tmux/plugins/tpm/bin/install_plugins

# ─── Neovim (pre-built binary → /usr/local, already on PATH) ─────
curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1
rm nvim-linux-x86_64.tar.gz

# ─── uv (Python package manager) ─────────────────────────────────
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "Done. Run: zsh && tmux new -s dev"
