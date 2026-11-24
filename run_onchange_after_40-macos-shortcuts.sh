#!/usr/bin/env bash
# macOS keyboard shortcuts. Re-runs when this file changes.
set -euo pipefail

# hotkey ID ENABLED KEY KEYCODE MODIFIERS
hotkey() {
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" "
  <dict>
    <key>enabled</key><$2/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key><array>
        <integer>$3</integer><integer>$4</integer><integer>$5</integer>
      </array>
    </dict>
  </dict>"
}

# Control-Space ("Select the previous input source") off, so it can't take
# the key before tmux or Rex sees its prefix.
hotkey 60 false 32 49 262144
# Screenshots of a selected area, swapped: Command-Shift-4 copies it to the
# clipboard, Control-Command-Shift-4 saves it as a file.
hotkey 31 true 52 21 1179648 # copy to clipboard: ⌘⇧4
hotkey 30 true 52 21 1441792 # save as file: ⌃⌘⇧4

# Applies the changes without logging out.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
