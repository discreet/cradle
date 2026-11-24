-- Rex: https://www.superlogical.com/rex/docs/customize/config
-- For Rex machines only (the chezmoi question "terminal"). Rex replaces
-- Ghostty + tmux here, so this file gives it tmux.conf's keys: the same
-- C-Space prefix and the same keys after it. Rex's look, Option key and
-- updates are only in its Settings (README: Terminal).
-- Rex doesn't watch this file: after a change, `rex config check`, then
-- `rex config reload` (or prefix r).
--
-- Already like tmux.conf without a binding: copy mode uses vi keys (v, C-v
-- for a block, y copies to the clipboard), new tabs and splits open in the
-- pane's folder, tabs are numbered from 1, the mouse works, and sessions
-- keep running with no window open.

local prefix = "ctrl+space>"
local function bind(key, action, args)
  rex.bind(prefix .. key, action, args)
end

-- Prefix twice sends C-Space itself to the program.
bind("ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Tabs (tmux windows): c new, n/p next/prev, 1-9 jump, w pick, , rename,
-- & close, Tab back.
--
-- Tab, ; and L are tmux's last window, pane and session. Rex 0.1.0-preview.34
-- replaced its per-tab, per-session and per-pane "recent" actions with one
-- history, client.navigate.back, so all three go back to wherever you were
-- last: the previous pane, tab, session or host, not only within one tab.
bind("c", "client.tab.new")
bind("n", "client.tab.next")
bind("p", "client.tab.previous")
for i = 1, 9 do
  bind(tostring(i), "client.tab.goto", { index = i })
end
bind("w", "pane.go_to")
bind(",", "client.tab.rename")
bind("shift+7", "client.tab.close") -- &
bind("tab", "client.navigate.back")

-- Panes: \ splits side by side, - top and bottom; hjkl moves; z zoom,
-- ; back, x close.
bind("\\", "pane.split", { direction = "right" })
bind("-", "pane.split", { direction = "down" })
bind("h", "pane.focus.left")
bind("j", "pane.focus.down")
bind("k", "pane.focus.up")
bind("l", "pane.focus.right")
bind("z", "pane.zoom")
bind(";", "client.navigate.back")
bind("x", "pane.close")

-- C-hjkl resizes by 5 and stays in a resize mode, so more C-hjkl keep
-- resizing like tmux's repeat. Esc or Enter leaves it; other keys do nothing
-- while it's on.
rex.mode("resize", { exclusive = true })
local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
  rex.bind("resize/ctrl+" .. key, "pane.resize", { direction = dir, amount = 5 })
end
rex.bind("resize/enter", "client.mode.exit")
rex.action{
  name = "resize_and_hold",
  title = "Resize Pane and Keep Resizing",
  args = { direction = "string" },
  run = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction, amount = 5 })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}
for key, dir in pairs(dirs) do
  bind("ctrl+" .. key, "resize_and_hold", { direction = dir })
end

-- Sessions: s pick, ( ) prev/next, L back, $ rename, S new, X close (Undo
-- Close, ⇧⌘T, brings it back), d detach (closes the window; the sessions
-- keep running).
bind("s", "session.switch")
bind("shift+9", "session.previous") -- (
bind("shift+0", "session.next") -- )
bind("shift+l", "client.navigate.back")
bind("shift+4", "session.rename") -- $
bind("shift+s", "session.new")
bind("shift+x", "session.close")
bind("d", "client.window.close")

-- Copy: [ copy mode, ] paste. r reloads this file.
bind("[", "pane.copy_mode.enter")
bind("]", "pane.paste")
bind("r", "client.config.reload")

-- Private Rex servers (rex.host{...}) go in local.lua beside this file,
-- which cradle doesn't manage, like ~/.ssh/config.local.
local dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
local f = io.open(dir .. "/local.lua")
if f then
  f:close()
  dofile(dir .. "/local.lua")
end
