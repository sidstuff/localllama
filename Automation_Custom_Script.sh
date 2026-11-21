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
    volumes: /mnt/models:/models:ro
    ports: 9931:9931
    image: ghcr.io/anbeeld/beellama.cpp:server-cpu
    environment:
      - LLAMA_ARG_MODEL=C:\Users\Owner\Desktop\LocalLLaMa\huihui-ai\Huihui-Qwen3.8-27B-abliterated-GSQ-RCO-IQ3_XXS.gguf
      - LLAMA_ARG_MODEL_DRAFT=C:\Users\Owner\Desktop\LocalLLaMa\HermiHg\Qwen3.8-27B-DFlash2-Q2_K_S-MIX.gguf
      - LLAMA_ARG_MMPROJ=C:\Users\Owner\Desktop\LocalLLaMa\HermiHg\mmproj-Qwen3.8-27B-Q5_K-MIX.gguf
      - LLAMA_ARG_CHAT_TEMPLATE_FILE=C:\Users\Owner\Desktop\LocalLLaMa\peculiar-ragdoll\chat_template.jinja
      - LLAMA_ARG_THREADS=4
      - LLAMA_ARG_CPU_RANGE=4-7
      - LLAMA_ARG_CPU_STRICT=1
      - LLAMA_ARG_PRIO=2
      - LLAMA_ARG_PRIO_BATCH=2
      - LLAMA_ARG_BATCH_SIZE=512
      - LLAMA_ARG_UBATCH_SIZE=128
      - LLAMA_ARG_SWA_FULL
      - LLAMA_ARG_FLASH_ATTN=on
      - LLAMA_ARG_KV_TAIL_TOKENS=1024
      - LLAMA_ARG_CACHE_TYPE_K=kvarn5
      - LLAMA_ARG_CACHE_TYPE_V=kvarn4
      - LLAMA_ARG_LOAD_MODE=mlock
      - LLAMA_ARG_GPU_LAYERS=all
      - LLAMA_ARG_FIT
      - LLAMA_ARG_SPLIT_MODE=none
      - LLAMA_ARG_TEMP=1.0
      - LLAMA_ARG_TOP_K=20
      - LLAMA_ARG_TOP_P=0.95
      - LLAMA_ARG_MIN_P=0.0
      - LLAMA_ARG_REPEAT_PENALTY=1.0
      - LLAMA_ARG_PRESENCE_PENALTY=0.0
      - LLAMA_ARG_SPEC_TYPE=draft-dflash,ngram-map-k4v
      - LLAMA_ARG_SPEC_DRAFT_PRIO=2
      - LLAMA_ARG_SPEC_DRAFT_PRIO_BATCH=2
      - LLAMA_ARG_SPEC_DRAFT_N_MAX=5
      - LLAMA_ARG_SPEC_DRAFT_TYPE_K=q4_0
      - LLAMA_ARG_SPEC_DRAFT_TYPE_V=q4_0
      - LLAMA_ARG_SPEC_DRAFT_NGL=all
      - LLAMA_ARG_KV_UNIFIED
      - LLAMA_ARG_CACHE_RAM=0
      - LLAMA_ARG_NO_CACHE_IDLE_SLOTS
      - LLAMA_ARG_PARALLEL=1
      - LLAMA_ARG_NO_MMPROJ_OFFLOAD
      - LLAMA_ARG_IMAGE_MIN_TOKENS=1024
      - LLAMA_ARG_NO_WEBUI
      - LLAMA_ARG_API_KEY=foo
      - LLAMA_ARG_REASONING=on
      - LLAMA_ARG_REASONING_FORMAT=deepseek
      - LLAMA_ARG_REASONING_EFFORT=xhigh
EOF
