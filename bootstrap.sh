#!/usr/bin/env bash
# Set up a fresh Apple Silicon Mac from a clone of this repo:
#   Command Line Tools -> Homebrew -> SSH key -> chezmoi apply -> login shell.
# Homebrew only installs mise; chezmoi itself runs through mise.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Re-run this script once the Command Line Tools finish installing."
  exit 1
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

new_key() { # new_key <file> <label>
  [[ -f $1 ]] && return
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  ssh-keygen -t ed25519 -f "$1" -C "$2 $(whoami)@$(hostname -s)"
  ssh-add --apple-use-keychain "$1"
}
# The personal key exists before chezmoi runs so git's allowed_signers file
# can include it.
new_key ~/.ssh/id_ed25519 personal

# The repo is cloned over HTTPS because the key above isn't on GitHub yet;
# pushes go over SSH once it is.
origin=$(git -C "$src" remote get-url origin)
if [[ $origin == https://github.com/* ]]; then
  git -C "$src" remote set-url origin "git@github.com:${origin#https://github.com/}"
fi

# Commit messages are checked by the repo's own hook (Conventional Commits).
git -C "$src" config core.hooksPath .githooks

brew install mise
chezmoi() { mise exec chezmoi@latest -- chezmoi "$@"; }
chezmoi init --apply --source "$src"

# A work identity (a work email was given) gets its own key, since GitHub
# tells accounts apart by key; applying again adds it to allowed_signers.
work_email=$(chezmoi execute-template '{{ .workEmail }}')
if [[ -n $work_email && ! -f ~/.ssh/id_ed25519_work ]]; then
  new_key ~/.ssh/id_ed25519_work work
  chezmoi apply
fi

brew_bash="$HOMEBREW_PREFIX/bin/bash"
if ! grep -qxF "$brew_bash" /etc/shells; then
  echo "$brew_bash" | sudo tee -a /etc/shells >/dev/null
fi
if [[ $(dscl . -read ~ UserShell | awk '{print $2}') != "$brew_bash" ]]; then
  chsh -s "$brew_bash"
fi

# Plugins at the versions in lazy-lock.json (language servers were installed
# by mise during chezmoi apply).
mise exec -- nvim --headless "+Lazy! restore" +qa

cat <<DONE

Done. Remaining manual steps:
  1. On your personal GitHub account, add ~/.ssh/id_ed25519.pub twice, once
     as an Authentication key and once as a Signing key:
     https://github.com/settings/keys
DONE
if [[ -n $work_email ]]; then
  cat <<DONE
     Add ~/.ssh/id_ed25519_work.pub to your work account on $(chezmoi execute-template '{{ .workHost }}')
     the same way (for signing, if the host supports SSH signatures).
DONE
fi
cat <<DONE
     Commits show as Verified only if each email you gave chezmoi is a
     verified email (or the noreply address) on its account.
  2. Open Ghostty.
  3. Sign in to Claude Code: claude auth login
DONE
