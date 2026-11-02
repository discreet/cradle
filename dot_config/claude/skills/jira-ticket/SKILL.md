---
name: jira-ticket
description: Draft and create Jira Stories, Epics and Spikes that follow the user's ticket standards (user story with Given/When/Then acceptance criteria and INVEST; outcome-based epics with scope and success measures; timeboxed spikes that end in a decision). Use whenever the user asks to create, file, write, draft or split a Jira ticket, story, epic or spike, including when they describe work and want it "in Jira".
---

# Jira tickets

Every Story, Epic and Spike Claude creates follows [standards.md](standards.md).
Read it before drafting. Other issue types (Bug, Task...) aren't covered:
follow the user's instructions for those.

1. **Project:** the user must name the Jira project (its key, e.g. `PROJ`).
   If they haven't, ask; never guess or pick one from the site.
2. **Type:** Story, Epic or Spike, from what the user asked for or what the
   work is (standards.md says how to tell). Check the project has that issue
   type with the Atlassian tools (`listJiraProjectIssueTypesMetadata`). If
   it doesn't, stop and say so; don't file it as another type.
3. **Draft** the ticket from standards.md: the summary, the description in
   its template, and any parent epic or links the user gave. Use only what the
   user told you or what's in the conversation and code. Where the standard
   needs something you don't have (who the user is, how success is measured,
   the timebox), ask, in one short list; don't invent it.
4. **Check** the draft against the standard's checklist for that type. If it
   fails (a story too big for a sprint, a spike without a timebox), say which
   check fails and propose the fix (split it, make it an epic, add a
   timebox) instead of filing it as it is.
5. **Show the full draft** (type, project, summary, description, parent,
   labels) and wait for the user's explicit OK. Change it as they ask.
6. **Create** it with the Atlassian connector: look up the required fields
   (`getJiraIssueTypeMetaWithFields`) and write the description in the format
   the connector asks for (`getContentFormatGuide`). If creating isn't
   available, the connector is read-only: say so (README: "claude.ai
   connectors") and give the user the draft to paste.
7. **Report** the new key and link. For an epic with a breakdown, or a spike
   with follow-ups, offer to create those stories next, each through steps
   3–6 and linked to it.

Never put secrets, credentials, customer data or personal details in a
ticket.
