---
name: mac-app-screenshots
description: Automated website or App Store screenshots for a macOS app with GrabKit (`make screenshots`). Use when adding or changing a Mac app's screenshot pipeline, its demo or mock data, a screenshot screen, or running and verifying a screenshot run.
---

# Mac app screenshots with GrabKit

A screenshot run is a headed UI test. It launches the app in **screenshot mode** on **mock data**, drives it to each screen, captures it in light and dark, and `grab-export` copies the PNGs out of the result bundle as `NN-slug-light.png` / `NN-slug-dark.png`. [GrabKit](https://github.com/brightdigit/GrabKit) holds every app-independent piece. The app holds only its screens, its accessibility IDs and its mock data.

## The rules

These hold in every app. Each has bitten a real project; [gotchas.md](gotchas.md) says how.

1. **Mock data, never real services.** Screenshot mode fakes everything with real state behind it: network, CloudKit, keychain, the clipboard, app groups, the clock. So the Screenshots build needs no restricted entitlement.
2. **Its own bundle ID.** The `Screenshots` configuration builds `<bundle ID>.Screenshots`, signed ad hoc (`CODE_SIGN_IDENTITY = -`, no team, no profile), with an entitlements file holding only entitlements that need no profile (App Sandbox, network client). The run gets its own container, defaults and privacy permissions, and `XCUIApplication.launch()` can't kill the user's running copy.
3. **`#if SCREENSHOTS` on the app target is the only compile gate.** The app target alone sets `SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) DEBUG SCREENSHOTS` in `Screenshots`. Screenshot code lives in the app's demo package target, which has no `#if DEBUG` and is reached only from `Main.swift`. Xcode builds local packages with Release settings in any configuration whose name lacks "Debug", so `#if DEBUG` in a package is compiled out.
4. **Fail closed.** `Main.swift` calls `GrabLaunchDecision(...).requireScreenshotMode()` first, so a Screenshots build quits unless it carries the `.Screenshots` ID and was launched with `-<Prefix>Screenshots YES`.
5. **Every flag takes a value** (`-<Prefix>Screenshots YES`). AppKit reads arguments as `-Key value` pairs.
6. **Prove the content.** Each screen's drive step waits until the window shows the mock data (an element's value equals the fixture), which proves the shot came from the mock and not real data.
7. **The owner runs it.** `make screenshots` takes over the screen and switches the Mac between Light and Dark. Start a run only when the owner says go, one app at a time. A hung run is left to time out, because killing it leaves "quit unexpectedly" dialogs that show in the next shots.

## Adding the pipeline to an app

Work through these in order. The templates are in [templates/](templates/); replace `My`, `MyApp` and `com.example.MyApp` throughout.

1. **Mock data.** List every service the screens touch and give screenshot mode a fake for each (rule 1). Done when the demo composition creates no live client: grep the demo target for the live types.
2. **Demo target.** Add an `<App>Demo` package target that depends on `GrabSupport` and builds the app's demo composition, plus an `<App>Accessibility` target (no dependencies) holding the `AccessibilityID`s the app sets and the tests query. Pass fixtures in the launch environment (`GrabFixture`), so the app ships no sample content.
3. **Gate.** Copy [templates/Main.swift](templates/Main.swift). Done when a Debug build's binary has no `<App>Demo` symbols: `nm <app binary> | grep -c <App>Demo` prints 0.
4. **Tuist.** Copy [templates/Tuist/](templates/Tuist/): the `Screenshots` configuration (rules 2 and 3), the UI test target `<App>ScreenshotTests` (signed ad hoc, no entitlements) and the `<App>Screenshots` scheme. The `<App>` scheme, `make build` and CI stay unchanged.
5. **Screens.** An `<App>Screenshots` package library (depends on `GrabTesting`) with one `GrabScreen` enum, one case per design, in the design's order ([templates/Screen.swift](templates/Screen.swift)). Each `drive(_:)` waits on content (rule 6) and returns a `GrabTarget`: a window, or a window plus `extras` for menus and sheets.
6. **Tests.** Copy [templates/ScreenshotTests.swift](templates/ScreenshotTests.swift): one test per screen, numbered like the files.
7. **Make.** Copy [templates/Makefile.screenshots](templates/Makefile.screenshots).
8. **Memory.** Copy [templates/screenshot-pipeline.md](templates/screenshot-pipeline.md) into the repo's memory folder and fill in its "Not verified" list.

Done when `swift test` passes for every package, `make build` is unchanged, and the "Not verified" list names everything only a real run can prove.

## Running and verifying

Follow [first-run.md](first-run.md) for every run on a Mac: the checks before it, and the evidence to collect after. To hand the run to another session, fill in [handoff-template.md](handoff-template.md).
