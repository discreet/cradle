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
2. Update README.md in the same change: Getting started (anything to have
   ready, a new chezmoi question, a bootstrap step or a manual step after
   it), the Layout and Day to day tables, the Keyboard section, the claude.ai
   connectors table and the "What changed" table where they're affected. Update
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
| Anything about cradle that can't be public: private notes every machine needs (which hosts or orgs are in use, quirks of the user's accounts), work skills, agents and settings | private-cradle (`~/.config/private-cradle`, the `privateCradleRepo` repo), cloned and backed up by `vault-sync`; notes in its README |
| Lessons: what worked or failed and what to do next time | agentdb. Work here learns from both databases: before real work, `reflexion_retrieve` on `agentdb` (personal, this folder's) and `agentdb-work` (work sessions' lessons, connected here on machines with a work identity); `cradle-maintainer` has them as `agentdb-personal` and `agentdb-work`. Store in the personal one, and bring nothing private from a work lesson into the repo: restate it in generic words |
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
| A GUI app | a `cask` in `Brewfile.tmpl` (a template: a terminal's app goes under its `.terminal` branch) |
| A Homebrew formula | Nowhere, if mise can install it. Only `bash`, `bash-completion@2` and `mise` are formulae |
| Shell settings, aliases, env | a file in `dot_config/bash/rc.d/` (loaded in name order) |
| A macOS setting | a `run_onchange_` script using `defaults write`, ideally applied without logging out |
| Something that runs at login | a plist in `private_Library/LaunchAgents/` named `<label>.plist`; `run_onchange_after_30-launch-agents.sh.tmpl` finds it and reloads only agents that changed. If it reads `~/Documents`, run its script as `/opt/homebrew/bin/bash <script>` (the program with Full Disk Access) and make it say so when access is denied, not fail quietly. If it needs the network, run `net-wait` first: launchd starts a run the Mac slept through on waking, often before Wi-Fi is back |
| A file that programs also write | a `modify_` template that merges managed keys over the live file, like `dot_config/claude/modify_settings.json` and `private_dot_docker/modify_private_config.json`. The merge can't set `false`, `""` or `0` over a live value; turn such a setting off another way (e.g. a `run_onchange_` script with `jq`) |
| A value that differs per machine | `promptStringOnce` in `.chezmoi.toml.tmpl`, used as `{{ .name }}` in a `.tmpl` file |
| A file from someone else's repo | `.chezmoiexternal.toml`, pinned to a commit, with a link to its history above the entry |
| A Neovim plugin | `dot_config/nvim/lua/plugins/`; then `chezmoi re-add ~/.config/nvim/lazy-lock.json` after it installs. Its language server goes in mise and `vim.lsp.enable` in `plugins/lsp.lua` |
| Claude Code settings, plugins, MCP servers | see the Claude Code section of README.md |
| A Claude Code agent | `dot_config/claude/agents/<name>.md`, only when it needs other tools, model or its own context; know-how alone is a skill. A row in README's Claude Code table. The session-start list (`claude-agents`) finds it by itself |
| A Claude Code skill | `dot_config/claude/skills/<name>/SKILL.md`, with longer reference notes in files beside it. A skill that needs the work vault goes in `.chezmoiignore`'s `workVault` block and `scripts/check`'s `personal_vault_only` list. A row in README's Layout table. Keep employer detail out: the skill finds it at run time and keeps it in the work vault. A work skill or agent goes in private-cradle, never here; see "Work extras" in Decisions |
| A Claude Code hook | its script in `dot_local/bin/`, registered in `dot_config/claude/modify_settings.json`'s `$hooks` (appended, so others' hooks stay); `scripts/check` asserts each machine's exact SessionStart list |
| How `cradle-maintainer` works | `dot_config/claude/agents/cradle-maintainer.md.tmpl` (a template for its agentdb servers' paths). Rules and decisions stay in this file, which it reads each time; don't copy them into the agent |
| Anything that only works through a claude.ai connector (Slack, Google...) | the feature where it belongs, plus a row in README's "claude.ai connectors" table: the connector, the access it needs, and what depends on it. Headless `claude -p` runs load connectors (since 2.1.323) but may use only the tools in their `--allowedTools`: allow read tools by exact name, and let the next interactive session catch up what a run couldn't reach |
| Obsidian settings or vault templates | `obsidian/`, applied to the work vault by `run_onchange_after_35-obsidian.sh.tmpl` (JSON settings are merged into the vault's `.obsidian/` files). Where past daily notes are archived: `dot_local/bin/executable_daily-archive.tmpl` alone (`--path` answers for `journal-check`); the journal skill's "Finding or creating the note" describes the same layout |
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
  npm-based language servers. mise installs one global Python only because
  gcloud's macOS installer needs that exact minor (3.14 for now) and fails
  without it (tested 2026-11-20); it's pinned to what gcloud asks for and
  installed before gcloud (`depends`). Projects still get theirs from uv.
- **Cloud CLIs:** `aws-cli` with AWS's Session Manager plugin (for `aws
  ssm start-session`), and `gcloud` (GCP auth, ADC, impersonation), both
  added 2026-11-20, all from mise. The `gcloud-cli` cask was rejected: it
  needs Homebrew's `python@3.14` formula and auto-updates outside mise. So
  was the `session-manager-plugin` cask: a `.pkg` installed with `sudo`;
  mise's `aqua:` backend takes the plugin from AWS's own zip instead.
  Credentials and config stay per machine (`~/.config/gcloud`), never in
  this repo.
- **GitHub CLIs:** `gh` (added back 2026-11-20 for PRs) and Graphite's
  `gt` (stacked PRs, added 2026-11-20), both from mise. Sign gh in
  with SSH as the git protocol so it doesn't become git's credential
  helper; the git identity rules below stay in charge of which key and
  email a repo uses.
- **Neovim:** lazy.nvim, built-in LSP and completion, conform for formatting,
  fzf-lua, gitsigns, vim-sleuth. Leader is `,`. Arrow keys stay disabled.
  Trailing whitespace is trimmed by hand (`,W`), not on save. Saving formats
  every file: with conform's formatter where one is set, otherwise with the
  language server (`lsp_format = "fallback"`), e.g. JSON, shell, Dockerfiles. Helm uses helm-ls;
  towolf/vim-helm was rejected. Plugin versions come from `lazy-lock.json`.
- **Terminal, per machine:** chezmoi asks `terminal` (chosen 2026-11-20):
  `ghostty` (Ghostty + tmux, the default) or `rex` (Superlogical's terminal
  and multiplexer). Each machine gets only its terminal's files: Ghostty's
  cask and config, tmux (`mise/conf.d/tmux.toml`), `tmux.conf`, `tmux-pick`
  or Rex's `~/.config/rex/init.lua`, its Gruvbox Dark theme file and its
  Settings script. The `⌃Space` script runs on both, since both use that
  prefix. Rex has no cask, so it's installed by hand from the tester
  `.dmg`. On a Rex machine Rex replaces Ghostty + tmux and is set up as
  close to them as it allows (the user's call, 2026-11-20): `init.lua`
  gives it `tmux.conf`'s keys on the same `C-Space` prefix, so a change to
  `tmux.conf`'s keys goes into `init.lua` too; private hosts go in the
  unmanaged `local.lua` it loads. The user's Rex shortcuts are those ported
  tmux keys (asked 2026-11-24): when asked for one, answer with the prefix
  key from `init.lua`, not Rex's built-in Command keys; if Rex drops or
  renames an action, rebind the same tmux key to its nearest replacement.
  Rex's Settings are macOS defaults
  (`com.superlogical.rex`), and `run_onchange_after_41-rex-settings.sh.tmpl`
  writes only those that differ from Rex's defaults; importing the theme
  is the one step by hand.
  Ghostty + tmux stays the default because Rex is only an invite-only beta
  (checked 2026-11-03 with its docs, changelog and beta feedback: still
  testers only, no cask, no keyboard copy mode, most settings outside its
  config file). Make `rex` the default when every row of README's "What Rex
  needs before it's the default" is met; recheck it when asked. That list is
  about this setup's needs, not tmux/Ghostty habits, so don't add rows for
  recreating tmux keys or workflows.
- **Ghostty:** built-in `Gruvbox Dark`, block cursor everywhere, both Option
  keys as Alt, SSH terminfo helper off. The first window runs `tmux-pick`.
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
  the whole host is work; required when the work host is github.com; the
  work account's own namespace is listed here too when work repos, like the
  work vault's backup, live under it) and work
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
  database, one per project and marker files were rejected. cradle alone
  reads both (asked 2026-11-25), so it manages the setup with every lesson:
  `agentdb-mcp work|personal` picks a database outright, the MCP script
  registers `agentdb-work` at local scope for the cradle folder only, and
  `cradle-maintainer` declares both in its own `mcpServers`, from any
  folder. Other sessions still see only their own database. Claude uses it
  because the global instructions (`dot_config/claude/CLAUDE.md.tmpl`) say
  to: `reflexion_retrieve` before real tasks, `reflexion_store` after.
  Possible later step, if Claude skips that too often: Claude Code hooks that
  recall at `SessionStart` and store at `Stop`. Hooks can't call MCP tools,
  so they'd run the `agentdb` CLI on the same database (reuse
  `agentdb-mcp`'s work/personal choice); first check the CLI covers recall
  and store.
  `cradle-maintainer` (`dot_config/claude/agents/`) is the expert on this
  repo: sessions elsewhere hand it every setup change and question. It
  stops before `chezmoi apply`, so the user's OK stays with the main
  session, which messages it back to commit and push. It reads this file
  and README.md every time instead of repeating them. It is the only custom
  agent for now (2026-11-05). Tabled, not rejected: a `work-lead`/
  `personal-lead` orchestrator run as the main session (`claude --agent`),
  a read-only `pm` agent over Slack, Google and other work tools, and a generic
  `repo-worker`, with repo knowledge kept in each repo's own CLAUDE.md
  rather than per-repo agents here. Don't propose them again unless asked.
  Each session's start shows the user its custom agents (user and
  project, found at runtime) through a SessionStart hook's `systemMessage`
  (`~/.local/bin/claude-agents`, asked 2026-11-20); it adds nothing to
  Claude's context.
  The Skylight Calendar MCP server (`skylight-mcp`) was removed on
  2026-11-20 at the user's request; the MCP script still unregisters it on
  old machines until they've all applied that.
- **Work extras are the user's alone** (rule set when the work agents were
  created; skills moved 2026-11-25): the specialized agents, skills and
  settings Claude builds for work are for the user's use only. Never in
  this repo or its history (on 2026-11-25 the user had two work skills and
  every mention of them purged from it, tags recreated and force-pushed),
  never committed to a work repo, pushed publicly or shared. A work repo
  keeps its agents out of git in `.git/info/exclude`, never a tracked
  `.gitignore`; a repo's own tracked `.claude/skills/` is the repo's call.
  Their home is the `claude/` folder of private-cradle (below).
- **gh is read-only for the work org's repos, in every session and agent**
  (the user's standing rule, 2026-11-27; first set for the code agents only,
  widened the same day). Unless the user explicitly allows a write in that
  session, no Claude session or agent writes to those repos with gh; the
  user runs such a write themselves (`! <command>`). The user's own repos,
  this one included, stay read/write: managing the machine needs them. The
  read-only owners are private, so they're listed in private-cradle's
  `claude/gh-read-only`, not here or in a chezmoi question (`workOrgs` also
  holds the user's own work account, which must stay writable). Enforced by
  `~/.local/bin/gh-read-only`, a global `PreToolUse` hook on Bash
  (`modify_settings.json`, machines with private-cradle): reads pass, and a
  gh write is blocked when its repo's owner is listed or its repo can't be
  told. A hook only in the code agents' frontmatter was the first version;
  the user chose everywhere. The code agents also state the rule in their
  Hard rules.
- **private-cradle holds everything about cradle that can't be public**
  (the user's rule, 2026-11-25): a private repo under the user's work
  account (`privateCradleRepo`, chosen over a hidden folder in the work
  vault), cloned to `~/.config/private-cradle`. Its `claude/` part:
  `run_after_46-private-cradle` links its skills and agents into
  Claude's config, `modify_settings.json` merges its `settings.json`, the
  journal follows its `journal.md` and the evening run allows its
  `journal-tools`, and `vault-sync` clones and backs it up. Its README holds
  the decisions about what's in it, and replaces the personal vault's
  `cradle.md` for private notes. cradle's side stays generic: name nothing
  private in this repo, commit messages or tags. Work repos keep a link to
  their agent in `.claude/agents/` (still excluded), pointing into it.
  The evening journal run may read all of private-cradle, read only
  (`Read(~/.config/private-cradle/**)`; the user's call, 2026-11-27), on one
  condition: nothing it reads there ever goes into this repo, its commits or
  tags. It stays on the machine and in the private repo; cradle holds only
  the generic rule.
- **Apps:** Homebrew installs only Obsidian, plus Ghostty on Ghostty
  machines. Firefox and Slack were removed on 2026-11-20 (Slack is still
  used through its claude.ai connector). The Slack app comes pre-installed
  and required on work machines, outside cradle: leave it, and don't
  suggest uninstalling it or count it as left over.
- **Uninstalling (planned, asked 2026-11-20):** cradle only installs. A
  cask, mise tool, MCP server or file dropped from the repo stays on
  machines that had it (`brew bundle` without `--cleanup`, `mise install`,
  `claude mcp add`, chezmoi leaving removed targets). Add a way to remove
  what the repo no longer lists, e.g. `brew bundle cleanup` with
  confirmation, `mise prune`, a `.chezmoiremove`, and removing
  unregistered MCP servers. Until then, say what to uninstall by hand.
- **Full Disk Access for the evening jobs** (chosen 2026-11-23): macOS
  blocks LaunchAgents from `~/Documents`, which held the evening journal and
  backups at "Nothing happened today" from 2026-11-20. The journal,
  `vault-sync` and `daily-archive` agents run their scripts with Homebrew's bash
  (`/opt/homebrew/bin/bash <script>`, not the `#!/usr/bin/env bash` line,
  which under launchd is Apple's `/bin/bash`), and that bash's real path
  (`realpath`) is granted Full Disk Access by hand, a step after bootstrap.
  Trade-off accepted: every bash script a LaunchAgent starts with that bash
  gets the access. Homebrew's bash is ad hoc signed, so each new bash build
  needs the grant again. Without access, `is-work` exits 2 with a message,
  `obsidian-journal` logs it and leaves a `no-access` marker,
  `vault-sync` notifies, and `journal-check` tells the next session and
  has it write the missed day. Likewise (2026-11-27), when the network
  isn't up within 5 minutes (`net-wait`) or Claude fails, the run adds the
  day to a `failed` marker and the next session writes it. No automatic test from launchd's context
  (that would need `launchctl`); `launchctl kickstart` of the agent is the
  manual check. Moving the vaults and work folders out of `~/Documents` and
  granting Apple's `/bin/bash` were not chosen.
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
  `## Slack` via the claude.ai connectors (Slack under either name, the
  connector's `mcp__claude_ai_Slack__*` or the plugin's
  `mcp__plugin_slack_slack__*`). Headless `claude -p` didn't load
  connectors in 2.1.314 but does in 2.1.323 (2026-11-23), so the evening
  run writes every section (chosen 2026-11-23), allowed read tools only:
  Slack's search, thread and profile reads under both names, Google
  Calendar's list, get and search, Drive's and Docs' reads for
  attached notes, and the tools private-cradle's `journal-tools` lists;
  never create, update, delete or respond. A hook (`journal-check`, on SessionStart
  and UserPromptSubmit, once a day) has the next interactive session catch
  up whichever is missing, saying so in one line without asking, then back
  up the vaults (chosen over offering first, on-demand only and local MCP
  servers with tokens). The user takes
  their own meeting notes in `## Meetings` under `### HH:MM` headings, from
  `/journal agenda` (run by the same hook each weekday without asking, including in a
  session left open overnight) or `Templates/Meeting.md`; the
  journal matches them to events by time and never edits the user's text
  (chosen over AI note-takers, attached notes docs and one note per
  meeting). Section markers `%% agenda %%`/`%% journal %%` record progress. Daily notes are managed from `obsidian/`: `Daily/YYYY-MM-DD.md`,
  from `Templates/Daily.md`, which the repo overwrites (the user chose a
  managed template over a create-once one). Only today's note stays at
  the top of `Daily/` (chosen 2026-11-24): `daily-archive` moves earlier
  ones to `Daily/YYYY-MM MMMM/Week N/` (year first, so months sort and
  years stay apart; exactly four weeks a month: days 1–7, 8–14, 15–21,
  22 to the end), every morning at 04:00 from a LaunchAgent and at the
  start of `/journal agenda`, never in the 18:00 run. Obsidian's Daily
  notes settings stay on `Daily/`, so it and the journal create today's
  note at the top. It never overwrites, deletes or touches files not
  named like a date; a taken archive path is reported and skipped. A
  past day's note the journal must create (a catch-up) goes straight
  into its archive folder. `daily-archive` runs without asking, allowed
  exactly as `Bash(daily-archive)` and `Bash(daily-archive --path *)`:
  declined on 2026-11-24 (an agenda run asked first), chosen on 2026-11-27
  because auto mode's classifier now refuses it outright. A line about it
  in the global instructions stays declined. Shell history was left out on purpose; per-session summaries and
  an on-demand-only journal were declined.
- **Google Workspace:** through claude.ai connectors only (Calendar for the
  journal; Drive, Docs and Sheets for searching and editing), connected in
  the claude.ai account, so nothing for it lives in this repo beyond the
  journal. A local Google MCP server, Workspace APIs with an OAuth client,
  `gcloud`, and the Google Drive desktop app were not chosen for Workspace
  (`gcloud` is installed for GCP only, see Cloud CLIs).
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
  `minimum_release_age_excludes` with a reason (none now); a one-off urgent
  upgrade uses `MISE_MINIMUM_RELEASE_AGE=0`. mise's npm backend also refuses
  a release with less trust evidence than an earlier one (e.g. provenance
  dropped). Then pin the last trusted version rather than add a
  `trust_policy_excludes` entry: agentdb is pinned to 3.10.0 since 3.10.1
  (2026-11-11) shipped without provenance (chosen 2026-11-20); unpin when a
  newer release has provenance (`npm view agentdb@<v> dist.attestations`).
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
   are skipped; see Decisions). Check whether a pinned tool can go back to
   `latest` (agentdb: a newer release with provenance), and whether
   gcloud now wants a newer Python (`mise install` warns "Python 3.X was
   not found"; bump `python` to it). Drop any `minimum_release_age_excludes` entry
   whose reason no longer holds. This covers Claude Code and
   the language servers. Then regenerate bash completions for the new
   versions (chezmoi only reruns that script when mise's config changes):
   `chezmoi execute-template <"$(chezmoi source-path)/run_onchange_after_25-completions.sh.tmpl" | bash`.
   Nothing to commit unless a pin changes.
2. **Homebrew:** `brew update && brew upgrade` (bash, mise, apps). If bash
   was upgraded, tell the user to grant Full Disk Access to the new
   `realpath /opt/homebrew/bin/bash` and remove the old entry (README,
   After bootstrap); the evening jobs stop until they do.
3. **Neovim plugins:** `nvim --headless "+Lazy! update" +qa`, then
   `chezmoi re-add ~/.config/nvim/lazy-lock.json`, `scripts/check`, commit
   and push.
4. **Pinned downloads:** for each entry in `.chezmoiexternal.toml`, look for
   newer commits at its history link. If there are any, show the user what
   changed and bump the commit only if they agree, then apply, commit and push.
5. **GitHub host keys:** compare `ssh_keys` from https://api.github.com/meta
   with `private_dot_ssh/known_hosts.github`. They rarely change; if they
   differ, tell the user before updating.
