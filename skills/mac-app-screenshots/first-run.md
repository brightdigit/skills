# Running and verifying a screenshot run

Run only when the owner says go. Record what you saw; claim nothing you didn't check.

## Before the run

1. The screen is unlocked and nothing covers the top left. A locked Mac launches the app in the background and the test fails with "Failed to activate application" after 60 s.
2. No "quit unexpectedly" dialog is open (`pgrep -x "Problem Reporter"` prints nothing). Dismiss any that are.
3. No other app's screenshot run is going: two runs fight over the screen and the appearance.
4. The system language is English, since the drive steps find menus by their titles.
5. Note the real app's data timestamps (its container's files), to show afterwards that they didn't change, and the Mac's appearance (`defaults read -g AppleInterfaceStyle`: `Dark`, or an error for Light).
6. Start a log capture: `/usr/bin/log stream --predicate 'subsystem == "<bundle ID>.Screenshots"' --level debug > build/screenshots-log.txt`
7. On the first run, macOS may ask to let Xcode control the computer. The owner approves it.
8. Smoke-test the launch, which takes seconds instead of a full run's minutes. Build with `xcodebuild … -configuration Screenshots build-for-testing`, then:
   - `open -n -a <Screenshots app> --args -<Prefix>Screenshots YES`: the app stays up and logs screenshot mode. Quit it with `osascript -e 'tell application id "<bundle ID>.Screenshots" to quit'`.
   - Run `<Screenshots app>/Contents/MacOS/<App>` with no arguments: exit status 1, a "runs only in screenshot mode" fault, and no new crash report in `~/Library/Logs/DiagnosticReports`.

## The run

`make test`, then `make build` (unchanged by screenshots), then `make screenshots` (`SCREENSHOT_APPEARANCES=light` for a quick first pass). A hung run is left to time out.

## Evidence to collect

Done when every item below has an observed answer:

- **Every PNG:** open it (a contact sheet of all of them is a quick final check after a re-run), check its size (`sips -g pixelWidth -g pixelHeight`) and compare it with its design. Check:
  - the appearance matches the name
  - the mock content shows
  - no pointer, tooltip, hover highlight or stray dialog
- **Mock data only:**
  - the drive steps' content waits passed
  - no privacy alert appears in any shot
  - the log shows the fakes being used
  - the real app's data timestamps are unchanged
  - `~/Library/Containers/<bundle ID>.Screenshots` exists
- **The Mac's appearance** is what it was before the run.
- **Failures:** for each failed test, the reason from the log or the `.xcresult`, and a crash report in `~/Library/Logs/DiagnosticReports/<App>-*.ips` if the app crashed.

Then update the app's `screenshot-pipeline.md` memory: move each "Not verified" item to "Found on real runs" with the date.
