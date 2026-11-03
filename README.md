# cradle

Configuration for an Apple Silicon Mac, built on three tools:

- [chezmoi](https://chezmoi.io) applies dotfiles from this repo, filling in
  per-machine values (name, email, signing key) through templates.
- [mise](https://mise.jdx.dev) installs every command-line tool: languages,
  Neovim, tmux, kubectl, Claude Code and the rest
  ([config](dot_config/mise/config.toml)). New releases wait a week before
  mise installs them, so a bad release is usually pulled first.
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
optionally, the orgs or groups on it that are work, any folders whose Claude
sessions are work (for agentdb's memory and the journal) and a work Obsidian
vault. Every machine is also asked for a personal Obsidian vault (see
Obsidian). With a work identity, the script
also creates a separate work SSH key. It then
installs the Brewfile, writes the dotfiles, runs `mise install` and loads the
LaunchAgents. Finally the script makes Homebrew's bash your login shell and
installs Neovim's plugins at the versions in `lazy-lock.json`. It ends by
listing the manual steps left: adding the key to GitHub, and signing in to
Claude Code.

## Managed with Claude Code

After the first setup, changes are made by asking Claude Code, from any
folder: "add jq", "update everything", "change the tmux status bar". A global
instruction (`dot_config/claude/CLAUDE.md.tmpl`) sends it to this repo, and
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
| Update tools | `mise upgrade` (tools set to `latest`; releases under a week old are skipped, `MISE_MINIMUM_RELEASE_AGE=0 mise upgrade <tool>` takes one anyway), then regenerate completions: `chezmoi execute-template <"$(chezmoi source-path)/run_onchange_after_25-completions.sh.tmpl" \| bash`; `brew upgrade` for apps |
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

## Terminal: Ghostty + tmux, Rex considered

Ghostty draws the terminal and tmux keeps sessions alive. Ghostty's first
window runs `tmux-pick`, which attaches to a session.
[Rex](https://superlogical.com), from Ghostty's author, does both jobs in one
app. It's a possible later change, not set up. Checked 2026-11-03 against its
[docs](https://www.superlogical.com/rex/docs), changelog and beta feedback
(through the `superlogical` MCP server): still a beta for invited testers,
with new builds almost daily (Mac `0.1.0-preview.25`, Linux server
`preview.12`) and no cask or download script until a public release:

| | Ghostty + tmux (today) | Rex (beta, checked 2026-11-03) |
|---|---|---|
| Sessions outlive the app | Yes, through tmux | Yes: a server keeps sessions running whether or not a client is attached |
| Remote | SSH, with tmux on the far end if wanted | Its own client/server, not SSH: a Rex server on Linux or FreeBSD, reached over Tailscale (or Headscale) or a network listener. Callers are trusted by how they connect; sign-in with SSH keys is planned. No Windows server yet |
| Scrollback and selection | Ghostty's, plus tmux's keyboard copy mode | Native, by mouse (about 64 MiB scrollback). No keyboard copy mode: it's the most-asked-for feature and accepted, but the team warns it's hard; testers script stand-ins in Lua |
| Splits, tabs | tmux panes and windows (prefix `C-Space`) | Panes, tabs and floating windows on Command keys (`⌘D`, `⇧⌘D`, `⌘T`); any key can be rebound, including tmux-style prefix sequences. "Last pane" and tmux-style popups are accepted, not built |
| Extras | Ghostty shell integration, themes | Per-pane activity in tabs (working, blocked, done), asks before closing busy panes, open a session on the web, an iPhone/iPad app paired by QR code, Ghostty/iTerm theme import |
| Config | `dot_config/ghostty/config`, `dot_config/tmux/tmux.conf` | Lua `~/.config/rex/init.lua` holds keys, actions and hosts (`rex config check` / `reload`). Appearance and most other settings are only in the app's Settings; keeping them in a file was deferred, so chezmoi could manage only part of it |
| Updates | mise and Homebrew, when asked | The Mac app updates itself by default (can be turned off in its Settings) |
| Platforms | macOS, Linux | Mac and iOS apps; Linux and FreeBSD server. Linux and Windows apps not in testing |
| License | Both open source | Closed source and unfree; free to use, with no telemetry, account or license checks |
| Install | Brewfile cask, mise | Testers only: a Mac `.dmg`, iOS through TestFlight, Linux packages behind a Discord sign-in. More install options promised for the public release |

Switching would replace tmux as well as Ghostty: `tmux-pick`, `tmux.conf` and
the `C-Space` prefix would go. It would be a breaking change.

### What Rex needs before switching

Switch when every row is met. The list covers what this setup and the way
it's run need, not tmux or Ghostty habits: with Rex, its own keys and ways of
working get learned from scratch. ✅ met, ◐ partly or unconfirmed, ❌ not
yet. Status as of 2026-11-03.

| | Rex must | Because | Status |
|---|---|---|---|
| 1 | Have a stable public release, with no open crash or input bugs in daily use | Daily tools here aren't betas; mise even waits a week before taking a new release | ❌ Tester previews only; the stable channel has no releases yet |
| 2 | Install and update from this repo: a Homebrew cask, or a mise tool for the CLI | Every app is a Brewfile cask and every CLI tool is in mise | ❌ A `.dmg` for testers; "more installation options for public release" |
| 3 | Update only when asked | Updates are run on purpose (Updating everything); Claude Code's own updater is off | ◐ Self-installs by default; turning that off is a Settings switch behind Developer Mode, not a file |
| 4 | Keep every setting in files chezmoi can manage: look (theme, font, padding, cursor), Option as Alt, keys, hosts | Claude makes every change in this repo; nothing is set by hand | ◐ `init.lua` holds keys, actions and hosts; look and most other settings are only in the app's Settings. Keeping them in a file was deferred. Unconfirmed whether Settings are plain `defaults` keys a `run_onchange_` script could write |
| 5 | Let Claude check a config change without touching live sessions | Changes are tested in a throwaway home and an isolated tmux server, never on the live one | ◐ `rex config check <file>` checks a draft; an isolated test server is unconfirmed |
| 6 | Run Neovim fully: true colour, focus events (reload changed files), Option as Alt, Ctrl keys | Neovim is the editor; Option is Alt for word movement in bash and Neovim | ◐ Option-as-Alt setting exists (broken in floating panes); an open bug shifts true-colour values |
| 7 | Copy text from output and scrollback without the mouse, in whatever way Rex chooses | Work is keyboard-driven (Neovim, arrow keys off) | ❌ Mouse only; accepted, with a warning that it's hard |
| 8 | Keep sessions running after the window or app closes, and get back to them at launch | Work is left running between days | ✅ The server keeps sessions; a session picker and "new session on launch" exist |
| 9 | Work over plain SSH to hosts without Rex | Work and personal hosts are reached with SSH keys, per identity | ✅ `rex terminfo setup` / `host install` handle `TERM` |
| 10 | Copy from a remote program to the Mac clipboard | Copying from remote shells (OSC 52) | ✅ OSC 52 works; remote-Mac clipboard bugs are open |
| 11 | If persistent remote sessions are wanted: sign in to a remote Rex server with SSH keys, on any host, and let programs there use the Mac's clipboard | Work can be any git host, reached with its own key; Tailscale can't be assumed there. Neovim keeps its own registers and reaches the Mac clipboard only through `"+` | ❌ Tailscale or no authentication; SSH-key sign-in planned. On a remote server `"+` (`pbcopy`) lands on that machine's clipboard, not this Mac's (open request); on Linux, Neovim would need its OSC 52 clipboard set up |
| 12 | Set up Claude Code's Rex skill and hook inside this repo's Claude config | Claude Code runs in the terminal all day, from `~/.config/claude` (`CLAUDE_CONFIG_DIR`), managed by chezmoi | ◐ `rex skill setup` exists (`--agent`, `--dry-run`) but writes to the agent's settings itself and looks for `~/.claude`; it would need to be brought into the repo |
| 13 | Need no account and send no telemetry | Nothing here phones home or needs a sign-in to run | ✅ No telemetry, account or licence checks |

To recheck, ask Claude: it reads Rex's docs, changelog and feedback through
the `superlogical` MCP server.


## Layout

| Path | What it configures |
|---|---|
| `CLAUDE.md`, `.claude/settings.json` | How Claude Code maintains this repo, and which commands it may run here without asking. Not copied to `~` |
| `obsidian/` | Obsidian's Daily notes and Templates settings and the daily note template, applied to the work vault by `run_onchange_after_35-obsidian.sh.tmpl`. Not copied to `~` |
| `dot_config/claude/skills/journal/`, `dot_local/bin/executable_journal-data`, `dot_local/bin/executable_obsidian-journal`, `dot_local/bin/executable_journal-check.tmpl`, `private_Library/LaunchAgents/local.obsidian-journal.plist.tmpl` | The work vault's journal (see Obsidian); installed only when a work vault is set |
| `.githooks/commit-msg` | Rejects commit messages that aren't Conventional Commits. `bootstrap.sh` turns it on with `git config core.hooksPath .githooks` |
| `scripts/check` | Renders every file into a throwaway home folder and checks it with the program that reads it (shellcheck, tmux, git, ssh, plutil, jq, Neovim, Ghostty, Homebrew). Run before every apply |
| `.chezmoi.toml.tmpl` | The questions chezmoi asks once per machine (name, email, signing key) and where the repo was cloned |
| `dot_config/mise/config.toml` | Every command-line tool and language server, installed by mise |
| `dot_bashrc`, `dot_bash_profile` | Shell entry points; they load `~/.config/bash/rc.d/*.bash` in order |
| `dot_config/bash/rc.d/` | Homebrew (`brew shellenv`'s output written out, so new shells don't run brew), environment, mise, completions, aliases, prompt |
| `dot_config/readline/inputrc` | Tab completion and prefix history search on Up/Down and `C-p`/`C-n` (bash's line editor) |
| `dot_config/git/` | Git config (SSH commit signing), global ignore, allowed signers. Commits are personal by default; repos on the work host (or its work orgs) switch to the work email and key (`work`) |
| `private_dot_ssh/` | SSH config (keys unlocked through the macOS keychain; a `git-work` host that points at the work git host and offers only the work key, so the host sees the work account) and GitHub's published host keys, so the first connection to GitHub is checked instead of trusted |
| `private_dot_docker/`, `.chezmoitemplates/docker-config.json` | Docker CLI: compose and buildx plugins from mise, logins in the macOS keychain. Merged into the live file like Claude Code's settings |
| `dot_config/nvim/` | Neovim: lazy.nvim, built-in LSP and completion (servers installed by mise), conform for formatting |
| `dot_config/tmux/tmux.conf` | tmux (prefix `C-Space`; the built-in keys it relies on are listed at the top) |
| `dot_config/ghostty/config` | Ghostty (Gruvbox dark). Its first window at launch runs `tmux-pick` |
| `dot_local/bin/executable_agentdb-mcp`, `dot_local/bin/executable_is-work.tmpl` | `~/.local/bin/agentdb-mcp`: starts agentdb's MCP server on the work or personal database (see Claude Code). `~/.local/bin/is-work [folder]`: exits 0 when a folder is work (git's identity there, or inside a work folder); agentdb, the journal and Claude's choice of vault all use it |
| `dot_local/bin/executable_tmux-pick` | `~/.local/bin/tmux-pick`: lists tmux sessions, most recent first, to attach to or start a new one; starts one straight away if there are none. Esc or leaving tmux drops to a plain shell |
| `dot_config/claude/`, `.chezmoitemplates/claude-settings.json` | Claude Code (see below) |
| `dot_config/claude/skills/jira-ticket/` | The `jira-ticket` skill and `standards.md`, the standards every Story, Epic and Spike follows (see Jira tickets) |
| `.chezmoiexternal.toml` | Files downloaded from other repos, pinned to a commit (Claude Code skills) |
| `private_Library/LaunchAgents/` | At login: starts Colima (Docker), loads SSH keys from the keychain into ssh-agent (git signs commits through it) and makes Caps Lock a Control key. Every evening: the Obsidian journal |
| `run_onchange_*` | Re-run `brew bundle`, `mise install` and completion generation when their inputs change, reload the LaunchAgents, register Claude Code's MCP servers, and turn off macOS's `⌃Space` shortcut |

## Claude Code

Installed by mise and updated with `mise upgrade`; its own auto-updater is
turned off (`DISABLE_AUTOUPDATER`) so it doesn't install a second copy outside
mise. `CLAUDE_CONFIG_DIR`, set in mise's config, moves its config from
`~/.claude` and `~/.claude.json` to `~/.config/claude`. mise applies it however
it runs `claude`: in a shell, through its shims (the evening journal) or with
`mise exec`. Sign in once per machine with `claude auth login`.

| Kind of file | Where it lives |
|---|---|
| Settings (theme, env, plugins, marketplaces, permissions, hooks) | Add keys to `.chezmoitemplates/claude-settings.json` (it already makes `chezmoi apply` and `update` always ask first). `modify_settings.json` merges them into the live file, so these values win, and anything Claude Code writes itself (`/model`, `/config`) is kept. Deleting a key here doesn't remove it from the live file; remove it there too. `false`, empty and `0` values can't override a live value either. |
| Plugins | Add `"name@marketplace": true` under `enabledPlugins`. Claude Code installs them at the next session start. |
| Global instructions, rules, agents, commands | Plain files under `dot_config/claude/`. `CLAUDE.md` there says this Mac is managed from this repo; add rules as `dot_config/claude/rules/*.md`. |
| Skills from GitHub | Add an entry to `.chezmoiexternal.toml`, pinned to a commit, with a link to the skill's history so updates can be checked by hand. Your own skills go in `dot_config/claude/skills/<name>/SKILL.md`. |
| MCP servers (user scope) | Claude Code stores these in its own state file, so they're registered by `run_onchange_after_45-claude-mcp.sh.tmpl`: add an `add <name> '<json>'` line there and the server's tool to mise. It replaces a server of the same name; removing a line doesn't unregister it (`claude mcp remove --scope user <name>`). |
| MCP server: agentdb | [AgentDB](https://github.com/ruvnet/agentdb) (`npm:agentdb` in mise), vector memory with reflexion, skills and a causal graph as MCP tools. Work and personal memories are separate databases in `~/.local/share/agentdb/`: `~/.local/bin/agentdb-mcp` starts the server in the session's folder and uses `work.db` when `is-work` says it's work: git's identity there is the work one (the same remote rules as commits) or the folder is inside one of the work folders chezmoi asked for (in git or not), otherwise `personal.db`. Without a work identity everything is personal. To change the work folders, edit `workFolders` (full paths, `;` between them) in `~/.config/chezmoi/chezmoi.toml` and `chezmoi apply`. The global instructions tell Claude to search it before real tasks and store what it learned after (`reflexion_retrieve`, `reflexion_store`); nothing is stored automatically. A session keeps the database it started with, so start Claude in the repo, not in a parent folder of work and personal repos. `/mcp` in Claude Code shows whether it's connected. |
| MCP server: superlogical | [Superlogical's Rex community server](https://www.superlogical.com/rex/docs/beta/community-mcp), hosted over HTTP, so nothing is installed: Rex's docs, every release's changelog, and past and current Rex Beta Discord threads, for reading up on Rex (see Terminal). It signs in with Discord OAuth and needs membership of the Rex Beta Discord: run `/mcp` in Claude Code, pick `superlogical` and sign in, once per machine. Named `superlogical`, not `rex`, as Superlogical recommends, so it doesn't clash with Rex's CLI and skills. |
| Not managed | `.claude.json` (sign-in, per-project state), history, sessions, the plugin cache, and anything synced from your claude.ai account (connectors, synced skills; see [claude.ai connectors](#claudeai-connectors)). |

## claude.ai connectors

Some of this setup only works through connectors in your claude.ai account.
They're connected there (claude.ai → Settings → Connectors), not by this repo,
so a new machine gets them as soon as you sign in to Claude Code with that
account; a missing connector only turns its feature off. Three things to
know:

- Claude Code loads them only in interactive sessions. Headless runs
  (`claude -p`, like the evening journal) can't use them, which is why the
  journal fills its connector sections in the next session you open.
- They belong to the claude.ai account, not to a folder, so they don't follow
  the work/personal split: every session, in any repo, sees the same Google,
  Slack and Atlassian accounts.
- What a connector may do (read only, or also write) is set when you connect
  it, and may be limited by a claude.ai organisation admin or by the service's
  own admin.

| Connector | Access needed | What in cradle depends on it |
|---|---|---|
| Slack | read | The journal's `## Slack` section (conversations you were in, mentions, DMs). |
| Google Calendar | read | The journal's `## Meetings` section and `/journal agenda` (today's meetings as headings to take notes under), and the start-of-session offer for both. |
| Google Drive | read and write | Searching Drive from Claude, and meeting notes docs attached to calendar events, which the journal reads. Write access lets Claude create files. |
| Google Docs | read and write | Creating and editing Docs from Claude. |
| Google Sheets | read and write | Creating and editing Sheets from Claude. |
| Atlassian | read and write (Jira) | Creating Jira tickets from Claude with the `jira-ticket` skill (Stories, Epics and Spikes to a set standard). Read access alone only lets it search and read issues; the skill then hands you the draft to paste. |

## Jira tickets

Ask Claude to create a story, epic or spike ("file a story in PROJ for…") and
the `jira-ticket` skill drafts it to the standards in
[`standards.md`](dot_config/claude/skills/jira-ticket/standards.md):

- **Story:** a verb-first summary, a user story (`As a… I want… so that…`)
  and Given/When/Then acceptance criteria, checked against INVEST; a story
  too big for a sprint gets split or becomes an epic.
- **Epic:** an outcome with the problem, success measures, scope in and out,
  acceptance criteria, risks and a breakdown into stories and spikes.
- **Spike:** `Spike: <question>`, why it matters now, a timebox of at most a
  sprint, the approach, and an output that's a decision plus follow-up
  stories.

You must name the project; Claude never picks one. If the project has no
issue type for what you asked (some have no Spike), it stops rather than
filing it as something else. It asks for what the standard needs and you
didn't say, shows the full draft, and creates it only after your OK, through
the Atlassian connector (see claude.ai connectors). Change the standards in
`standards.md`, here in the repo.

## Obsidian

Work and personal notes are separate vaults. chezmoi asks each machine for
a work vault (only with a work identity) and a personal vault; leave either
blank for none. Claude Code works with them directly as files, with no plugin
or MCP server:

- Both vaults are extra working folders in every session. Claude's
  instructions say to use the one matching the session (work when `is-work`
  says the session's folder is work, otherwise personal) and to reach into
  the other only when asked. Folders you name as private, per vault, are
  blocked for Claude's file tools, and the global instructions forbid reading
  them any other way. Neither the vault paths nor the folder names are in
  this repo.
- **The personal vault** is unstructured and ad hoc: cradle writes nothing
  to it, with no daily notes, templates or journal.
- **The work vault** is structured and automated, as below.
- Daily notes are configured from `obsidian/` in this repo: they live in
  `Daily/` as `YYYY-MM-DD.md` and start from `Templates/Daily.md` (a `date`
  property and `## Notes`, `## Meetings`, `## Terminal`, `## Slack`).
  `Templates/Meeting.md` starts a meeting's notes: `### HH:MM` with the
  current time. Give "Templates: Insert template" a hotkey in Obsidian
  (Settings → Hotkeys), then it's the hotkey, "Mee", Enter. A `run_onchange` script merges the
  settings into the work vault's `.obsidian/` files, keeping anything else set in
  Obsidian, and writes the template; edit them here, not in Obsidian, since
  the next apply overwrites the template. Obsidian picks up the settings when
  it next opens the vault.
- **Meeting notes during the day:** `/journal agenda` (or "add today's
  meetings") puts today's Google Calendar events into `## Meetings` as
  `### 10:00 Title (with who)` headings; type your notes under them, or start
  one with the Meeting template for a meeting that isn't there. Running it
  again adds only new events. On weekdays, Claude offers it once a day: when
  you start it, or at your first message of the day in a session left open
  overnight.
- `/journal [YYYY-MM-DD]` writes that day's daily note sections:
  `## Meetings` (that day's Google Calendar events matched to your notes by
  time, your notes kept as written, plus a short summary under each and your
  action items at the top; attached notes docs are read too),
  `## Terminal` (what you did in each work Claude Code session, grouped by
  project, and your work commits; personal ones are left out) and `## Slack` (conversations you took part in, were
  mentioned in or were sent as DMs, leading with what's waiting on you). It
  creates the note from the template if needed and replaces only its own
  sections, except Meetings, where it merges and keeps your notes. Meetings
  and Slack come from [claude.ai connectors](#claudeai-connectors); a source
  with nothing that day gets `- Nothing.`
- A LaunchAgent runs it every evening at 18:00 (on waking, if the Mac was
  asleep), only if there were work sessions or commits that day. Log:
  `~/Library/Logs/obsidian-journal.log`. That run is headless, and headless
  Claude Code doesn't load claude.ai connectors, so it can't reach Calendar
  or Slack. Instead, a hook (`journal-check`, run when Claude starts and on
  each message, checking once a day) looks at the last weekday's note; if its Meetings section isn't
  summarised yet (marked `%% journal %%`, hidden in reading view) or its
  Slack section is empty, Claude offers once to fill them. The same hook
  offers today's agenda.
- `journal-data [YYYY-MM-DD]` prints what the summary is built from: your
  prompts and Claude's replies (shortened) in work sessions and your commits
  in work git repos up to four folders below home, judged by `is-work`. Shell history is not used.

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
