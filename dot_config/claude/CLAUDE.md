# This Mac

This Mac's setup (command-line tools, apps, dotfiles, macOS settings and
Claude Code's own settings) is managed by chezmoi from the cradle repo, at
`chezmoi source-path` (normally `~/Documents/cradle`).

When asked to install, update, change or remove anything about this machine's
setup, from any folder, read that repo's CLAUDE.md and make the change there.
Don't edit the managed files in `~` directly, and don't install tools
globally with `brew install`, `npm install -g`, `pip install`, `uv tool
install` or `go install`; they belong in the repo's mise config or Brewfile.
Project dependencies inside a project are fine.
