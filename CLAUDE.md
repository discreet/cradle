# cradle

chezmoi source for the user's Apple Silicon MacBook: every CLI tool, app,
dotfile, macOS setting and Claude Code's own settings. The user doesn't edit
this repo by hand. Claude makes every change, update and addition here, so
keep it lean and make each change complete: config, README and this file.
README.md says what is set up and why; this file says how to change it.

Repo: `~/Documents/cradle` (`chezmoi source-path`),
`git@github.com:discreet/cradle.git`, branch `main`.

## Making a change

1. Edit the source in this repo, never the files in `~`. chezmoi overwrites
   those on the next apply. If a program changed a managed file and the change
   should be kept (e.g. `lazy-lock.json` after a plugin update), copy it back
   with `chezmoi re-add <path>`.
2. Update README.md in the same change: the Layout and Day to day tables, the
   Keyboard section and the "What changed" table where they're affected. Update
   the Decisions list below if the user changes or makes a decision.
3. Run `scripts/check` and fix anything it reports. It renders every file into
   a throwaway home folder and checks it with the program that reads it.
4. Summarise `chezmoi diff` in plain words, then run `chezmoi apply`. Claude
   Code asks the user before every apply; that prompt is their OK. If they
   decline, stop and leave the change uncommitted. Always type it exactly as
   `chezmoi apply` (options after `apply`): the ask rule doesn't match
   `chezmoi --verbose apply` or a full path to chezmoi. If the apply needs a
   password (`sudo` for a cask, `chsh`), ask the user to run
   `! chezmoi apply` themselves.
5. Confirm it works on the machine: run the tool, open the config, `mise ls`,
   `launchctl print gui/$(id -u)/<label>`, whatever fits.
6. Commit and push; no asking needed, never force-push. Then tag a release
   if one is due (below) and push it with `git push --follow-tags`.

The repo is public on GitHub. Nothing private goes in it: no names, emails,
tokens, keys, work org or host names, employer details or machine-specific
paths. Those are answers to `.chezmoi.toml.tmpl`'s questions (saved per
machine in `~/.config/chezmoi/chezmoi.toml`) and reach files only through
templates; private hosts go in `~/.ssh/config.local` or `~/.bashrc.local`.
Commits here use the personal identity, which the check verifies.

Something in `~` that differs from the repo (`chezmoi status`) was changed
outside it. Ask before overwriting it, and offer to bring it into the repo.

Durable decisions belong in this file, not in Claude's memory, which stays on
one machine.

## Commits and releases

