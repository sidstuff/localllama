set -e
cat > /var/lib/dietpi/dietpi-autostart/custom.sh << 'EOF'
sudo mount --mkdir /dev/mmcblk0p2 /mnt/models
for url in https://github.com/regclient/regclient/releases/latest/download/regctl-linux-arm64 \
https://raw.githubusercontent.com/mag37/dockcheck/HEAD/dockcheck.sh; do \
wget -N --no-if-modified-since -P ~/.local/bin $url; done
dockcheck.sh -aFp
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
healthCheckTimeout: 600
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
    volumes: /mnt/models:/models:ro
    ports: 9931:9931
    image: ghcr.io/anbeeld/beellama.cpp:server-cpu
    command: --cpu-range 4-7 --cpu-strict 1 --prio 2 --prio-batch 2 --spec-drft-prio 2 --spec-draft-prio-batch 2
    environment:
      - LLAMA_ARG_MODEL=/models/Qwen4-Flash-UD-IQ1_S.gguf
      - LLAMA_ARG_SPEC_DRAFT_MODEL=/models/Qwen4-Flash-DFlash2-Q4_K_M.gguf
      - LLAMA_ARG_THREADS=4
      - LLAMA_ARG_BATCH=512
      - LLAMA_ARG_UBATCH=128
      - LLAMA_ARG_SWA_FULL=true
      - LLAMA_ARG_FLASH_ATTN=on
      - LLAMA_ARG_KV_TAIL_TOKENS=1024
      - LLAMA_ARG_KV_TAIL_TYPE=q8_0
      - LLAMA_ARG_CACHE_TYPE_K=kvarn5
      - LLAMA_ARG_CACHE_TYPE_V=kvarn4
      - LLAMA_ARG_LOAD_MODE=mlock
      - LLAMA_ARG_N_GPU_LAYERS=0
      - LLAMA_ARG_SPLIT_MODE=none
      - LLAMA_ARG_TEMPERATURE=1.0
      - LLAMA_ARG_TOP_K=20
      - LLAMA_ARG_TOP_P=0.95
      - LLAMA_ARG_MIN_P=0.0
      - LLAMA_ARG_REPEAT_PENALTY=1.0
      - LLAMA_ARG_PRESENCE_PENALTY=0.0
      - LLAMA_ARG_SPEC_TYPE=draft-dflash,ngram-map-k4v
      - LLAMA_ARG_SPEC_DRAFT_N_MAX=5
      - LLAMA_ARG_SPEC_DRAFT_TYPE_K=q4_0
      - LLAMA_ARG_SPEC_DRAFT_TYPE_V=q4_0
      - LLAMA_ARG_N_GPU_LAYERS_DRAFT=0
      - LLAMA_ARG_KV_UNIFIED=true
      - LLAMA_ARG_CACHE_RAM=0
      - LLAMA_ARG_CACHE_IDLE_SLOTS=0
      - LLAMA_ARG_N_PARALLEL=1
      - LLAMA_ARG_UI=0
      - LLAMA_ARG_REASONING=on
      - LLAMA_ARG_REASONING_EFFORT=xhigh
      - LLAMA_ARG_THINK=deepseek
EOF
