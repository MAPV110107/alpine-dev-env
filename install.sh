#!/bin/sh
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
setup-apkrepos -1
sed -i 's/#//g' /etc/apk/repositories
echo "$(cat /etc/apk/repositories | grep main | head -n 1 | sed 's/main/community/')" >> /etc/apk/repositories
apk update

apk add util-linux lvm2 device-mapper exfatprogs fuse-exfat docker docker-cli-compose neovim git curl wget w3m gcc g++ musl-dev make nodejs npm ripgrep fd build-base python3 bash sqlite tor neomutt aria2 android-tools tmux htop ncdu jq fzf unzip gcompat openssh

echo "root:alpine" | chpasswd
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rc-service sshd start
rc-update add sshd boot

rc-service docker start
rc-update add docker boot

mkdir -p ~/.config ~/.local/share ~/.local/state ~/.cache ~/workspace

if grep -qs '/mnt/ventoy' /proc/mounts; then
  mkdir -p /mnt/ventoy/.nvim/config /mnt/ventoy/.nvim/share /mnt/ventoy/.nvim/state /mnt/ventoy/.nvim/cache /mnt/ventoy/workspace
  
  if [ -f "./config/nvim/init.lua" ]; then
    cp -a ./config/nvim/. /mnt/ventoy/.nvim/config/ 2>/dev/null
  else
    rm -rf /mnt/ventoy/.nvim/config
    git clone https://github.com/LazyVim/starter /mnt/ventoy/.nvim/config
    rm -rf /mnt/ventoy/.nvim/config/.git
  fi
  
  rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/workspace
  ln -s /mnt/ventoy/.nvim/config ~/.config/nvim
  ln -s /mnt/ventoy/.nvim/share ~/.local/share/nvim
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

npm install -g localtunnel
docker compose up -d

QRCP_URL=$(curl -s https://api.github.com/repos/claudiodangelis/qrcp/releases/latest | jq -r '.assets[] | select(.name | contains("linux_x86_64.tar.gz")) | .browser_download_url' | head -n 1)
curl -L "$QRCP_URL" -o qrcp.tar.gz
tar -xzf qrcp.tar.gz -C /usr/local/bin qrcp
rm qrcp.tar.gz

mkdir -p /opt/obscura
OBSCURA_URL=$(curl -s https://api.github.com/repos/h4ckf0r0day/obscura/releases/latest | jq -r '.assets[] | select(.name | contains("linux")) | select(.name | contains("x86_64")) | .browser_download_url' | head -n 1)
curl -L "$OBSCURA_URL" -o obscura.tar.gz
tar -xzf obscura.tar.gz -C /opt/obscura
ln -s /opt/obscura/obscura /usr/local/bin/obscura
rm obscura.tar.gz