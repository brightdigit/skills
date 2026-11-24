# Gotchas

Each of these happened on a real run of Stewed, Mistico or TesserClip.

- **Packages lose `DEBUG` in a custom configuration.** In a configuration whose name doesn't contain "Debug", Xcode builds local packages with Release settings (`-O`, no `-DDEBUG`), even when Tuist declares it `.debug(name:)`. TesserClip's `#if DEBUG` screenshot mode was compiled out and the app quit at launch. Gate with `#if SCREENSHOTS` on the app target.
- **`App.init()` is too early to build app state.** SwiftUI runs it before it creates the delegate, which makes it the place for the fail-closed check, but building the demo session there crashed TesserClip at launch ("Could not find a storyboard named 'Main'"). Register a factory and let the delegate build the session.
- **The demo code ships in Release.** The app target links the demo package target in every configuration, and its protocol conformances and `NSView` subclasses survive dead stripping. Nothing outside `#if SCREENSHOTS` reaches it; check that with `git grep -l 'import <App>Demo'`, not `nm`.
- **Restricted entitlements need a profile.** iCloud, keychain groups, push and app groups work only with a provisioning profile for that exact bundle ID, and an ad hoc build has none. Fake the service instead.
- **`XCUIApplication.launch()` kills the running app** with the same bundle ID. That is one reason for the `.Screenshots` ID.
- **A locked screen** launches the app as "Running Background", and the test fails after 60 s with "Failed to activate application". The result bundle's screen recording shows the lock screen.
- **Stage Manager** scales windows (0.9 seen). `GrabRunner` notes a window that isn't the expected size.
- **Killing a hung run** leaves "quit unexpectedly" dialogs that show in later shots. `GrabRunner` refuses to capture while one is open.
- **Switching appearance stalls** when another busy app is frontmost: XCTest waits for the frontmost app to idle. `GrabRunner` switches while the app under test is still frontmost.
- **Sheets and menus** can be missed by `window.screenshot()`. Return them as `GrabTarget.extras`, which crops a screen capture to the union of frames. An open menu's own frame can run to the bottom of the screen, so pass the menu bar title instead.
- **The standard About panel is a `Dialog`**, not a `Window`: query `app.dialogs`, and pass `checksWindowSize: false` for it and for any window the app doesn't size.
- **Parking the pointer closes a submenu.** The runner moves the pointer off the window before capturing; for an open menu, return `GrabTarget(..., parksPointer: false)`. TesserClip's 05 light shot lost its Substitutions submenu this way, while the dark one kept it by timing.
- **The Mac's appearance must come back.** `XCUIDevice.appearance` can read as `.unspecified`, and restoring that does nothing: a TesserClip run once left the Mac in Dark. `GrabRunner` now restores the appearance it read before the first capture (from `AppleInterfaceStyle` when XCUIDevice can't say). Check `defaults read -g AppleInterfaceStyle` before and after a run.
- **SwiftLint's `empty_count` autocorrect** turns `query.count == 0` into `.isEmpty`, which `XCUIElementQuery` lacks. Use `firstMatch.exists`.
- **Pop-up menus and menu bar items share titles.** Search the pop-up's own menu, not the app's menu bar.
- **XCUI waits ~10 s for the app to idle** after each pop-up pick, so screens with several picks take minutes per appearance.
- **SwiftUI accessibility can recurse.** Mistico's References panel crashed under XCUI with a stack overflow in `AccessibilityNode.accessibilityLabel`. When one screen crashes the app, read its `.ips` crash report before blaming the runner.
- **A bare flag swallows the next argument.** AppKit reads `-Key value` pairs, so every flag carries a value.
