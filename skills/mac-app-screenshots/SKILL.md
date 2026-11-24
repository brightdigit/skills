---
name: mac-app-screenshots
description: Automated website or App Store screenshots for a macOS app with GrabKit (`make screenshots`). Use when adding or changing a Mac app's screenshot pipeline, its demo or mock data, a screenshot screen, or running and verifying a screenshot run.
---

# Mac app screenshots with GrabKit

A screenshot run is a headed UI test. It launches the app in **screenshot mode** on **mock data**, drives it to each screen, captures it in light and dark, and `grab-export` copies the PNGs out of the result bundle as `NN-slug-light.png` / `NN-slug-dark.png`. [GrabKit](https://github.com/brightdigit/GrabKit) holds every app-independent piece. The app holds only its screens, its accessibility IDs and its mock data.

## The rules

These hold in every app. Each has bitten a real project; [gotchas.md](gotchas.md) says how.

1. **Mock data, never real services.** Screenshot mode fakes everything with real state behind it: network, CloudKit, keychain, the clipboard, app groups, the clock. So the Screenshots build needs no restricted entitlement.
2. **Its own bundle ID.** The `Screenshots` configuration builds `<bundle ID>.Screenshots`, signed ad hoc (`CODE_SIGN_IDENTITY = -`, no team, no profile). When the app has entitlements that need a profile (iCloud, keychain groups, push, app groups), the configuration points `CODE_SIGN_ENTITLEMENTS` at a file holding only the profile-free ones (App Sandbox, network client); an app with only profile-free entitlements keeps its own. The run gets its own container, defaults and privacy permissions, and `XCUIApplication.launch()` can't kill the user's running copy.
3. **Decided at runtime; no compile gate.** Every launch asks GrabKit's `GrabLaunchDecision` before it reads any data. A `.Screenshots` build launched with `-<Prefix>Screenshots YES` runs on demo data. A `.Screenshots` build without it quits (fail closed: `exit`, never a trap, never a fallback to live). Any other build runs live and ignores the flag. The demo code ships in every build; only the bundle ID can start it.
4. **No `#if DEBUG` in a package for anything the Screenshots build needs.** Xcode builds local packages with Release settings in any configuration whose name lacks "Debug", so the Screenshots build compiles `#if DEBUG` package code out.
5. **Every flag takes a value** (`-<Prefix>Screenshots YES`). AppKit reads arguments as `-Key value` pairs.
6. **Prove the content.** Each screen's drive step waits until the window shows the mock data (an element's value equals the fixture), which proves the shot came from the mock and not real data.
7. **The owner runs it.** `make screenshots` takes over the screen and switches the Mac between Light and Dark. Start a run only when the owner says go, one app at a time. A hung run is left to time out, because killing it leaves "quit unexpectedly" dialogs that show in the next shots.

## Adding the pipeline to an app

Work through these in order. The templates are in [templates/](templates/); replace `My`, `MyApp` and `com.example.MyApp` throughout.

1. **Mock data.** List every service the screens touch and give screenshot mode a fake for each (rule 1). Done when the demo composition creates no live client: grep the demo target for the live types.
2. **Seam and demo target.** The demo target depends on the app module, so the app module needs a seam it can plug into: a small protocol for the demo session (its fakes, the window background, launch hooks) and a static the app reads when it builds its state, such as `AppDelegate.demoSession`. Nothing in the app module creates a session. Then add an `<App>Demo` package target that depends on `GrabSupport` and the app module and implements the seam, plus an `<App>Accessibility` target (no dependencies) holding the `AccessibilityID`s and the launch prefix (`TC`) shared by the app and the tests. Pass fixtures in the launch environment (`GrabFixture`), so the app ships no sample content. Done when the app module has no `#if DEBUG` screenshot code left.
3. **Launch decision.** Copy [templates/Main.swift](templates/Main.swift). SwiftUI runs the `App`'s `init()` before it creates the `@NSApplicationDelegateAdaptor` delegate, so `init()` runs the decision and, for screenshot mode, sets the seam's static to a *factory*. The delegate calls the factory from its own `init()`: building the session (fakes, observers, the app's state) in `App.init()` is too early, and the app crashes at launch with "Could not find a storyboard named 'Main'". Done when tests show the real bundle ID with the flag stays live and the `.Screenshots` ID with it installs the factory, and the smoke test in [first-run.md](first-run.md) passes.
4. **Tuist.** Copy [templates/Tuist/](templates/Tuist/): the `Screenshots` configuration (rules 2 and 3), the UI test target `<App>ScreenshotTests` (signed ad hoc, no entitlements) and the `<App>Screenshots` scheme. The `<App>` scheme, `make build` and CI stay unchanged.
5. **Screens.** An `<App>Screenshots` package library (depends on `GrabTesting`) with one `GrabScreen` enum, one case per design, in the design's order ([templates/Screen.swift](templates/Screen.swift)). Declare the `GrabScreen` conformance on an `@MainActor` extension, so the drive helpers beside it share the protocol's isolation. Each `drive(_:)` waits on content (rule 6) and returns a `GrabTarget`: a window, or a window plus `extras` for menus and sheets.
6. **Tests.** Copy [templates/ScreenshotTests.swift](templates/ScreenshotTests.swift): one test per screen, numbered like the files.
7. **Make.** Copy [templates/Makefile.screenshots](templates/Makefile.screenshots).
8. **Memory.** Copy [templates/screenshot-pipeline.md](templates/screenshot-pipeline.md) into the repo's memory folder and fill in its "Not verified" list.

Done when `swift test` passes for every package, `make build` is unchanged, and the "Not verified" list names everything only a real run can prove.

## Running and verifying

Follow [first-run.md](first-run.md) for every run on a Mac: the checks before it, and the evidence to collect after. To hand the run to another session, fill in [handoff-template.md](handoff-template.md).
