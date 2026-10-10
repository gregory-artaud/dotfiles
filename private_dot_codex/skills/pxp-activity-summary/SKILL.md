---
name: pxp-activity-summary
description: Generate a concise French summary of Grégory's PXP work since a supplied date from his related sent Gmail replies, GitHub pull requests, and assigned Trello cards. Use for preparing SR activity notes for Project X Paris.
---

# PXP activity summary

Produce a concise French activity summary from a user-supplied start date through today. If the start date is missing, ask for it.

Use the connected Gmail, GitHub, and Trello tools read-only.

## Sources

### Gmail

Review messages sent by the authenticated user since the start date. Keep a sent message when either:

- it belongs to a thread containing a message labelled `PXP`; or
- a recipient has an `@projectxparis.fr` address.

Because Gmail labels individual messages rather than every sent reply, correlate labelled messages and sent messages by thread ID. Read enough of each relevant thread to identify the concrete action performed.

Only attribute work supported by the user's own sent message. Do not credit the user for a request they merely received, a thread where they were only copied, or work explicitly performed by a colleague.

### GitHub

Review pull requests authored by `@me` in:

- `galadrimteam/pxpr-monorepo`
- `galadrimteam/pxpr-operations`

Include the union of PRs created since the start date and PRs merged since the start date. Report how many were created and merged, how many remain open, and how many were closed without merging. Group the work into a few meaningful themes from PR titles and descriptions instead of listing every PR.

### Trello

Identify the authenticated Trello member, then review open and archived cards assigned to that member. Keep cards created or updated during the requested period. Read enough card detail to capture the concrete subject, and include the card link.

Use Trello to catch relevant work that may not have produced a PR or email. Avoid repeating the same item when a card clearly corresponds to a PR already summarized.

## Output

Write in French and follow this compact structure:

1. A short opening sentence describing the dominant activity.
2. `### Synthèse` with the GitHub counts.
3. `### Principaux chantiers` with concise bullet points grouped by theme.
4. A short list of representative PR links.
5. The PRs still open, when any exist.
6. `### Tickets Trello` with short bullets for relevant assigned cards, when any exist.
7. `### Côté support par mail` with the concrete support actions found in sent mail.
8. A final `En une phrase` summary suitable for reuse in an SR.

Keep the result useful as speaking notes: concise but specific, with no exhaustive PR inventory, methodology explanation, or speculative attribution.
