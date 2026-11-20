set -e
cat > /var/lib/dietpi/dietpi-autostart/custom.sh << 'EOF'
mount --mkdir /dev/mmcblk0p2 /mnt/models
for url in https://github.com/regclient/regclient/releases/latest/download/regctl-linux-arm64 \
https://raw.githubusercontent.com/mag37/dockcheck/HEAD/dockcheck.sh; do \
wget -N --no-if-modified-since -P ~/.local/bin $url; done
dockcheck -aFp
brew upgrade
brew cleanup --prune=all
pkill llama-swap
llama-swap --config ~/.config/llama-swap.yaml --watch-config
EOF
chmod 755 /var/lib/dietpi/dietpi-autostart/custom.sh
usermod -aG sudo dietpi
echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd
su - dietpi
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap mostlygeek/llama-swap
brew install llama-swap
cd ~/.local/bin
ln -s regctl-linux-arm64 regctl
cat > ~/.config/llama-swap.yaml << 'EOF'
healthCheckTimeout: 300
sendLoadingState: true
models:
  qwen4:
    cmd: docker compose up
  update:
    cmd: sh /var/lib/dietpi/dietpi-autostart/custom.sh
EOF
cat > ~/compose.yaml << 'EOF'
services:
  qwen4:
    image: ghcr.io/anbeeld/beellama.cpp:server-cpu
    environment:
      - LLAMA_ARG_N_GPU_LAYERS=999
      - LLAMA_ARG_MODEL=/models/phi-4.Q4_K_M.gguf
    ports:
      - "9931:9931"
    volumes:
      - /mnt/models:/models
EOF
