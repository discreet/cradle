# Ticket standards

Based on widely used agile practice: user stories (Connextra format), INVEST,
Given/When/Then acceptance criteria (behaviour-driven development), outcome-
oriented epics, and timeboxed spikes (Extreme Programming, SAFe).

## Which type

- **Story:** one piece of user-visible value (or value to another system or
  team) that a team can finish within a sprint.
- **Epic:** an outcome too big for one sprint, delivered by several stories,
  normally within a quarter. An epic is never worked on directly.
- **Spike:** time-boxed research to answer a question or reduce a risk
  before the work can be estimated or decided. Its result is knowledge (a
  decision, a recommendation, a prototype), not shippable code.

If a "story" can't be finished in a sprint, it's an epic or needs splitting.
If the team can't estimate it because something is unknown, a spike comes
first.

## Story

**Summary:** short and outcome-focused, starting with a verb, under about
70 characters: `Export invoices as CSV`, not `CSV`, `Invoices` or a full
user-story sentence.

**Description:**

```markdown
## User story
As a <specific role>, I want <capability> so that <benefit>.

## Acceptance criteria
1. Given <context>, when <action>, then <observable result>.
2. ...

## Notes
Context, constraints, designs or links the team needs. Optional.

## Out of scope
What this story deliberately doesn't do. Optional.
```

**Checklist (INVEST):**
- **Independent:** can be built and released without waiting on another
  story; any dependency is linked.
- **Negotiable:** says what and why, not how; no implementation steps.
- **Valuable:** the "so that" names a real benefit to the role.
- **Estimable:** nothing unknown blocks an estimate (otherwise, a spike).
- **Small:** fits in one sprint (otherwise, split it: by workflow step,
  business rule, data variation, or happy path first).
- **Testable:** 1–7 acceptance criteria, each Given/When/Then with an
  observable result; no "works well" or "is fast" without a measure.
- The role is a specific user or system, not "user" when a better one exists.
- Linked to its parent epic when it belongs to one.

## Epic

**Summary:** the outcome, not an activity: `Customers can pay by bank
transfer`, not `Payments work`.

**Description:**

```markdown
## Problem
Who has the problem, what it costs them or us, and how we know.

## Outcome
What will be true when this epic is done, in one or two sentences.

## Success measures
How we'll know it worked: metrics with a target, or an observable change.

## Scope
In: ...
Out: ...

## Acceptance criteria
The conditions for calling the epic done (all stories delivered isn't one).

## Dependencies and risks
Other teams, systems, decisions or unknowns. Unknowns get a spike.

## Breakdown
- Proposed stories and spikes, one line each.
```

**Checklist:**
- Problem and outcome are stated in user or business terms, not as tasks.
- At least one success measure that can be checked.
- Scope lists what's out as well as what's in.
- Big enough for more than one sprint, small enough for about a quarter
  (otherwise, split it into several epics).
- The breakdown names the first stories, and a spike for every major unknown.

## Spike

**Summary:** the question, prefixed: `Spike: Can we move sessions to Redis
without downtime?`.

**Description:**

```markdown
## Question
The one question this spike answers, or the risk it reduces.

## Why now
The decision, estimate or story it unblocks (link it).

## Timebox
At most one sprint; usually one to three days. Stop when it runs out.

## Approach
What to try or read: options to compare, prototype to build, people to ask.

## Output
What exists at the end: a decision with its reasons, a recommendation, a
short write-up or prototype, and follow-up stories.

## Acceptance criteria
1. The question is answered (or shown unanswerable) and the answer recorded
   where the team will find it.
2. Follow-up stories are created or updated and linked.
```

**Checklist:**
- Exactly one question, specific enough that "answered" is clear.
- A timebox of at most one sprint.
- The output is knowledge, not production code; any prototype is thrown
  away or turned into stories.
- Linked to the work it unblocks.
