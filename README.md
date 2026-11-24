# cradle

Configuration for an Apple Silicon Mac, built on three tools:

- [chezmoi](https://chezmoi.io) applies dotfiles from this repo, filling in
  per-machine values (name, email, signing key) through templates.
- [mise](https://mise.jdx.dev) installs every command-line tool: languages,
  Neovim, tmux, kubectl, Claude Code and the rest
  ([config](dot_config/mise/config.toml)). New releases wait a week before
  mise installs them, so a bad release is usually pulled first.
- A [Brewfile](Brewfile.tmpl) covers only what mise can't: bash (the login
  shell), bash-completion, mise itself, and GUI apps (Obsidian, and Ghostty
  unless the machine uses Rex). git is Apple's, from the Command Line Tools.

Each machine picks its terminal when it's set up: Ghostty with tmux (the
default), or Rex (see [Terminal](#terminal-ghostty--tmux-or-rex)).

## Getting started

Setting up a new Mac takes three stages: things to have ready, the bootstrap
run, and a few steps only you can do afterwards.

### Before you start

**The Mac**

- An Apple Silicon Mac, signed in to a user account that's an administrator.
  Homebrew, adding bash to `/etc/shells` and changing the login shell all ask
  for its password.
- iCloud's **Desktop & Documents Folders** turned off (System Settings → your
  name → iCloud → iCloud Drive). Everything lives under `~/Documents`, and
  iCloud syncing breaks git repos there.
- An internet connection. Bootstrap downloads Homebrew, the apps and every
  mise tool.

**Accounts**

- **Personal GitHub account.** Note its noreply email (GitHub → Settings →
  Emails, "Keep my email addresses private"): commits use it, and it keeps
  your real address out of public repos.
- **Work identity** (skip on a personal-only Mac): your work email, the work
  git host (`github.com`, `gitlab.com` or a self-hosted name), your account
  there, and the orgs or groups that are work, exactly as they appear in repo
  URLs, plus your work account's own name if any work repos live under it
  rather than in an org. The orgs are required when the work host is `github.com`, since
  personal repos are there too.
- **Two private repos for the Obsidian vault backups**, with their SSH URLs.
  Each should be empty, or already hold that vault's notes. The personal one
  goes on your GitHub account. The work one goes on the work host, in a work
  org or under your work account (then give that account's name as a work
  org too), so it's committed and pushed as work. Skip a repo to leave that
  vault without a backup.
- **Discord account in the Rex Beta Discord**: needed to download Rex if
  this machine will use it, and optional otherwise, for the `superlogical`
  MCP server.

**Your answers to chezmoi's questions.** Bootstrap asks these once; the
answers stay on the machine in `~/.config/chezmoi/chezmoi.toml`, never in
this repo. The work questions come only when you give a work email; a vault's
other questions only when you give the vault.

| Question | Answer |
|---|---|
| Full name | As on your commits |
| Personal git email | Your GitHub noreply address |
| Work git email | Blank on a personal-only Mac |
| Work git host | e.g. `github.com` |
| Work orgs, groups or accounts | Space-separated, as in repo URLs. Include your work account's own name if work repos live under it (e.g. the work vault's backup repo) |
| Folders for Claude's work memory | `~/Documents/work` |
| Work Obsidian vault folder | `~/Documents/work/Obsidian` |
| Work vault folders Claude must not read | Folder names inside the vault, `;` between them |
| Private git repo for the work vault | Its SSH URL |
| Personal Obsidian vault folder | `~/Documents/personal/Obsidian` |
| Personal vault folders Claude must not read | As above |
| Private git repo for the personal vault | Its SSH URL |
| Terminal | `ghostty` (Ghostty with tmux) or `rex` (Rex, installed by hand) |

### Run bootstrap

