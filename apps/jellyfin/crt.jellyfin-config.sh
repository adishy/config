#!/bin/bash

################################################################################
# JELLYFIN NVIDIA SETUP FOR POP!_OS 24.04 LTS (MX250 / PASCAL)
# ------------------------------------------------------------------------------
# 1. Driver: Proprietary 550+ (Non-open) to support Pascal architecture.
# 2. GSP Fix: Disabled GSP Firmware to allow MX250 chip initialization.
# 3. Docker: Pinned NVIDIA repo priority (1002) to fix "package not found".
################################################################################

# 1. CLEANING & REINSTALLING DRIVERS
echo "Cleaning old drivers..."
sudo apt purge -y ~nnvidia
sudo apt autoremove -y
sudo apt update
sudo apt install -y system76-driver-nvidia linux-headers-$(uname -r)

# 2. INSTALLING TOOLS
echo "Installing monitoring tools (nvtop, fastfetch)..."
sudo apt install -y nvtop fastfetch mesa-utils dkms

# 3. FIXING MX250 GSP INITIALIZATION
echo "Applying GSP Firmware fix for MX250..."
echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee /etc/modprobe.d/nvidia.conf
sudo update-initramfs -u

# 4. REPO PINNING & TOOLKIT INSTALL
echo "Pinning NVIDIA repository and installing toolkit..."
sudo tee /etc/apt/preferences.d/nvidia-docker-pin-1002 <<EOF
Package: *
Pin: origin nvidia.github.io
Pin-Priority: 1002
EOF

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

# 5. DOCKER RUNTIME REGISTRATION
echo "Registering NVIDIA runtime with Docker..."
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# 6. DIRECTORY PERMISSIONS
echo "Setting up local folder permissions for Jellyfin..."
mkdir -p config cache
sudo chown -R 1000:1000 config cache
chmod -R 775 config cache

echo "----------------------------------------------------------------"
echo "SETUP COMPLETE!"
echo "1. REBOOT NOW."
echo "2. Run 'nvidia-smi' to check the driver."
echo "3. Run 'docker compose up -d' in your Jellyfin folder."
echo "----------------------------------------------------------------"
