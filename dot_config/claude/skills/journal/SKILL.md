---
name: journal
description: Write or refresh the "Meetings", "Terminal" and "Slack" sections of a daily note in the user's work Obsidian vault, summarising a day's Google Calendar meetings (with the user's own notes), work Claude Code sessions, work git commits and the Slack conversations the user took part in or was mentioned in. Also adds today's meetings to the note as headings to take notes under (`/journal agenda`). Use when the user asks to journal, log or summarise their day (or a given date) into Obsidian, or to add today's meetings or agenda to their daily note; the evening LaunchAgent also runs it.
---

# Journal

Two modes: **agenda** (`/journal agenda`, or "add today's meetings") puts
today's meetings into the note so the user can take notes under them; the
**summary** (`/journal [YYYY-MM-DD]`) writes the day's sections.

## The Meetings section

Shared by both modes. The user takes notes here during the day; never change
or remove their text. It looks like this:

```markdown
## Meetings
**Action items**
- [ ] Send the rollout plan to Dana (Platform sync)

### 10:00 Platform sync (with Dana, Lee)
- user's own notes, untouched
> [!summary]
> - Decided: roll out on Thursday.

### 14:05 Vendor call
- user's own notes
%% journal %%
```

- Meeting headings are `### HH:MM Title (with who)`, in time order, naming a
  team or a few people rather than every guest. The user also adds headings
  as `### HH:MM` plus a few words of their own (from `Templates/Meeting.md`),
  possibly before the meeting's real start time.
- Yours to write and rewrite: the meeting headings, the `**Action items**`
  list at the top, the `> [!summary]` callout at the end of a meeting, and the
  marker on the section's last line: `%% agenda %%` once the agenda is in,
  `%% journal %%` once it's summarised. Everything else is the user's.
- **Matching** a user heading to an event: the event in progress at that
  time, else the one starting within 15 minutes after it. Rewrite a matched
  heading in the format above, keeping the user's notes under it. Leave a
  heading that matches no event as it is (an unscheduled meeting). Never put
  two headings for the same event; merge by moving the user's text under one.

## Agenda

1. **Day:** today. Skip if Google Calendar tools
   (`mcp__claude_ai_Google_Calendar__*`) aren't available, and say so.
2. List today's events (see "Which events" below).
3. Find or create today's note (below), then add a heading for every event
   that has none, in time order, matching existing headings as above. Keep
   everything already in the section, and end it with `%% agenda %%` unless
   it already ends with `%% journal %%`. Running it again later in the day
   adds only new events.

## Summary

1. **Day:** today, unless the user names a date. Use `YYYY-MM-DD`.
2. **Terminal:** run `journal-data <day>`. It prints each work Claude Code
   session of that day (folder, the user's prompts and Claude's replies,
   shortened) and the user's commits in work git repos. Personal sessions
   and repos are left out on purpose; never add them.
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
4. **Meetings**, only if Google Calendar tools are available; otherwise leave
   the Meetings section exactly as it is and say so. List the day's events
   (see "Which events"). If an event has meeting notes attached (a Google
   Doc) and Google Drive tools are available, read them too.
5. If there are no meetings, sessions, commits or Slack messages, say so and
   stop.
6. **Write the sections.** Keep each short enough to skim in a minute, and use
   `[[wikilinks]]` only to notes that already exist in the vault.
   - `## Meetings`, as described above: a heading for every event, matched to
     the user's headings. Under each meeting the user took notes for (or that
     has attached notes), a `> [!summary]` of a bullet or two: what was
     decided and what the user is to do. Collect the user's action items from
     all meetings in `**Action items**` (`- [ ]`, with the meeting in
     brackets). End with `%% journal %%`.
   - `## Terminal`, grouped by project or repo: a few bullets on what was done
     and why, decisions made and anything left open (not a list of commands),
     then the commits, one line each: `abc1234 subject`.
   - `## Slack`, grouped by channel or DM: what each conversation was about,
     what was decided, and what's still waiting on the user (questions put to
     them, requests, follow-ups they promised). Lead with anything waiting on
     the user.
   - A source you checked that had nothing gets one line, `- Nothing.` (in
     Meetings, keep any notes and still end with `%% journal %%`). Leave a
     source you couldn't reach as it is: the next interactive session offers
     to fill it.
7. **Update the note:** replace Terminal and Slack if the note has them (up to
   the next `## ` heading) and touch nothing else; otherwise append them.
   Merge Meetings as described above instead of replacing it.

## Which events

The user's primary calendar for the day. Keep the events they organised or
didn't decline; leave out all-day events (out of office, holidays, working
location) and blocks with no other guests (focus time).

## Finding or creating the note

The work vault is named in your global instructions; the journal is only
ever written there, never to the personal vault. Read
`<vault>/.obsidian/daily-notes.json` if it exists: `folder` is where daily
notes live (default: the vault root) and `format` is the file name as a
Moment.js date format (default `YYYY-MM-DD`). If the note doesn't exist,
create it from the template named by `template` there (`<vault>/<template>.md`),
with `{{date}}`, `{{date:FORMAT}}` and `{{title}}` filled in for that day.
Without a template, create the note with only the sections you write. If the
note has no `## Meetings`, add it before `## Terminal` (or at the end).

## Leave out

Secrets (tokens, passwords, keys, connection strings, meeting passcodes,
meeting links and dial-in numbers), anything from vault folders you must not
read, and details about other people beyond what the work needs.
