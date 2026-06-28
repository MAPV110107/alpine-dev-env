#!/bin/sh

echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
setup-apkrepos -1
sed -i 's/#//g' /etc/apk/repositories
echo "$(cat /etc/apk/repositories | grep main | head -n 1 | sed 's/main/community/')" >> /etc/apk/repositories
apk update

apk add \
  util-linux lvm2 device-mapper exfatprogs fuse-exfat gcompat openssh e2fsprogs \
  neovim tree-sitter tree-sitter-cli lua-language-server \
  git lazygit github-cli \
  python3 py3-pip py3-virtualenv pipx ruff black \
  nodejs npm rust cargo build-base \
  curl wget rsync tar unzip sqlite yq jq \
  bat eza zoxide starship fzf ripgrep fd tree less \
  btop ncdu strace lsof mtr htop tmux bash \
  gnupg pass age android-tools \
  docker docker-cli-compose

echo "root:root" | chpasswd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rc-service sshd start
rc-update add sshd boot

mkdir -p ~/.config ~/.local/share ~/.local/state ~/.cache ~/workspace

if grep -qs '/mnt/ventoy' /proc/mounts; then
  mkdir -p /mnt/ventoy/.nvim/config /mnt/ventoy/.nvim/state /mnt/ventoy/.nvim/cache /mnt/ventoy/workspace
  
  if [ ! -f "/mnt/ventoy/.nvim/config/init.lua" ]; then
    if [ -f "./config/nvim/init.lua" ]; then
      cp -a ./config/nvim/. /mnt/ventoy/.nvim/config/ 2>/dev/null
    else
      git clone https://github.com/LazyVim/starter /mnt/ventoy/.nvim/config
      rm -rf /mnt/ventoy/.nvim/config/.git
    fi
  fi
  
  if [ ! -f "/mnt/ventoy/kattze_nvim_share.img" ]; then
    dd if=/dev/zero of=/mnt/ventoy/kattze_nvim_share.img bs=1M count=2048 status=none
    mkfs.ext4 -q /mnt/ventoy/kattze_nvim_share.img
  fi
  
  rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/workspace
  mkdir -p ~/.local/share/nvim
  
  mount -o loop /mnt/ventoy/kattze_nvim_share.img ~/.local/share/nvim
  
  ln -s /mnt/ventoy/.nvim/config ~/.config/nvim
  ln -s /mnt/ventoy/.nvim/state ~/.local/state/nvim
  ln -s /mnt/ventoy/.nvim/cache ~/.cache/nvim
  ln -s /mnt/ventoy/workspace ~/workspace
else
  if [ -f "./config/nvim/init.lua" ]; then
    cp -r ./config/nvim ~/.config/
  else
    rm -rf ~/.config/nvim
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
  fi
fi

npm install -g localtunnel serve

QRCP_URL=$(curl -s https://api.github.com/repos/claudiodangelis/qrcp/releases/latest | jq -r '.assets[]? | select(.name | contains("linux_x86_64.tar.gz")) | .browser_download_url' | head -n 1)

if [ -n "$QRCP_URL" ] && [ "$QRCP_URL" != "null" ]; then
  curl -L "$QRCP_URL" -o qrcp.tar.gz
  tar -xzf qrcp.tar.gz -C /usr/local/bin qrcp
  rm qrcp.tar.gz
fi