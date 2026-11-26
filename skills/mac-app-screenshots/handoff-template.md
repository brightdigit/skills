# Handoff: run and verify `make screenshots` for <App> (#<issue>)

You're picking up <App>'s screenshot pipeline. The code is written but has never run on a Mac. Run it here, fix what breaks, and report exactly what each PNG shows.

## Where things are

- **Issue #<issue>:** the plan and the settled decisions. Don't reopen them.
- **PR #<pr> (`<branch>`):** <what it contains>.
- **`<memory folder>/screenshot-pipeline.md`:** how the pieces fit, and the "Not verified" list. Read it first.
- **The `mac-app-screenshots` skill:** the rules, `first-run.md` and `gotchas.md`.

## Setup

Work in a worktree for `<branch>`. Merge only, never rebase or force-push. Push with `git push -u origin HEAD`.

## The run and the evidence

Follow the skill's `first-run.md`. Expect <N> PNGs in `build/screenshots/`: <NN-slug list>, each as `-light` and `-dark`.

## Likely failures

<The memory note's "Not verified" list, one numbered item each, with where to look.>

Raise anything that would add an entitlement, a bundle ID or a real service before changing it.

## Finish

- Update the memory note: move each "Not verified" item to what was found, with the date.
- Update the PR's Evidence section with what you ran and saw. Leave it as a draft.
- Report each PNG (name, pixel size, what it shows, any defect), the mock-data evidence, and anything still open.
