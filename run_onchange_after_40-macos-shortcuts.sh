#!/usr/bin/env bash
# Turns off macOS's Control-Space shortcut ("Select the previous input
# source"), which would take the key before tmux sees its prefix. Re-runs when
# this file changes.
set -euo pipefail

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 '
  <dict>
    <key>enabled</key><false/>
    <key>value</key><dict>
      <key>type</key><string>standard</string>
      <key>parameters</key><array>
        <integer>32</integer><integer>49</integer><integer>262144</integer>
      </array>
    </dict>
  </dict>'
# Applies the change without logging out.
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
