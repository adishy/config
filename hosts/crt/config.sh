sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo systemctl enable --now tailscaled
# Currently unused but may be useful later..
echo 'TS_PERMIT_CERT_UID=1000' | sudo tee -a /etc/default/tailscaled
sudo systemctl restart tailscaled

./crt.graphics-config.sh
./setup_das.sh
