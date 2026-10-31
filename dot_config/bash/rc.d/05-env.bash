# The Command Line Tools' own bin ahead of /usr/bin, whose git, clang, make
# etc. are launchers that look the tools up on every call (git: ~23 ms vs
# ~9 ms, and the prompt runs git several times).
export PATH="$HOME/.local/bin:/Library/Developer/CommandLineTools/usr/bin:$PATH"

export EDITOR=nvim
export VISUAL=$EDITOR

export CLICOLOR=1
# Quit if one screen, keep colours, smart-case search.
export LESS=-FRi
export INPUTRC="$HOME/.config/readline/inputrc"
# Keeps ~/.claude and ~/.claude.json under ~/.config/claude instead.
export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
# `go install` puts binaries on PATH. (GOPATH is set in mise's config; GOBIN
# isn't, or mise's own go: installs would land here too.)
export GOBIN="$HOME/.local/bin"

shopt -s globstar histappend checkwinsize
stty -ixon

export HISTSIZE=10000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT='%F %T '
# Save each command as it runs (other shells see it when they start). The
# exit status is captured first for the prompt; mise adds its own hook later.
PROMPT_COMMAND="__prompt_status=\$?; history -a"
