sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo systemctl enable --now tailscaled
#tailscale serve --bg 8096

echo 'TS_PERMIT_CERT_UID=1000' | sudo tee -a /etc/default/tailscaled
sudo systemctl restart tailscaled
