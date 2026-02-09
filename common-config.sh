git config --global user.email "development-mails@adishy.com"
git config --global user.name "Aditya Shylesh"

# Push the current branch to a branch of the same name by default
git config --global push.default current

# Automatically set up "upstream" tracking on the first push
git config --global push.autoSetupRemote true

sudo tailscale set --operator=$USER
