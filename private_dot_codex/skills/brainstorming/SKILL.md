---
name: brainstorming
description: Explore an ambiguous product, feature, component, or behavior change and turn it into an approved technical design before implementation. Use when the user explicitly asks to brainstorm or when consequential requirements and trade-offs are unresolved; do not use for routine, well-specified edits or pure bug fixes.
---

# Brainstorming Ideas Into Designs

Turn an idea into a clear, appropriately scoped design through collaborative dialogue. Preserve the user's stated choices and do not implement while important product or architecture decisions remain unresolved.

## Workflow

1. Inspect the relevant project context: existing files, documentation, conventions, and recent changes when useful.
2. Assess scope. If the request combines independent subsystems, propose a decomposition and select the first coherent unit to design.
3. Clarify purpose, constraints, and success criteria. Ask one focused question at a time only when the answer materially changes the design; otherwise state reasonable assumptions and continue.
4. Present two or three viable approaches when there is a genuine choice. Lead with the recommendation and explain the important trade-offs.
5. Present the design at a level proportional to its complexity. Cover the relevant architecture, component boundaries, data flow, failure behavior, migration concerns, and testing strategy.
6. Ask for approval before implementation when the design contains consequential choices that the user has not already authorized.
7. If the user wants a persistent specification, write it to their requested location or, by default, `docs/specs/YYYY-MM-DD-<topic>-design.md`. Do not commit it unless the user requests a commit or the surrounding workflow already authorizes one.
8. Review the specification for placeholders, contradictions, ambiguous requirements, excessive scope, and unrequested complexity. Fix concrete problems inline.
9. After approval, either produce an implementation plan or proceed with implementation according to the user's request and the active Codex mode.

Do not force this full workflow onto a small, well-specified change. A brief design and a stated assumption may be enough when risk and ambiguity are low.

## Design Guidance

- Prefer the smallest design that satisfies the stated goal.
- Keep components focused, with clear interfaces and dependencies.
- Follow established project patterns unless changing them directly serves the requested goal.
- Include targeted cleanup only when it is necessary for the work; avoid unrelated refactoring.
- Make acceptance criteria observable and testable.
- Identify destructive migrations, compatibility breaks, security implications, or external side effects before implementation.

## Visual Companion

For genuinely visual questions—such as UI layouts, wireframes, design directions, architecture diagrams, or spatial relationships—you may offer the browser-based visual companion. Do not offer it for ordinary requirements questions, textual trade-offs, or technical choices that are clearer in prose.

Offer it just in time, when the first visual question arises, and wait for the user's consent before opening a browser or starting its server. If accepted, read [visual-companion.md](visual-companion.md) completely before using it.

Run companion scripts from this skill's directory so the relative `scripts/` paths resolve correctly. Browser launch is an external GUI action and may require user approval in the active environment.
