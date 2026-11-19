set -e
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
    cmd: dockcheck -aFpu && brew upgrade && brew cleanup --prune=all && pkill -SIGTERM llama-swap && llama-swap --config ~/.config/llama-swap.yaml
EOF
printf "AutoMode=true\nAutoPrune=true\nOnlySpecific=true\n" > ~/.config/dockcheck.config
cat > /var/lib/dietpi/dietpi-autostart/custom.sh << 'EOF'
for url in https://github.com/regclient/regclient/releases/latest/download/regctl-linux-arm64 \
https://raw.githubusercontent.com/mag37/dockcheck/HEAD/dockcheck.sh; do \
wget -N --no-if-modified-since -P ~/.local/bin $url; done
dockcheck
brew upgrade
brew cleanup --prune=all
pkill llama-swap
llama-swap --config ~/.config/llama-swap.yaml --watch-config
EOF