- **Commits follow [Conventional Commits](https://www.conventionalcommits.org):**
  `type(scope): what changed`, imperative, at most 72 characters, a blank
  line before any body. Types: `feat` (adds or changes what the setup does),
  `fix`, `perf`, `refactor`, `docs`, `style`, `test`, `build`, `ci`, `chore`,
  `revert`. The scope is the area: `tmux`, `nvim`, `git`, `ssh`, `bash`,
  `mise`, `brew`, `claude`, `macos`, `bootstrap`, `check`... A breaking change
  gets `!` after the type and a `BREAKING CHANGE:` footer saying what to do.
  `.githooks/commit-msg` rejects anything else; never bypass it with
  `--no-verify`.
- **Every commit and tag is signed** (SSH, `commit.gpgsign`/`tag.gpgsign`);
  never turn signing off.
- **Releases are annotated, signed SemVer tags only:** `vMAJOR.MINOR.PATCH`,
  made with `git tag -a vX.Y.Z -m "<summary of the changes>"` (signed through
  `tag.gpgsign`). No lightweight tags, no version file, never move or delete a
  pushed tag. After pushing, tag if the commits since the last tag include:
  - a breaking change → **major**: machines already set up need a manual step,
    or a habit changes (a tool or key binding removed or changed, a new or
    renamed chezmoi question);
  - `feat` → **minor**: something added or a setting changed compatibly;
  - `fix` or `perf` → **patch**.
  Commits of other types alone don't make a release.
- **Still 0.x:** the project started at `v0.1.0` because some of it isn't
  confirmed on a real machine yet (Ghostty's startup command, Neovim with its
  plugins, Caps Lock at login, a full first `mise install`). Until `v1.0.0`, a
  breaking change bumps the minor version and `feat`/`fix`/`perf` bump the
  patch. Tag `v1.0.0` only when the user confirms those all work.

`scripts/check` verifies the hook is on, every commit message and signature,
and every tag.

## Where things go

| To add or change | Put it in |
|---|---|
| A command-line tool, language server or formatter | `dot_config/mise/config.toml`. Prefer the registry name (`mise registry <name>`), then `github:`/`npm:`/`go:` backends. Use `latest` unless the user wants a pin. Add its bash completion to `run_onchange_after_25-completions.sh.tmpl` if it has one |
| A GUI app | a `cask` in `Brewfile` |
| A Homebrew formula | Nowhere, if mise can install it. Only `bash`, `bash-completion@2` and `mise` are formulae |
| Shell settings, aliases, env | a file in `dot_config/bash/rc.d/` (loaded in name order) |
| A macOS setting | a `run_onchange_` script using `defaults write`, ideally applied without logging out |
| Something that runs at login | a plist in `private_Library/LaunchAgents/` named `<label>.plist`; `run_onchange_after_30-launch-agents.sh.tmpl` finds it and reloads only agents that changed |
| A file that programs also write | a `modify_` template that merges managed keys over the live file, like `dot_config/claude/modify_settings.json` and `private_dot_docker/modify_private_config.json`. The merge can't set `false`, `""` or `0` over a live value; turn such a setting off another way (e.g. a `run_onchange_` script with `jq`) |
| A value that differs per machine | `promptStringOnce` in `.chezmoi.toml.tmpl`, used as `{{ .name }}` in a `.tmpl` file |
| A file from someone else's repo | `.chezmoiexternal.toml`, pinned to a commit, with a link to its history above the entry |
| A Neovim plugin | `dot_config/nvim/lua/plugins/`; then `chezmoi re-add ~/.config/nvim/lazy-lock.json` after it installs. Its language server goes in mise and `vim.lsp.enable` in `plugins/lsp.lua` |
| Claude Code settings, plugins, MCP servers | see the Claude Code section of README.md |
| Obsidian settings or vault templates | `obsidian/`, applied to the vault by `run_onchange_after_35-obsidian.sh.tmpl` (JSON settings are merged into the vault's `.obsidian/` files) |
| A file in the repo that must not land in `~` | `.chezmoiignore` (names starting with `.` are skipped already) |

## Decisions

The user chose these; keep them unless they say otherwise. Rejected options
are listed so they aren't proposed again without a reason.

- **Lean.** No settings that repeat a default, no tools nothing uses. When a
  change makes something redundant, remove it or offer to.
- **Homebrew holds as little as possible**; mise installs every CLI tool and
  language server (no mason). git is Apple's from the Command Line Tools,
  whose `usr/bin` is on PATH ahead of `/usr/bin`; no Homebrew git, wrappers or
  symlinks.
- **Shell:** Homebrew bash, not zsh. The prompt is path and git state, plus
  `user@host` over SSH only; kube and Terraform segments were removed on
  purpose. History isn't shared live between shells. Deep paths aren't
  trimmed.
- **Python:** uv, no conda. Ruby and Rust are dropped. node exists only for
  npm-based language servers.
- **Neovim:** lazy.nvim, built-in LSP and completion, conform for formatting,
  fzf-lua, gitsigns, vim-sleuth. Leader is `,`. Arrow keys stay disabled.
  Trailing whitespace is trimmed by hand (`,W`), not on save. Saving formats
  every file: with conform's formatter where one is set, otherwise with the
  language server (`lsp_format = "fallback"`), e.g. JSON, shell, Dockerfiles. Helm uses helm-ls;
  towolf/vim-helm was rejected. Plugin versions come from `lazy-lock.json`.
- **Ghostty:** built-in `Gruvbox Dark`, block cursor everywhere, both Option
  keys as Alt, SSH terminfo helper off. The first window runs `tmux-pick`.
- **tmux:** lean; prefix `C-Space`. Pane movement stays separate from Neovim's
  (vim-tmux-navigator declined; how to add it is in README's Keyboard section).
- **Keyboard:** a standard Mac keyboard. Caps Lock is Control via `hidutil`.
  Karabiner (tap for Esc) and Ghostty Command keys for tmux were declined;
  README's Keyboard section says how to switch.
- **Git identities:** personal and work, on separate accounts. Personal is on
  GitHub; work can be any git host (GitHub, GitLab, self-hosted), so nothing
  may assume GitHub for work. Each machine is asked for a name, a personal
  email, and optionally a work email, work host and work orgs/groups (blank:
  the whole host is work; required when the work host is github.com). Repos
  whose remote matches use the work email and `~/.ssh/id_ed25519_work`; SSH
  remotes reach the host through the `git-work` SSH alias (git rewrites their
  URLs), which offers only that key; personal hosts get `IdentitiesOnly` so a
  loaded work key is never offered to them. HTTPS remotes stay HTTPS and get
  the work email, but sign in with whatever the keychain holds for the host,
  so on a host shared with personal (github.com) work should use SSH. Not
  matched: SSH remotes with a port (`ssh://git@host:2222/...`) or a user
  other than `git`. Everything else, this repo included, is personal with
  `~/.ssh/id_ed25519`. Switching by folder was rejected. Commits are signed
  with SSH, not GPG; each key is on its account as an Authentication and a
  Signing key.
- **SSH:** GitHub's host keys are pinned in `private_dot_ssh/known_hosts.github`.
  `StrictHostKeyChecking accept-new`, keepalives and `ControlMaster` were
  declined.
- **Docker:** Colima from mise, started by a LaunchAgent, default VM size.
- **Claude Code:** from mise with its auto-updater off; config in
  `~/.config/claude` via `CLAUDE_CONFIG_DIR`; terminal only, no desktop app or
  IDE extension.
- **Obsidian:** Claude uses the vault as plain files (an extra working
  folder), not through an MCP server or plugin. Each machine is asked for the
  vault path and folders Claude must not read (denied to its file tools,
  forbidden otherwise by the global instructions). The `journal` skill
  summarises the day's Claude Code sessions and git commits into a
  `## Terminal` section of the daily note, run by a LaunchAgent every evening
  at 18:00. Slack conversations go in a `## Slack` section via the claude.ai
  Slack connector; headless `claude -p` doesn't load connectors (tested,
  2.1.314), so a SessionStart hook has the next interactive session offer to
  fill it (chosen over on-demand only and a local Slack MCP server with a
  token). Daily notes are managed from `obsidian/`: `Daily/YYYY-MM-DD.md`,
  from `Templates/Daily.md`, which the repo overwrites (the user chose a
  managed template over a create-once one). Shell history was left out on purpose; per-session summaries and
  an on-demand-only journal were declined.
- **Downloads from other repos** are pinned to a commit and updated by hand
  after reading what changed.
- **No links to or names of the old repos** this setup replaced, anywhere in
  the repo; the "What changed" table describes them only as the old setup.

## Testing safely

`scripts/check` covers most changes. For anything it can't (how a script
behaves, a LaunchAgent, a key binding), test in a throwaway home and keep away
from the live machine:

- Use `HOME=$(mktemp -d)` (or `env -i HOME=...`) and `chezmoi --source <repo>
  --config <temp file>`; never `chezmoi apply` to the real home to test.
- Never `launchctl bootstrap` a test agent, `defaults write` to a real domain,
  or `hidutil property --set` while testing. Lint and dry-run instead.
- Claude runs inside the user's tmux, so `$TMUX` is set. Every test tmux
  command needs `env -u TMUX`, its own `-L` name and its own `TMUX_TMPDIR`;
  without them, a test `kill-server` once killed the user's session. Check
  `tmux ls` before and after.

## Updating everything

When the user asks to update, do these in order and report what changed:

1. **Tools:** `mise outdated`, then `mise upgrade`. This covers Claude Code and
   the language servers. Nothing to commit unless a pin changes.
2. **Homebrew:** `brew update && brew upgrade` (bash, mise, apps).
3. **Neovim plugins:** `nvim --headless "+Lazy! update" +qa`, then
   `chezmoi re-add ~/.config/nvim/lazy-lock.json`, `scripts/check`, commit
   and push.
4. **Pinned downloads:** for each entry in `.chezmoiexternal.toml`, look for
   newer commits at its history link. If there are any, show the user what
   changed and bump the commit only if they agree, then apply, commit and push.
5. **GitHub host keys:** compare `ssh_keys` from https://api.github.com/meta
   with `private_dot_ssh/known_hosts.github`. They rarely change; if they
   differ, tell the user before updating.
