
# Node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Go
export PATH=$PATH:/$HOME/.go/bin

# Python

#uv
source $HOME/.local/bin/env

# Fingerprint
alias fpservicebounce="sudo systemctl restart open-fprintd python3-validity"

# Bitwarden
alias bw="flatpak run --command=bw com.bitwarden.desktop"
