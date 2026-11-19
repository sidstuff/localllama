set -e
usermod -aG sudo dietpi
echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopasswd
su - dietpi
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap mostlygeek/llama-swap
brew install llama-swap
wget -O regctl https://github.com/regclient/regclient/releases/latest/download/regctl-linux-arm64
wget https://raw.githubusercontent.com/mag37/dockcheck/main/dockcheck.sh
install -m 755 regctl dockcheck.sh ~/.local/bin
printf "AutoMode=true\nAutoPrune=true\nAutoSelfUpdate=true\nOnlySpecific=true\n" > ~/.config/dockcheck.config
cat > ~/.config/llama-swap.yaml << 'EOF'
models:
  qwen4:
    cmd: docker compose up
  update:
    cmd: dockcheck -aFpu && brew upgrade && brew cleanup --prune=all && pkill -SIGTERM llama-swap && llama-swap --config ~/.config/llama-swap.yaml
EOF
