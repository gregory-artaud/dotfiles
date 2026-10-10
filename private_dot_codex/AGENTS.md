# Global frontend/UI/UX defaults

These are personal defaults for frontend work across repositories. Project-specific design tokens, existing design systems, documented UI conventions, Figma-derived rules, and repository or nested `AGENTS.md` instructions take precedence. Infer the existing product language first and adapt these defaults to it.

## UI composition

- Do not use `Card` as the default container for every piece of information.
- Never nest Cards inside Cards unless there is a strong semantic reason.
- Avoid making everything a bordered, rounded rectangle.
- Prefer whitespace, alignment, typography, separators, subtle background changes, and grouping before introducing containers.
- Give pages a clear visual hierarchy rather than a grid of interchangeable widgets.
- Not every section needs a visible boundary.
- Prefer fewer, stronger visual groups over many small isolated components.
- Avoid the stereotypical AI-generated SaaS dashboard aesthetic.

## shadcn/ui

- Treat shadcn/ui as a set of accessible primitives, not as the application's visual identity.
- Do not mechanically use `Card`, `CardHeader`, and `CardContent` for every domain concept.
- Customize composition, spacing, typography, radius, and interaction patterns.
- Compose primitives into a coherent, product-specific interface.

## Visual consistency

Before creating significant UI, infer or establish the application's:

- spacing scale
- typography hierarchy
- radius strategy
- container widths
- surface hierarchy
- border usage
- color roles
- interaction patterns
- motion principles

Reuse these consistently. A new screen should visually feel like it belongs to the same product.

## Motion

When appropriate for a React interface, use Motion from motion.dev if it fits the project's dependencies and conventions.

Animations should communicate state changes, hierarchy, spatial relationships, appearance and disappearance, reordering, navigation transitions, or user feedback.

Prefer subtle layout animations, enter/exit transitions, shared-element or layout transitions, animated height/content changes, hover and press micro-interactions, and stagger only when it improves comprehension.

Avoid arbitrary fade-ins everywhere, excessive bouncing, inconsistent easing curves, and animation that delays interaction. Establish a small, consistent motion language and respect reduced-motion preferences.

## UX completeness

Always consider information hierarchy, primary versus secondary actions, empty states, loading states, errors, disabled states, keyboard navigation, focus states, responsive behavior, touch targets, and progressive disclosure. Do not optimize only for visual appearance.

## Visual review

For significant UI work, valid JSX and CSS are not sufficient completion criteria. When browser or screenshot tooling is available:

1. Run the application.
2. Inspect the rendered page.
3. Check spacing, hierarchy, alignment, overflow, responsiveness, and visual density.
4. Look specifically for unnecessary containers and Cards.
5. Iterate if the result looks generic, cluttered, or visually inconsistent.

Use screenshots when useful to evaluate the final result. Include keyboard, focus, reduced-motion, and representative responsive checks when relevant.

## Design decision rule

Before adding a Card, border, background surface, or wrapper, ask: "Does this element actually need its own visual container?"

If the answer is no, use layout and whitespace instead.