In Terminal (Ghostty isn't installed yet), as yourself, not with `sudo`:

```sh
git clone https://github.com/discreet/cradle.git ~/Documents/cradle
~/Documents/cradle/bootstrap.sh
```

On a fresh Mac, `git` first offers to install the Command Line Tools; run the
clone again once they finish. The clone uses HTTPS because the Mac has no SSH
key on GitHub yet. chezmoi remembers where the repo is.

While it runs, be ready for:

- **Your Mac password**, for Homebrew, `/etc/shells` and the login shell
  (some apps may ask too).
- **A passphrase for each new SSH key**: the personal key, and with a work
  identity a work key. It's saved in the macOS keychain, so you type it once.
- **chezmoi's questions**, with the answers above.

What it does, in order: installs Homebrew and mise; creates the personal SSH
key if there isn't one; switches the clone's remote to SSH and turns on the
repo's commit message hook; runs `chezmoi init --apply`, which asks the
questions, installs the Brewfile, writes the dotfiles, runs `mise install`,
registers Claude Code's MCP servers and loads the LaunchAgents; creates the
work SSH key, with a work identity; creates the folder layout (see Folders)
except vault folders with a backup repo, which `vault-sync` clones later;
makes Homebrew's bash your login shell; and installs Neovim's plugins at the
versions in `lazy-lock.json`. It ends by listing the steps below.

### After bootstrap

1. **Add the SSH keys to their accounts.** On GitHub (Settings → SSH and GPG
   keys), add `~/.ssh/id_ed25519.pub` twice: once as an Authentication key
   and once as a Signing key. Add `~/.ssh/id_ed25519_work.pub` to your work
   account on the work host the same way (as a Signing key too, if the host
   supports SSH signatures). Commits show as Verified only when each email you
   gave chezmoi is verified (or is the noreply address) on its account.
2. **Open the terminal.** Ghostty: its first window starts tmux
   (`tmux-pick`). Rex: install it from the tester `.dmg` (Rex Beta Discord),
   then import the Gruvbox Dark theme; cradle has already written its keys
   and other Settings (see [Terminal](#terminal-ghostty--tmux-or-rex)).
   New terminals use Homebrew's
   bash; Caps Lock is already Control.
3. **Sign in to Claude Code:** `claude auth login`, with the claude.ai account
   that has the connectors. The first time you start `claude` in a folder,
   trust it when asked; Claude Code runs no hooks (the journal's) until you do.
4. **Fetch the vaults:** `vault-sync`, once the keys are on their accounts. It
   clones each vault from its backup repo, or makes the first backup if the
   repo is empty.
5. **Open the vaults in Obsidian:** "Open folder as vault" for each vault
   folder. Then run `chezmoi apply` once, so the work vault gets its Daily
   notes settings and templates. Optionally, give "Templates: Insert
   template" a hotkey (Settings → Hotkeys) to start meeting notes quickly.
6. **Let the evening jobs read `~/Documents`** (with a vault): macOS
   blocks LaunchAgents from `~/Documents` unless the program they run has
   Full Disk Access. The journal, backup and daily notes archive agents run
   Homebrew's bash, so give it that access:
   1. `realpath /opt/homebrew/bin/bash` prints the real program, e.g.
      `/opt/homebrew/Cellar/bash/5.3.20/bin/bash`. Add that path, not the
      `/opt/homebrew/bin/bash` link.
   2. System Settings → Privacy & Security → Full Disk Access → `+`, press
      ⌘⇧G, paste the path, Open, and make sure its switch is on.
   Every bash script a LaunchAgent starts with that bash gets the access.
   Homebrew's bash is signed per build, so after `brew upgrade` updates
   bash, add the new path and remove the old one. Without it the evening run
   writes nothing and backs nothing up; its log says so, and the next
   Claude Code session tells you. The morning archive run only logs it
   (`~/Library/Logs/daily-archive.log`); `/journal agenda` archives instead. To try it now:
   `launchctl kickstart gui/$(id -u)/local.obsidian-journal` (or
   `local.vault-sync` without a work vault) runs the evening job, then read
   its log.
7. **Sign in to the cloud CLIs you use:** `gh auth login` (choose SSH as
   the git protocol and skip uploading a key, so git keeps using cradle's
   keys; `gh auth login` again for a second account, `gh auth switch` to
   change), `gt auth --token <token>` (from Graphite's web app),
   `gcloud auth login` and `gcloud auth application-default login` (for
   Terraform and other tools using Google's libraries). Credentials stay on
   the machine.
8. **Optional: Rex's community MCP server.** In Claude Code, `/mcp`, pick
   `superlogical` and sign in with Discord.
9. **Check it all:** `chezmoi status` should print nothing, `mise ls` should
   show every tool installed, and `scripts/check` in `~/Documents/cradle`
   should pass.

From then on, change anything by asking Claude Code in `~/Documents/cradle`
(see Managed with Claude Code).

## Folders

Everything lives under `~/Documents` (not synced to iCloud, which breaks git
repos), split into work and personal:

```
~/Documents/
├── cradle/                 this repo
├── work/                   the work folder for chezmoi's question
│   ├── code/<org>/<repo>   repos, by the org or owner in their remote
│   ├── Obsidian/           work vault
│   └── <topic>/            anything else: exports, prep, files to hand over
└── personal/
    ├── code/<owner>/<repo>
    ├── Obsidian/           personal vault
    └── <topic>/
```

Bootstrap creates `personal/code`, `work/code` (with a work identity) and the
vault folders (`vault-sync` clones those with a backup repo); `<org>` and
topic folders come as you clone and file things.
At `chezmoi init`, answer the work folders question with `~/Documents/work`
and the vault questions with the two `Obsidian/` folders. Everything under
`work/` is then work for Claude (memory, journal, vault), in git or not;
work repos cloned elsewhere still count by their remote. Start Claude
inside `work/` or `personal/` (a repo, a topic, or the folder itself),
never in `~/Documents`: a session's folder decides work or personal for the
whole session, and `~/Documents` holds both.

## Managed with Claude Code

After the first setup, changes are made by asking Claude Code, from any
folder: "add jq", "update everything", "change the tmux status bar". A global
instruction (`dot_config/claude/CLAUDE.md.tmpl`) hands it to the
`cradle-maintainer` agent (see Claude Code), which works in this repo, and
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
| Add an app | add a `cask` to `Brewfile.tmpl`, then `chezmoi apply` |
| Remove a tool or app | delete its line, `chezmoi apply`, then uninstall it by hand (`mise uninstall <tool>`, `brew uninstall --cask <app>`): cradle doesn't uninstall anything yet |
| Update tools | `mise upgrade` (tools set to `latest`; releases under a week old are skipped, `MISE_MINIMUM_RELEASE_AGE=0 mise upgrade <tool>` takes one anyway), then regenerate completions: `chezmoi execute-template <"$(chezmoi source-path)/run_onchange_after_25-completions.sh.tmpl" \| bash`; `brew upgrade` for apps |
| Change a tool version | edit `dot_config/mise/config.toml`, then `chezmoi apply` |
| Pin a version for a project | `mise use kubectl@1.34` inside the project |
| Update Neovim plugins | `:Lazy update` in Neovim, then `chezmoi re-add ~/.config/nvim/lazy-lock.json` (the lock file pins every machine to the same versions) |
| Update a pinned skill | open the history link above its entry in `.chezmoiexternal.toml`, read what changed, put the new commit in its `url`, then `chezmoi apply` |
| Archive past daily notes now | `daily-archive` (the 04:00 run logs to `~/Library/Logs/daily-archive.log`) |
| Back up the Obsidian vaults now | `vault-sync` (the evening run logs to `~/Library/Logs/obsidian-journal.log`, or `vault-sync.log` without a work vault) |
| Refresh GitHub's SSH host keys | only if GitHub rotates them (ssh then refuses to connect): regenerate `private_dot_ssh/known_hosts.github` from the `ssh_keys` list at https://api.github.com/meta |

Docker runs in a [Colima](https://github.com/abiosoft/colima) VM that a
LaunchAgent starts at login (log: `~/Library/Logs/colima.log`), with
`--ssh-config=false` so it leaves `~/.ssh/config` alone (`colima ssh` still
works). `colima stop`
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
  off so it can't take the prefix, tmux's or Rex's
  (`run_onchange_after_40-macos-shortcuts.sh`).
- `⌘⇧4` copies a selected area of the screen to the clipboard, and `⌃⌘⇧4`
  saves it as a file: macOS's two shortcuts swapped, in the same script.
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

## Terminal: Ghostty + tmux, or Rex

chezmoi asks each machine which terminal it uses (`terminal`), and installs
only that one's files:

- **`ghostty`** (the default): Ghostty draws the terminal and tmux keeps
  sessions alive. Ghostty's first window runs `tmux-pick`, which attaches to
  a session. Installs the Ghostty cask, tmux (`dot_config/mise/conf.d/tmux.toml`),
  `tmux.conf`, Ghostty's config and `tmux-pick`.
- **`rex`**: [Rex](https://superlogical.com), from Ghostty's author, does
  both jobs in one app. None of the above is installed. Rex itself isn't
  either: there's no cask yet, so download the tester `.dmg` from the Rex
  Beta Discord. Rex is set up to work like Ghostty + tmux:
  - **Keys:** `~/.config/rex/init.lua` gives Rex `tmux.conf`'s keys on the
    same `⌃Space` prefix (`c`, `n`/`p`, `1`-`9`, `Tab`, `\`, `-`, `hjkl`,
    `⌃hjkl` to resize until Esc, `z`, `;`, `x`, `s`, `(`/`)`, `L`, `S`, `$`,
    `d` to close the window with sessions left running, `[` copy mode with
    vi keys, `]`, `r` to reload). Keep it in step with `tmux.conf`.
    Private Rex servers (`rex.host{...}`) go in `~/.config/rex/local.lua`,
    which `init.lua` loads if it's there and cradle doesn't manage. After
    editing either: `rex config check`, then `rex config reload` (prefix
    `r`; Rex doesn't watch the file). Outside Rex's own terminals the CLI is
    at `~/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex`.
  - **Settings:** Rex keeps them in macOS defaults (`com.superlogical.rex`).
    `run_onchange_after_41-rex-settings.sh.tmpl` writes the ones that differ
    from Rex's defaults: dark appearance, padding Y 10, tabs along the bottom
    (where tmux's status bar was; Rex has no custom status line), cursor style forced,
    Developer Mode on and updates that only notify. Rex's defaults already
    match the rest of Ghostty's config (font size 12, padding X 10, block
    cursor without blinking, Option as Alt). Ghostty's 150×50 window size
    has no Rex setting.
  - **Theme, by hand once per machine:** Rex has no built-in Gruvbox, so
    cradle installs Ghostty's own theme file at
    `~/.config/rex/themes/Gruvbox Dark` (pinned in `.chezmoiexternal.toml`).
    In Settings → Themes → Import Theme, press ⌘⇧G, paste that path, and
    pick it as the Dark Mode theme.

To switch a machine, run `chezmoi init` and give the other answer (or edit
`terminal` in `~/.config/chezmoi/chezmoi.toml`), then `chezmoi apply`. The
old terminal's apps and tools stay installed until you remove them.

Rex is still a beta; the rest of this section is why Ghostty + tmux is the
default, and when Rex can take over. Checked 2026-11-03 against its
[docs](https://www.superlogical.com/rex/docs), changelog and beta feedback
(through the `superlogical` MCP server): still a beta for invited testers,
with new builds almost daily (Mac `0.1.0-preview.25`, Linux server
`preview.12`) and no cask or download script until a public release:

| | Ghostty + tmux (today) | Rex (beta, checked 2026-11-03) |
|---|---|---|
| Sessions outlive the app | Yes, through tmux | Yes: a server keeps sessions running whether or not a client is attached |
| Remote | SSH, with tmux on the far end if wanted | Its own client/server, not SSH: a Rex server on Linux or FreeBSD, reached over Tailscale (or Headscale) or a network listener. Callers are trusted by how they connect; sign-in with SSH keys is planned. No Windows server yet |
| Scrollback and selection | Ghostty's, plus tmux's keyboard copy mode | Native (about 64 MiB scrollback), by mouse or a vi-style keyboard copy mode (`v`, `⌃v`, `y`; added by 2026-11-20) |
| Splits, tabs | tmux panes and windows (prefix `C-Space`) | Panes, tabs and floating windows on Command keys (`⌘D`, `⇧⌘D`, `⌘T`); any key can be rebound, including tmux-style prefix sequences. "Last pane" and tmux-style popups are accepted, not built |
| Extras | Ghostty shell integration, themes | Per-pane activity in tabs (working, blocked, done), asks before closing busy panes, open a session on the web, an iPhone/iPad app paired by QR code, Ghostty/iTerm theme import |
| Config | `dot_config/ghostty/config`, `dot_config/tmux/tmux.conf` | Lua `~/.config/rex/init.lua` holds keys, actions and hosts (`rex config check` / `reload`). Appearance and most other settings are only in the app's Settings; keeping them in a file was deferred, so chezmoi could manage only part of it |
| Updates | mise and Homebrew, when asked | The Mac app updates itself by default (can be turned off in its Settings) |
| Platforms | macOS, Linux | Mac and iOS apps; Linux and FreeBSD server. Linux and Windows apps not in testing |
| License | Both open source | Closed source and unfree; free to use, with no telemetry, account or license checks |
| Install | Brewfile cask, mise | Testers only: a Mac `.dmg`, iOS through TestFlight, Linux packages behind a Discord sign-in. More install options promised for the public release |

A Rex machine has no tmux, `tmux-pick` or `tmux.conf`; `init.lua` keeps the
`C-Space` prefix and its keys.

### What Rex needs before it's the default

Make `rex` the default answer when every row is met. The list covers what this setup and the way
it's run need, not tmux or Ghostty habits: with Rex, its own keys and ways of
working get learned from scratch. ✅ met, ◐ partly or unconfirmed, ❌ not
yet. Status as of 2026-11-03.

| | Rex must | Because | Status |
|---|---|---|---|
| 1 | Have a stable public release, with no open crash or input bugs in daily use | Daily tools here aren't betas; mise even waits a week before taking a new release | ❌ Tester previews only; the stable channel has no releases yet |
| 2 | Install and update from this repo: a Homebrew cask, or a mise tool for the CLI | Every app is a Brewfile cask and every CLI tool is in mise | ❌ A `.dmg` for testers; "more installation options for public release" |
| 3 | Update only when asked | Updates are run on purpose (Updating everything); Claude Code's own updater is off | ◐ Self-installs by default; turning that off is a Settings switch behind Developer Mode, not a file |
| 4 | Keep every setting in files chezmoi can manage: look (theme, font, padding, cursor), Option as Alt, keys, hosts | Claude makes every change in this repo; nothing is set by hand | ◐ `init.lua` holds keys, actions and hosts; Settings are plain `defaults` keys, written by a `run_onchange_` script (2026-11-20). Only importing a theme is still by hand |
| 5 | Let Claude check a config change without touching live sessions | Changes are tested in a throwaway home and an isolated tmux server, never on the live one | ◐ `rex config check <file>` checks a draft; an isolated test server is unconfirmed |
| 6 | Run Neovim fully: true colour, focus events (reload changed files), Option as Alt, Ctrl keys | Neovim is the editor; Option is Alt for word movement in bash and Neovim | ◐ Option-as-Alt setting exists (broken in floating panes); an open bug shifts true-colour values |
| 7 | Copy text from output and scrollback without the mouse, in whatever way Rex chooses | Work is keyboard-driven (Neovim, arrow keys off) | ✅ A vi-style copy mode (2026-11-20) |
| 8 | Keep sessions running after the window or app closes, and get back to them at launch | Work is left running between days | ✅ The server keeps sessions; a session picker and "new session on launch" exist |
| 9 | Work over plain SSH to hosts without Rex | Work and personal hosts are reached with SSH keys, per identity | ✅ `rex terminfo setup` / `host install` handle `TERM` |
| 10 | Copy from a remote program to the Mac clipboard | Copying from remote shells (OSC 52) | ✅ OSC 52 works; remote-Mac clipboard bugs are open |
| 11 | If persistent remote sessions are wanted: sign in to a remote Rex server with SSH keys, on any host, and let programs there use the Mac's clipboard | Work can be any git host, reached with its own key; Tailscale can't be assumed there. Neovim keeps its own registers and reaches the Mac clipboard only through `"+` | ❌ Tailscale or no authentication; SSH-key sign-in planned. On a remote server `"+` (`pbcopy`) lands on that machine's clipboard, not this Mac's (open request); on Linux, Neovim would need its OSC 52 clipboard set up |
| 12 | Set up Claude Code's Rex skill and hook inside this repo's Claude config | Claude Code runs in the terminal all day, from `~/.config/claude` (`CLAUDE_CONFIG_DIR`), managed by chezmoi | ✅ Rex sets them up itself at first launch, in `~/.config/claude`; both are now in the repo for Rex machines (2026-11-20) |
| 13 | Need no account and send no telemetry | Nothing here phones home or needs a sign-in to run | ✅ No telemetry, account or licence checks |

To recheck, ask Claude: it reads Rex's docs, changelog and feedback through
the `superlogical` MCP server.

## Layout

| Path | What it configures |
|---|---|
| `Brewfile.tmpl` | Homebrew formulae and apps; a template, so Ghostty is left out on Rex machines |
| `CLAUDE.md`, `.claude/settings.json` | How Claude Code maintains this repo, and which commands it may run here without asking. Not copied to `~` |
| `dot_config/claude/skills/journal/`, `dot_local/bin/executable_journal-data`, `dot_local/bin/executable_obsidian-journal`, `dot_local/bin/executable_journal-check.tmpl`, `private_Library/LaunchAgents/local.obsidian-journal.plist.tmpl` | The work vault's journal (see Obsidian); installed only when a work vault is set |
| `dot_local/bin/executable_daily-archive.tmpl`, `private_Library/LaunchAgents/local.daily-archive.plist.tmpl` | Moves the work vault's past daily notes into month and week folders every morning (see Obsidian); installed only when a work vault is set |
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
| `dot_config/tmux/tmux.conf`, `dot_config/mise/conf.d/tmux.toml` | tmux (prefix `C-Space`; the built-in keys it relies on are listed at the top) and its install. Ghostty + tmux machines only |
| `dot_config/ghostty/config` | Ghostty (Gruvbox dark). Its first window at launch runs `tmux-pick`. Ghostty + tmux machines only |
| `dot_config/rex/init.lua` | Rex's keys (`tmux.conf`'s, on the same `C-Space` prefix), actions and hosts; loads the unmanaged `local.lua` beside it. Rex machines only, with the Gruvbox Dark theme file from `.chezmoiexternal.toml` |
| `dot_local/bin/executable_vault-sync.tmpl`, `private_Library/LaunchAgents/local.vault-sync.plist.tmpl` | Backs up each Obsidian vault to its private git repo (see Obsidian); installed only when a vault repo is set. The LaunchAgent only without a work vault; with one, the journal's evening run starts the backup |
| `dot_local/bin/executable_agentdb-mcp`, `dot_local/bin/executable_is-work.tmpl` | `~/.local/bin/agentdb-mcp`: starts agentdb's MCP server on the work or personal database (see Claude Code). `~/.local/bin/is-work [folder]`: exits 0 when a folder is work (git's identity there, or inside a work folder); agentdb, the journal and Claude's choice of vault all use it |
| `dot_local/bin/executable_claude-agents` | `~/.local/bin/claude-agents`: Claude Code's SessionStart hook that shows you the custom agents a session can use (see Claude Code) |
| `dot_local/bin/executable_tmux-pick` | Ghostty + tmux machines only. `~/.local/bin/tmux-pick`: lists tmux sessions, most recent first, to attach to or start a new one; starts one straight away if there are none. Esc or leaving tmux drops to a plain shell |
| `dot_config/claude/`, `.chezmoitemplates/claude-settings.json` | Claude Code (see below) |
| `.chezmoiexternal.toml` | Files downloaded from other repos, pinned to a commit (Claude Code skills, Rex's Gruvbox Dark theme) |
| `private_Library/LaunchAgents/` | The Obsidian ones run their script with Homebrew's bash, which needs Full Disk Access to read `~/Documents` (see After bootstrap). At login: starts Colima (Docker), loads SSH keys from the keychain into ssh-agent (git signs commits through it) and makes Caps Lock a Control key. Every morning at 04:00: archives the work vault's past daily notes. Every evening at 18:00: the Obsidian journal, then the vault backups |
| `run_onchange_*` | Re-run `brew bundle`, `mise install` and completion generation when their inputs change, reload the LaunchAgents, register Claude Code's MCP servers, turn off macOS's `⌃Space` shortcut and make `⌘⇧4` copy to the clipboard, and write Rex's Settings (Rex machines) |

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
| Global instructions, rules, agents, commands | Plain files under `dot_config/claude/`. `CLAUDE.md` there says this Mac is managed from this repo; add rules as `dot_config/claude/rules/*.md` and agents as `dot_config/claude/agents/<name>.md`. |
| Rex (Rex machines) | Rex's `rex` skill (`dot_config/claude/skills/rex/`, the stub `rex skill setup` writes; it reads its guide from the installed `rex`) and its SessionStart hook (`modify_settings.json`), which tells Rex which session Claude runs in. Rex adds both itself at first launch; they're in the repo so applying doesn't remove them. |
| Agent list at session start | `~/.local/bin/claude-agents`, a SessionStart hook (`modify_settings.json`, every machine) on startup, `/resume` and `/clear`. It shows you, not Claude, the custom agents the session can use, as `SessionStart:startup says: User agents: ...`: user agents from `~/.config/claude/agents/` and project agents from every `.claude/agents/` between the session's folder and its repo root, each with its name and the first sentence of its description. It follows symlinks, skips broken links and files without a name and description, and lists an agent once where Claude Code would use only one (the closest project agent; a project agent over a user one of the same name). It reads the files at each start, so it lists agents this repo doesn't manage too, and prints nothing when there are none. Built-in agents aren't listed. |
| Agent: cradle-maintainer | `dot_config/claude/agents/cradle-maintainer.md`, the expert on this repo. Every session hands it setup changes and questions, from any folder. It reads this README and CLAUDE.md before each task rather than repeating them, so it can't drift from them. It edits, updates the docs and runs `scripts/check`, then stops and returns a summary of `chezmoi diff`; the session runs `chezmoi apply` (your OK) and messages it back to check the result, commit and push. Opus. |
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

- Some arrive under another name: Slack can come as the Slack plugin
  (`mcp__plugin_slack_slack__*`) instead of the connector
  (`mcp__claude_ai_Slack__*`), so what uses Slack accepts both.
- What a connector may do (read only, or also write) is set when you connect
  it, and may be limited by a claude.ai organisation admin or by the service's
  own admin.

| Connector | Access needed | What in cradle depends on it |
|---|---|---|
| Google Calendar | read | The journal's `## Meetings` section (the evening run and the start-of-session catch-up) and `/journal agenda` (today's meetings as headings to take notes under). |
| Google Drive | read and write | Searching Drive from Claude, and meeting notes docs attached to calendar events, which the journal reads. Write access lets Claude create files. |
| Google Docs | read and write | Creating and editing Docs from Claude, and reading meeting notes for the journal. |
| Google Sheets | read and write | Creating and editing Sheets from Claude. |

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
  to it, with no daily notes, templates or journal. Its `cradle.md` note
  holds private notes about this setup that every machine needs but this
  public repo can't hold (Claude reads and adds to it; see Memory).
- **Backups:** Obsidian doesn't sync between machines here; each vault is
  its own private git repo instead (chezmoi asks for the SSH URLs). Create
  them empty first: the personal one on your GitHub account, the work one on
  the work host, in a work org or under your work account listed among the
  work orgs, so git commits and pushes with the work identity. `vault-sync` runs every evening at 18:00, started by the
  journal's run once today's note is written (on a machine without a work
  vault, by its own LaunchAgent); again after the journal skill fills in the
  Slack and Meetings summaries in your next session (Claude may run it
  without asking); and on demand. It commits what changed, rebases onto anything another machine
  pushed and pushes. Obsidian's window layout (`workspace.json`) and trash
  stay out. On a new machine it clones each vault into its folder. If two
  machines changed the same lines, it leaves the vault as it was and shows a
  notification; resolve it with git in the vault. The journal leaves the
  vaults' backup commits out.
- **The work vault** is structured and automated, as below.
- Daily notes are configured from `obsidian/` in this repo: today's is
  `Daily/YYYY-MM-DD.md` and starts from `Templates/Daily.md` (a `date`
  property and `## Notes`, `## Meetings`, `## Terminal`, `## Slack`).
- **Meeting notes during the day:** `/journal agenda` (or "add today's
  meetings") first archives the past daily notes (above), then puts today's
  Google Calendar events into `## Meetings` as
  `### 10:00 Title (with who)` headings; type your notes under them, or start
  one with the Meeting template for a meeting that isn't there. Running it
  again adds only new events. On weekdays, Claude does it once a day without
  asking, saying so in one line: when you start it, or at your first message
  of the day in a session left open overnight.
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
- `journal-data [YYYY-MM-DD]` prints what the summary is built from: your
  prompts and Claude's replies (shortened) in work sessions and your commits
  in work git repos up to four folders below home, judged by `is-work`. Shell history is not used.

## What changed from the old setup

| Old setup | Now |
|---|---|
| `bash` | Same drop-in folder, moved to `~/.config/bash/rc.d`. The prompt shows path and git state via git's own `__git_ps1` (`*` unstaged, `+` staged, `%` untracked), `user@host` only over SSH, and a red `❯` after a failed command; the kube namespace and terraform workspace are gone. History is timestamped and saved per command but no longer shared live between open shells. A readline `inputrc` adds case-insensitive completion and prefix history search on Up/Down and `C-p`/`C-n`. `go install` targets `~/.local/bin`. Completions are generated once and lazy-loaded by bash-completion@2. `KUBECONFIG` is back to the default `~/.kube/config` |
| `asdf` | mise |
| `go`, `kubectl`, `helm`, `terraform` | mise (`latest` globally, pinned per project) |
| `python`, `miniconda`, `base-env.yaml` | uv; Python versions and environments are per project. mise keeps one global Python, pinned to the version gcloud needs |
| `ruby`, `rust` | Dropped (Rust was only there to build Alacritty) |
| `packages` | mise for CLI tools, Brewfile for apps. Homebrew git is replaced by Apple's. Removed: `ack` (use ripgrep), `tree`, `exa`, `aws-iam-authenticator` (use `aws eks get-token`), compiler libraries asdf needed, `ansible`, `argo`, `mkdocs`, `ctags`, `brew-cask-completion`, `curl`, `wget`, `make`, `telnet`, `watch`, `ncdu`, `gopass`, `ccrypt`, `aws-vault`, `coreutils`, `gnu-sed`, `gnu-tar`, `jq` (macOS ships it), `yq`, `kubectx` (use k9s or `kubectl config`), `bats-core`, and the Keybase, Signal, Chrome, Hammerspoon and Karabiner apps |
| `vim` | Neovim. NeoBundle is now lazy.nvim. ALE, vim-go and black are now LSP and conform, with Neovim's built-in completion. Helm charts get helm-ls and Compose files get Docker's language server (filetype rules in `lua/config/filetypes.lua`). polyglot and the syntax plugins are replaced by Neovim's built-in syntax highlighting. ack.vim is now fzf-lua. gitgutter is now gitsigns. Dropped: fugitive, surround, repeat, endwise, targets, tabular, indent guides, vim-test, markdown-preview and TypeScript support |
| `git` | Separate personal (GitHub) and work (any git host) identities, chosen by the repo's remote. Commits and tags are signed with SSH, not GPG. `git pull` rebases instead of merging. Current git settings are added (zdiff3, histogram diff, autoSetupRemote, etc.); settings that are now git's or Apple's defaults are dropped. Aliases that duplicated others or that signing-by-default made redundant (`ca`, `amend`, `ci`, `cs`, `csa`, `ris`, `tsa`, `dc`, `head`, `fap`, `r`, `ra`, `lg`, `lgs`) are removed, as are the rarely used `rero`, `rht`, `dh1`, `ff`, `ms`, `mc`, `ignore`/`ignored`/`acknowledge`, and the plain shortcuts `co`, `sw`, `b`, `aa`, `di`, `ds`, `rc`, `fa`, `dlb`, `drb`. Fetch no longer prunes local tags. The log aliases share one `--pretty=line` format |
| `gpg` | Dropped. SSH keys go in the macOS keychain instead of gpg-agent |
| `tmux` | Same prefix (`C-Space`), colours and `hjkl` pane movement. Splits are now `\` and `-`, resizing moved to `Ctrl-hjkl` so `L` jumps back to the last session again, and `S` creates a named session. Windows and panes are numbered from 1; mouse support is on; copy mode uses vi-style `v`/`y` (to the macOS clipboard through Ghostty). The status bar shows the session name instead of the kube context, plus a PREFIX flag and the date. Settings tmux removed or now defaults are dropped, and `reattach-to-user-namespace` is gone |
| `alacritty` | Ghostty, with its built-in `Gruvbox Dark` theme (the same palette). Block cursor everywhere, including the prompt; Option works as Alt. The first window at launch opens a tmux session picker |
