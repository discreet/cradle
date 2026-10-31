# cradle

Configuration for an Apple Silicon Mac, built on three tools:

- [chezmoi](https://chezmoi.io) applies dotfiles from this repo, filling in
  per-machine values (name, email, signing key) through templates.
- [mise](https://mise.jdx.dev) installs every command-line tool: languages,
  Neovim, tmux, kubectl, Claude Code and the rest
  ([config](dot_config/mise/config.toml)).
- A [Brewfile](Brewfile) covers only what mise can't: bash (the login shell),
  bash-completion, mise itself, and GUI apps. git is Apple's, from the Command
  Line Tools.

## New machine

```sh
git clone https://github.com/discreet/cradle.git ~/.local/share/chezmoi
~/.local/share/chezmoi/bootstrap.sh
```

On a fresh Mac, `git` first offers to install the Command Line Tools; run the
clone again once they finish. The clone uses HTTPS because the machine has no
SSH key on GitHub yet (for a private repo, git asks for your GitHub username
and a personal access token). The repo can live anywhere; chezmoi remembers
where.

The bootstrap script installs Homebrew and mise, creates an SSH key if there
isn't one, switches the clone's remote to SSH, turns on the repo's commit
message hook, and runs `chezmoi init --apply`
through mise. chezmoi asks once for your name, your personal git email (your
GitHub noreply address keeps it private) and, if the machine is also used for
work, a work email, the work git host (GitHub, GitLab or any other) and,
optionally, the orgs or groups on it that are work. With a work identity, the script
also creates a separate work SSH key. It then
installs the Brewfile, writes the dotfiles, runs `mise install` and loads the
LaunchAgents. Finally the script makes Homebrew's bash your login shell and
installs Neovim's plugins at the versions in `lazy-lock.json`. It ends by
listing the manual steps left: adding the key to GitHub, and signing in to
Claude Code.

## Managed with Claude Code

After the first setup, changes are made by asking Claude Code, from any
folder: "add jq", "update everything", "change the tmux status bar". A global
instruction (`dot_config/claude/CLAUDE.md`) sends it to this repo, and
[CLAUDE.md](CLAUDE.md) tells it how to work here: where each kind of change
goes, the decisions already made, how to test without touching the machine,
and the update routine.

For each change, Claude edits this repo and runs `scripts/check`. It then
summarises `chezmoi diff` and runs `chezmoi apply`, which always asks you
first: that's your one checkpoint. After the apply it commits and pushes on
its own. Commits follow Conventional Commits (checked by `.githooks/commit-msg`)
and are signed; releases are annotated, signed SemVer tags (`v1.2.3`), bumped
from the commit types. Starting Claude in this folder skips permission prompts for the
read-only commands, the check, commits and pushes
(`.claude/settings.json`); force-pushing, skipping the hook, turning off
signing and deleting tags are blocked.

## Day to day

The commands behind what Claude does, for reference:

| Task | Command |
|---|---|
| Edit a dotfile | `chezmoi edit ~/.bashrc` (or edit the source and `chezmoi apply`) |
| Preview changes | `chezmoi diff` |
| Pull and apply updates | `chezmoi update` |
| Add a CLI tool | add it to `dot_config/mise/config.toml` (`mise registry <name>` to check it's there), then `chezmoi apply` |
| Add an app | add a `cask` to `Brewfile`, then `chezmoi apply` |
| Update tools | `mise upgrade` (tools set to `latest`); `brew upgrade` for apps |
| Change a tool version | edit `dot_config/mise/config.toml`, then `chezmoi apply` |
| Pin a version for a project | `mise use kubectl@1.34` inside the project |
| Update Neovim plugins | `:Lazy update` in Neovim, then `chezmoi re-add ~/.config/nvim/lazy-lock.json` (the lock file pins every machine to the same versions) |
| Update a pinned skill | open the history link above its entry in `.chezmoiexternal.toml`, read what changed, put the new commit in its `url`, then `chezmoi apply` |
| Refresh GitHub's SSH host keys | only if GitHub rotates them (ssh then refuses to connect): regenerate `private_dot_ssh/known_hosts.github` from the `ssh_keys` list at https://api.github.com/meta |

Docker runs in a [Colima](https://github.com/abiosoft/colima) VM that a
LaunchAgent starts at login (log: `~/Library/Logs/colima.log`). `colima stop`
frees its memory until the next login or `colima start`.

Settings for a single machine go in `~/.bashrc.local` and
`~/.ssh/config.local`, which this repo doesn't manage.

## Keyboard

Set up for a standard Mac keyboard, where Control sits beside `fn` at the
bottom-left corner:

- Caps Lock is Control, on every keyboard, through a LaunchAgent that runs
  `hidutil` at login. tmux's prefix (`C-Space`), Neovim's split movement and
  completion, fzf and readline all use Control.
- macOS's own `⌃Space` shortcut (select the previous input source) is turned
  off so it can't take tmux's prefix (`run_onchange_after_40-macos-shortcuts.sh`).
- Bash history prefix search is on `C-p`/`C-n` as well as Up/Down.
- tmux splits side by side with `\` instead of `|`, which needs Shift.

Alternatives considered and not set up, in case they're wanted later:

- **Caps Lock as Esc when tapped, Control when held.** `hidutil` can only swap
  one key for another, so this needs
  [Karabiner-Elements](https://karabiner-elements.pqrs.org): add
  `cask "karabiner-elements"` to the Brewfile, approve its driver in System
  Settings, add its "Change caps_lock to control if pressed with other keys,
  to escape if pressed alone" rule (or commit
  `dot_config/karabiner/karabiner.json`), and delete
  `local.caps-lock-control.plist` from the repo and from
  `~/Library/LaunchAgents` after `launchctl bootout gui/$(id -u)/local.caps-lock-control`.
- **One set of keys for tmux panes and Neovim splits.** Today Neovim splits use
  `C-hjkl` and tmux panes use the prefix then `hjkl`.
  [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
  makes `C-hjkl` cross both. It needs the plugin in Neovim plus its bindings in
  `tmux.conf`, and in shell panes inside tmux `C-l` (clear screen) and `C-k`
  (delete to end of line) then need the prefix first.
- **Command keys for tmux.** Ghostty can turn Command shortcuts into tmux
  keys, e.g. `keybind = cmd+1=text:\x001` (`\x00` is `C-Space`) to jump to
  window 1, or `cmd+t=text:\x00c` for a new window. These replace Ghostty's own
  tab shortcuts.

## Layout

| Path | What it configures |
|---|---|
| `CLAUDE.md`, `.claude/settings.json` | How Claude Code maintains this repo, and which commands it may run here without asking. Not copied to `~` |
| `.githooks/commit-msg` | Rejects commit messages that aren't Conventional Commits. `bootstrap.sh` turns it on with `git config core.hooksPath .githooks` |
| `scripts/check` | Renders every file into a throwaway home folder and checks it with the program that reads it (shellcheck, tmux, git, ssh, plutil, jq, Neovim, Ghostty, Homebrew). Run before every apply |
| `.chezmoi.toml.tmpl` | The questions chezmoi asks once per machine (name, email, signing key) and where the repo was cloned |
| `dot_config/mise/config.toml` | Every command-line tool and language server, installed by mise |
| `dot_bashrc`, `dot_bash_profile` | Shell entry points; they load `~/.config/bash/rc.d/*.bash` in order |
| `dot_config/bash/rc.d/` | Homebrew, environment, mise, completions, aliases, prompt |
| `dot_config/readline/inputrc` | Tab completion and prefix history search on Up/Down and `C-p`/`C-n` (bash's line editor) |
| `dot_config/git/` | Git config (SSH commit signing), global ignore, allowed signers. Commits are personal by default; repos on the work host (or its work orgs) switch to the work email and key (`work`) |
| `private_dot_ssh/` | SSH config (keys unlocked through the macOS keychain; a `git-work` host that points at the work git host and offers only the work key, so the host sees the work account) and GitHub's published host keys, so the first connection to GitHub is checked instead of trusted |
| `private_dot_docker/`, `.chezmoitemplates/docker-config.json` | Docker CLI: compose and buildx plugins from mise, logins in the macOS keychain. Merged into the live file like Claude Code's settings |
| `dot_config/nvim/` | Neovim: lazy.nvim, built-in LSP and completion (servers installed by mise), conform for formatting |
| `dot_config/tmux/tmux.conf` | tmux (prefix `C-Space`; the built-in keys it relies on are listed at the top) |
| `dot_config/ghostty/config` | Ghostty (Gruvbox dark). Its first window at launch runs `tmux-pick` |
| `dot_local/bin/executable_tmux-pick` | `~/.local/bin/tmux-pick`: lists tmux sessions, most recent first, to attach to or start a new one; starts one straight away if there are none. Esc or leaving tmux drops to a plain shell |
| `dot_config/claude/`, `.chezmoitemplates/claude-settings.json` | Claude Code (see below) |
| `.chezmoiexternal.toml` | Files downloaded from other repos, pinned to a commit (Claude Code skills) |
| `private_Library/LaunchAgents/` | At login: starts Colima (Docker), loads SSH keys from the keychain into ssh-agent (git signs commits through it) and makes Caps Lock a Control key |
| `run_onchange_*` | Re-run `brew bundle`, `mise install` and completion generation when their inputs change, reload the LaunchAgents, and turn off macOS's `⌃Space` shortcut |

## Claude Code

Installed by mise and updated with `mise upgrade`; its own auto-updater is
turned off (`DISABLE_AUTOUPDATER`) so it doesn't install a second copy outside
mise. `CLAUDE_CONFIG_DIR` (set in
`05-env.bash`) moves its config from `~/.claude` and `~/.claude.json` to
`~/.config/claude`. That only works for `claude` started from a shell, which is
the only way it's used here. Sign in once per machine with `claude auth login`.

| Kind of file | Where it lives |
|---|---|
| Settings (theme, env, plugins, marketplaces, permissions, hooks) | Add keys to `.chezmoitemplates/claude-settings.json` (it already makes `chezmoi apply` and `update` always ask first). `modify_settings.json` merges them into the live file, so these values win, and anything Claude Code writes itself (`/model`, `/config`) is kept. Deleting a key here doesn't remove it from the live file; remove it there too. `false`, empty and `0` values can't override a live value either. |
| Plugins | Add `"name@marketplace": true` under `enabledPlugins`. Claude Code installs them at the next session start. |
| Global instructions, rules, agents, commands | Plain files under `dot_config/claude/`. `CLAUDE.md` there says this Mac is managed from this repo; add rules as `dot_config/claude/rules/*.md`. |
| Skills from GitHub | Add an entry to `.chezmoiexternal.toml`, pinned to a commit, with a link to the skill's history so updates can be checked by hand. Your own skills go in `dot_config/claude/skills/<name>/SKILL.md`. |
| MCP servers (user scope) | Claude Code stores these in its own state file, so add a `run_onchange_` script that runs `claude mcp add-json --scope user ...`. |
| Not managed | `.claude.json` (sign-in, per-project state), history, sessions, the plugin cache, and anything synced from your claude.ai account (connectors, synced skills). |

## What changed from the old setup

| Old setup | Now |
|---|---|
| `bash` | Same drop-in folder, moved to `~/.config/bash/rc.d`. The prompt shows path and git state via git's own `__git_ps1` (`*` unstaged, `+` staged, `%` untracked), `user@host` only over SSH, and a red `❯` after a failed command; the kube namespace and terraform workspace are gone. History is timestamped and saved per command but no longer shared live between open shells. A readline `inputrc` adds case-insensitive completion and prefix history search on Up/Down and `C-p`/`C-n`. `go install` targets `~/.local/bin`. Completions are generated once and lazy-loaded by bash-completion@2. `KUBECONFIG` is back to the default `~/.kube/config` |
| `asdf` | mise |
| `go`, `kubectl`, `helm`, `terraform` | mise (`latest` globally, pinned per project) |
| `python`, `miniconda`, `base-env.yaml` | uv; Python versions and environments are per project |
| `ruby`, `rust` | Dropped (Rust was only there to build Alacritty) |
| `packages` | mise for CLI tools, Brewfile for apps. Homebrew git is replaced by Apple's. Removed: `ack` (use ripgrep), `tree`, `exa`, `aws-iam-authenticator` (use `aws eks get-token`), compiler libraries asdf needed, `ansible`, `argo`, `mkdocs`, `ctags`, `brew-cask-completion`, `curl`, `wget`, `make`, `telnet`, `watch`, `ncdu`, `gopass`, `ccrypt`, `aws-vault`, `coreutils`, `gnu-sed`, `gnu-tar`, `jq` (macOS ships it), `yq`, `gh`, `kubectx` (use k9s or `kubectl config`), `bats-core`, and the Keybase, Signal, Chrome, Hammerspoon and Karabiner apps |
| `vim` | Neovim. NeoBundle is now lazy.nvim. ALE, vim-go and black are now LSP and conform, with Neovim's built-in completion. Helm charts get helm-ls and Compose files get Docker's language server (filetype rules in `lua/config/filetypes.lua`). polyglot and the syntax plugins are replaced by Neovim's built-in syntax highlighting. ack.vim is now fzf-lua. gitgutter is now gitsigns. Dropped: fugitive, surround, repeat, endwise, targets, tabular, indent guides, vim-test, markdown-preview and TypeScript support |
| `git` | Separate personal (GitHub) and work (any git host) identities, chosen by the repo's remote. Commits and tags are signed with SSH, not GPG. `git pull` rebases instead of merging. Current git settings are added (zdiff3, histogram diff, autoSetupRemote, etc.); settings that are now git's or Apple's defaults are dropped. Aliases that duplicated others or that signing-by-default made redundant (`ca`, `amend`, `ci`, `cs`, `csa`, `ris`, `tsa`, `dc`, `head`, `fap`, `r`, `ra`, `lg`, `lgs`) are removed, as are the rarely used `rero`, `rht`, `dh1`, `ff`, `ms`, `mc`, `ignore`/`ignored`/`acknowledge`, and the plain shortcuts `co`, `sw`, `b`, `aa`, `di`, `ds`, `rc`, `fa`, `dlb`, `drb`. Fetch no longer prunes local tags. The log aliases share one `--pretty=line` format |
| `gpg` | Dropped. SSH keys go in the macOS keychain instead of gpg-agent |
| `tmux` | Same prefix (`C-Space`), colours and `hjkl` pane movement. Splits are now `\` and `-`, resizing moved to `Ctrl-hjkl` so `L` jumps back to the last session again, and `S` creates a named session. Windows and panes are numbered from 1; mouse support is on; copy mode uses vi-style `v`/`y` (to the macOS clipboard through Ghostty). The status bar shows the session name instead of the kube context, plus a PREFIX flag and the date. Settings tmux removed or now defaults are dropped, and `reattach-to-user-namespace` is gone |
| `alacritty` | Ghostty, with its built-in `Gruvbox Dark` theme (the same palette). Block cursor everywhere, including the prompt; Option works as Alt. The first window at launch opens a tmux session picker |
