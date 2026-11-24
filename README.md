# My LocalLLaMa Setup

… so i can ssh into my rpi 4b to a nix shell containing python3 and deno then run dspy.rlm, with an api served from my nanopi m6 running llama-swap managed llama.cpp containers and dockcheck on dietpi

## NanoPi M6

```sh
wget https://dietpi.com/downloads/images/DietPi_NanoPiM6-ARMv8-Trixie.img.xz
xz -d DietPi_NanoPiM6-ARMv8-Trixie.img.xz
dd bs=4M if=DietPi_NanoPiM6-ARMv8-Trixie.img of=/dev/sda conv=fsync oflag=direct status=progress
mount --mkdir /dev/sda2 /mnt/dietpisetup
wget -qO- https://raw.githubusercontent.com/sidstuff/localllama/HEAD/dietpi.override | while IFS= read -r line
do sed -i "s|^#\\?${line%%=*}=.*|$line|" /mnt/dietpisetup/dietpi.txt; done
umount /dev/sda2
echo "start=64G" | sfdisk --append /dev/sda
mkfs.f2fs -s 2 -i -O extra_attr,inode_checksum,sb_checksum /dev/sda3
mount --mkdir /dev/sda3 /mnt/gguf
```
