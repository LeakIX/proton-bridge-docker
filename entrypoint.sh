#!/bin/bash
set -euo pipefail

# Initialize GPG key and pass store on first run.
# Bridge requires a keychain; pass + gpg provides one
# without X11 or gnome-keyring.
if [ ! -f "$HOME/.gnupg/trustdb.gpg" ]; then
    echo "Initializing GPG key for Bridge keychain..."
    gpg --batch --passphrase '' \
        --quick-gen-key 'ProtonMail Bridge' default default never
fi

if [ ! -d "$HOME/.password-store" ] || \
   [ -z "$(ls -A "$HOME/.password-store" 2>/dev/null)" ]; then
    echo "Initializing pass store..."
    GPG_ID=$(gpg --list-keys --with-colons 2>/dev/null \
        | grep '^pub' | head -1 | cut -d: -f5)
    pass init "$GPG_ID"
fi

exec proton-bridge "$@"
