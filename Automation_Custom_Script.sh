set -e
cat > /var/lib/dietpi/dietpi-autostart/custom.sh << 'EOF'
sudo mount --mkdir /dev/mmcblk0p2 /mnt/gguf
if pgrep llama-swap && brew update && brew outdated && brew upgrade && pkill llama-swap || ! pgrep llama-swap
then docker stop $(docker ps -q); llama-swap --config ~/.config/llama-swap.yaml & brew cleanup --prune=all; fi
for url in https://github.com/regclient/regclient/releases/latest/download/regctl-linux-arm64 \
https://raw.githubusercontent.com/mag37/dockcheck/HEAD/dockcheck.sh
do wget -N --no-if-modified-since -P ~/.local/bin $url; done
dockcheck.sh -aFp
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
  update:
    cmd: sh /var/lib/dietpi/dietpi-autostart/custom.sh
  inkling:
    cmd: >
      docker run --rm -v /mnt/gguf:/gguf:ro -p ${PORT}:9931 ghcr.io/ggml-org/beellama.cpp:server
      --lora /gguf/Inkling-2-Mini-Unbound-LoRA-r16.gguf -Cr 4-7 --cpu-strict 1
    env:
      - LLAMA_ARG_MODEL=/gguf/Inkling-2-Mini-UD-IQ4_XS.gguf
      - LLAMA_ARG_SPEC_DRAFT_MODEL=/gguf/dspark-Inkling-2-Mini-Q8_0.gguf
      - LLAMA_ARG_MMPROJ=/gguf/mmproj-Inkling-2-Mini-F16.gguf
      - LLAMA_ARG_THREADS=4
      - LLAMA_ARG_BATCH=512
      - LLAMA_ARG_UBATCH=128
      - LLAMA_ARG_SWA_FULL=true
      - LLAMA_ARG_LOAD_MODE=mlock
      - LLAMA_ARG_TEMPERATURE=1.0
      - LLAMA_ARG_TOP_K=0
      - LLAMA_ARG_TOP_P=1.0
      - LLAMA_ARG_MIN_P=0.0
      - LLAMA_ARG_SPEC_TYPE=draft-dspark,ngram-map-k4v
      - LLAMA_ARG_SPEC_DRAFT_N_MAX=3
      - LLAMA_ARG_KV_UNIFIED=true
      - LLAMA_ARG_CACHE_RAM=0
      - LLAMA_ARG_CACHE_IDLE_SLOTS=0
      - LLAMA_ARG_N_PARALLEL=1
      - LLAMA_ARG_UI=0
EOF
