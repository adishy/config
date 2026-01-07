# 1. Install NVIDIA toolkit and Docker
sudo apt update && sudo apt install -y nvidia-container-toolkit docker.io

# 2. Add your user to the docker group (requires logout/login to apply)
sudo usermod -aG docker $USER

# 3. Configure Docker to use the NVIDIA runtime and restart
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
