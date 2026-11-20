-- Rex: https://www.superlogical.com/rex/docs/customize/config
-- For Rex machines only (the chezmoi question "terminal"). This file holds
-- keys (rex.bind), actions (rex.action) and hosts (rex.host). Rex's look,
-- Option key and updates are only in its Settings (README: Terminal).
-- Rex doesn't watch this file: after a change, `rex config check`, then
-- `rex config reload`.
--
-- No key bindings yet: Rex's own keys are learned as they come, not
-- recreated from tmux.

-- Private Rex servers (rex.host{...}) go in local.lua beside this file,
-- which cradle doesn't manage, like ~/.ssh/config.local.
local dir = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex"
local f = io.open(dir .. "/local.lua")
if f then
  f:close()
  dofile(dir .. "/local.lua")
end
