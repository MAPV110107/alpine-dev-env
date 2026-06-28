#!/bin/sh

USB_MOUNT="/mnt/ventoy"
CACHE_DIR="$USB_MOUNT/kattze_cache"
NVIM_IMG="$USB_MOUNT/kattze_nvim_share.img"

echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
setup-apkrepos -1
sed -i 's/#//g' /etc/apk/repositories
echo "$(cat /etc/apk/repositories | grep main | head -n 1 | sed 's/main/community/')" >> /etc/apk/repositories

if grep -qs "$USB_MOUNT" /proc/mounts; then
  mkdir -p "$USB_MOUNT/.nvim/config" "$USB_MOUNT/.nvim/state" "$USB_MOUNT/.nvim/cache"
  mkdir -p "$USB_MOUNT/workspace"
  mkdir -p "$CACHE_DIR/apk" "$CACHE_DIR/npm-global"

  rm -rf /etc/apk/cache
  ln -s "$CACHE_DIR/apk" /etc/apk/cache
  
  if [ ! -f "$NVIM_IMG" ]; then
    apk add --quiet e2fsprogs
    dd if=/dev/zero of="$NVIM_IMG" bs=1M count=2048 status=none
    mkfs.ext4 -q "$NVIM_IMG"
  fi
fi

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

if grep -qs "$USB_MOUNT" /proc/mounts; then
  rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/workspace
  mkdir -p ~/.local/share/nvim
  mount -o loop "$NVIM_IMG" ~/.local/share/nvim
  
  ln -s "$USB_MOUNT/.nvim/config" ~/.config/nvim
  ln -s "$USB_MOUNT/.nvim/state" ~/.local/state/nvim
  ln -s "$USB_MOUNT/.nvim/cache" ~/.cache/nvim
  ln -s "$USB_MOUNT/workspace" ~/workspace

  npm config set prefix "$CACHE_DIR/npm-global"
  echo "export PATH=$CACHE_DIR/npm-global/bin:\$PATH" >> ~/.bashrc
  echo "export PATH=$CACHE_DIR/npm-global/bin:\$PATH" >> ~/.profile
  export PATH=$CACHE_DIR/npm-global/bin:$PATH
fi

if ! command -v serve &> /dev/null; then
  npm install -g localtunnel serve
fi

echo "root:kattze" | chpasswd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rc-service sshd start
rc-update add sshd boot