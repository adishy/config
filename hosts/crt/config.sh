sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo systemctl enable --now tailscaled
tailscale serve --bg 8096
