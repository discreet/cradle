# bash-completion@2 loads each command's completion on first Tab, from
# Homebrew's prefix and from ~/.local/share/bash-completion/completions, where
# chezmoi writes completions for git and mise's tools
# (run_onchange_after_25-completions.sh).
if [[ -r $HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh ]]; then
  source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

command -v aws_completer >/dev/null && complete -C aws_completer aws

# Also key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd. Ctrl-T lists
# files with ripgrep so .gitignore is respected; Alt-C uses fzf's own walker.
if command -v fzf >/dev/null; then
  export FZF_CTRL_T_COMMAND="rg --files --hidden --glob '!.git'"
  eval "$(fzf --bash)"
fi
