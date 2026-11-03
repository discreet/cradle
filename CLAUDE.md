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
   Keyboard section, the claude.ai connectors table and the "What changed"
   table where they're affected. Update
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

## Memory

What Claude learns while working here goes where it can reach the machines
that need it. After each change, put anything worth keeping in one place:

| What | Where |
|---|---|
| Decisions, rules, how to change things | This file and README.md: the only memory every machine gets, through git. Public, so nothing private |
| Private values that differ per machine (hosts, orgs, paths) | A chezmoi question (`.chezmoi.toml.tmpl`), used through templates |
| Private notes every machine needs (which hosts or orgs are in use, quirks of the user's accounts) | `cradle.md` in the personal Obsidian vault, backed up and cloned to each machine by `vault-sync` |
| Lessons: what worked or failed and what to do next time | agentdb (`reflexion_store`); sessions here use the personal database |
| Facts about one machine only, or work in progress on it | Claude Code's own project memory, which stays on that machine |

Don't keep a decision or a rule in Claude Code's memory or agentdb: it would
be missing on the next machine. When one turns up there, move it here.


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
  pushed tag unless the user explicitly asks for that tag to be moved or
  deleted. After pushing, tag if the commits since the last tag include:
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
| Anything that only works through a claude.ai connector (Slack, Google, Atlassian...) | the feature where it belongs, plus a row in README's "claude.ai connectors" table: the connector, the access it needs, and what depends on it. Connectors aren't loaded in headless `claude -p` runs, so design for the next interactive session |
| Obsidian settings or vault templates | `obsidian/`, applied to the work vault by `run_onchange_after_35-obsidian.sh.tmpl` (JSON settings are merged into the vault's `.obsidian/` files) |
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
  Ghostty + tmux was kept over Rex (Superlogical's terminal and multiplexer)
  on 2026-11-03, because Rex is only an invite-only beta (rechecked the same
  day with its docs, changelog and beta feedback: still testers only, no
  cask, no keyboard copy mode, most settings outside its config file).
  Switch when every row of README's "What Rex needs before switching" is
  met; recheck it when asked. That list is about this setup's needs, not
  tmux/Ghostty habits: with Rex the user will learn its own ways, so don't
  add rows for recreating tmux keys or workflows. Switching replaces tmux
  too, so it's breaking.
  Claude reads up on Rex through Superlogical's hosted community MCP server
  (`superlogical`, Discord sign-in via `/mcp`, needs the Rex Beta Discord).
- **tmux:** lean; prefix `C-Space`. Pane movement stays separate from Neovim's
  (vim-tmux-navigator declined; how to add it is in README's Keyboard section).
- **Keyboard:** a standard Mac keyboard. Caps Lock is Control via `hidutil`.
  Karabiner (tap for Esc) and Ghostty Command keys for tmux were declined;
  README's Keyboard section says how to switch.
- **Git identities:** personal and work, on separate accounts. Personal is on
  GitHub; work can be any git host (GitHub, GitLab, self-hosted), so nothing
  may assume GitHub for work. Each machine is asked for a name, a personal
  email, and optionally a work email, work host, work orgs/groups (blank:
  the whole host is work; required when the work host is github.com) and work
  folders (for agentdb only; git still goes by remote). Repos
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
  `~/.config/claude` via `CLAUDE_CONFIG_DIR` (set in mise's `[env]`, so it
  reaches claude from shells, shims and launchd alike); terminal only, no desktop app or
  IDE extension. MCP servers are registered by
  `run_onchange_after_45-claude-mcp.sh.tmpl`. agentdb (npm, ruvnet) is the
  memory MCP server, with separate work and personal databases
  (`~/.local/bin/agentdb-mcp`). A session is work when git's identity in its
  folder is work or the folder is under a work folder (`workFolders`, asked
  per machine with a work identity); anything else is personal. One shared
  database, one per project and marker files were rejected. Claude uses it
  because the global instructions (`dot_config/claude/CLAUDE.md.tmpl`) say
  to: `reflexion_retrieve` before real tasks, `reflexion_store` after.
  Possible later step, if Claude skips that too often: Claude Code hooks that
  recall at `SessionStart` and store at `Stop`. Hooks can't call MCP tools,
  so they'd run the `agentdb` CLI on the same database (reuse
  `agentdb-mcp`'s work/personal choice); first check the CLI covers recall
  and store.
- **Folders:** `~/Documents/work/` and `~/Documents/personal/`, each with
  `code/<org>/<repo>`, its `Obsidian/` vault and other files in topic
  folders next to `code/` (not as vault attachments); `cradle` stays at
  `~/Documents/cradle`. `workFolders` is `~/Documents/work`. Flat `code/`,
  grouping by product and a single shared vault were not chosen. README's
  Folders section is the reference.
- **Obsidian:** two vaults, work and personal (chosen over one shared
  vault). Claude uses both as plain files (extra working folders), not
  through an MCP server or plugin, and its instructions say to use the one
  matching the session (`is-work`, the same rule as agentdb) and reach into
  the other only when asked. Each machine is asked for a work vault (only
  with a work identity) and a personal vault, each with folders Claude must
  not read (denied to its file tools, forbidden otherwise by the global
  instructions). The personal vault is unstructured and ad hoc: cradle writes
  nothing to it, no daily notes, templates or journal. Obsidian doesn't sync
  between machines; each vault is backed up to its own private git repo
  (personal on GitHub, work on the work host) by `vault-sync` (chosen over
  Obsidian Sync, iCloud Drive and Time Machine): every evening at 18:00 once
  the journal has written the day's note (its run starts `vault-sync`; a
  machine without a work vault has its own 18:00 agent), and again after
  the journal skill fills in the Slack and Meetings summaries in the next
  interactive session (allowed without asking). Everything below is
  the work vault only. The `journal` skill
  summarises the day's work Claude Code sessions and git commits (personal
  ones are left out) into a
  `## Terminal` section of the daily note, run by a LaunchAgent every evening
  at 18:00. Meetings (Google Calendar, plus decisions and action items from
  attached meeting notes) and Slack conversations go in `## Meetings` and
  `## Slack` via the claude.ai connectors; headless `claude -p` doesn't load
  connectors (tested, 2.1.314), so a hook (`journal-check`, on SessionStart
  and UserPromptSubmit, once a day) has the next interactive session catch
  up whichever is missing, saying so in one line without asking, then back
  up the vaults (chosen over offering first, on-demand only and local MCP
  servers with tokens). The user takes
  their own meeting notes in `## Meetings` under `### HH:MM` headings, from
  `/journal agenda` (offered by the same hook each weekday, including in a
  session left open overnight) or `Templates/Meeting.md`; the
  journal matches them to events by time and never edits the user's text
  (chosen over AI note-takers, attached notes docs and one note per
  meeting). Section markers `%% agenda %%`/`%% journal %%` record progress. Daily notes are managed from `obsidian/`: `Daily/YYYY-MM-DD.md`,
  from `Templates/Daily.md`, which the repo overwrites (the user chose a
  managed template over a create-once one). Shell history was left out on purpose; per-session summaries and
  an on-demand-only journal were declined.
- **Google Workspace:** through claude.ai connectors only (Calendar for the
  journal; Drive, Docs and Sheets for searching and editing), connected in
  the claude.ai account, so nothing for it lives in this repo beyond the
  journal. A local Google MCP server, Workspace APIs with an OAuth client,
  `gcloud`, and the Google Drive desktop app were not chosen.
- **Jira:** tickets are created through the claude.ai Atlassian connector
  (needs write access granted on it) with the `jira-ticket` skill. Stories,
  Epics and Spikes follow `skills/jira-ticket/standards.md`: net-new
  standards from well-known practice (Connextra user stories, INVEST,
  Given/When/Then, outcome epics, timeboxed spikes), deliberately not
  modelled on the existing Jira. Spike is its own issue type; a project
  without it is a stop, not a fallback to Task or Story. The project must be
  named every time for now; a per-machine default project (a chezmoi
  question, since keys are work details) may replace that later.
- **claude.ai connectors** are the default for anything that talks to a
  hosted service the user already signs in to, over local MCP servers with
  tokens. README's "claude.ai connectors" table lists every connector and
  what in cradle depends on it.
- **Downloads from other repos** are pinned to a commit and updated by hand
  after reading what changed.
- **mise waits a week for new releases** (`minimum_release_age = "7d"`):
  `latest` skips anything younger, against bad or malicious releases. Chosen
  2026-11-02 after checking verification: mise already checks checksums,
  GitHub attestations and SLSA provenance by default, but the `github:` tools
  here publish only a checksum. Exceptions go in
  `minimum_release_age_excludes` with a reason (agentdb, until its 3.x line is
  a week old); a one-off urgent upgrade uses `MISE_MINIMUM_RELEASE_AGE=0`.
  Switching buildx to `aqua:` was rejected: aqua names the binary so Docker
  can't find it, and it gains nothing over the checksum.
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

1. **Tools:** `mise outdated`, then `mise upgrade` (versions under a week old
   are skipped; see Decisions). Drop any `minimum_release_age_excludes` entry
   whose reason no longer holds. This covers Claude Code and
   the language servers. Then regenerate bash completions for the new
   versions (chezmoi only reruns that script when mise's config changes):
   `chezmoi execute-template <"$(chezmoi source-path)/run_onchange_after_25-completions.sh.tmpl" | bash`.
   Nothing to commit unless a pin changes.
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
