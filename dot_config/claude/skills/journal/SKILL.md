---
name: journal
description: Write or refresh the "Terminal" and "Slack" sections of an Obsidian daily note, summarising a day's Claude Code sessions, git commits and the Slack conversations the user took part in or was mentioned in. Use when the user asks to journal, log or summarise their day (or a given date) into Obsidian; the evening LaunchAgent also runs it.
---

# Journal

1. **Day:** today, unless the user names a date. Use `YYYY-MM-DD`.
2. **Terminal:** run `journal-data <day>`. It prints each Claude Code session
   of that day (folder, the user's prompts and Claude's replies, shortened)
   and the user's commits in their git repos.
3. **Slack**, only if Slack tools (`mcp__claude_ai_Slack__*`) are available;
   otherwise leave Slack out and say so. With `slack_search_public_and_private`
   (`sort: timestamp`, `response_format: concise`, following `cursor` until
   there are no more pages):
   - messages the user sent: `filters: "from:<@USER_ID> on:<day>"`;
   - messages mentioning them: `keywords: ["<@USER_ID>"]`, `filters: "on:<day>"`;
   - DMs and group DMs they received: `filters: "on:<day>"`,
     `channel_types: "im,mpim"`.
   The user's ID is in the search tool's description, or from
   `slack_read_user_profile`. Read a thread with `slack_read_thread` only when
   the search results don't make the conversation clear.
4. If there are no sessions, commits or Slack messages, say so and stop.
5. **Find the daily note:** the vault is named in your global instructions.
   Read `<vault>/.obsidian/daily-notes.json` if it exists: `folder` is where
   daily notes live (default: the vault root) and `format` is the file name
   as a Moment.js date format (default `YYYY-MM-DD`).
6. **Write the sections.** Keep each short enough to skim in a minute, and use
   `[[wikilinks]]` only to notes that already exist in the vault.
   - `## Terminal`, grouped by project or repo: a few bullets on what was done
     and why, decisions made and anything left open (not a list of commands),
     then the commits, one line each: `abc1234 subject`.
   - `## Slack`, grouped by channel or DM: what each conversation was about,
     what was decided, and what's still waiting on the user (questions put to
     them, requests, follow-ups they promised). Lead with anything waiting on
     the user.
7. **Update the note:** for each section, replace it if the note has it (up to
   the next `## ` heading) and touch nothing else; otherwise append it. If the
   note doesn't exist, create it from the template named by `template` in
   `daily-notes.json` (`<vault>/<template>.md`), with `{{date}}`,
   `{{date:FORMAT}}` and `{{title}}` filled in for that day, then fill its
   sections. Without a template, create the note with only these sections.
8. **Leave out** secrets (tokens, passwords, keys, connection strings, meeting
   passcodes), anything from vault folders you must not read, and details
   about other people beyond what the work needs.
