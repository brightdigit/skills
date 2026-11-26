# Screenshots: `make screenshots` (#<issue>)

Built <YYYY-MM-DD> with GrabKit <version> and the `mac-app-screenshots` skill.

- **Prefix:** `-<Prefix>Screenshots YES`, `-<Prefix>Appearance`, `TEST_RUNNER_<PREFIX>_SCREENSHOT_APPEARANCES`.
- **Bundle ID:** `<bundle ID>.Screenshots`, signed ad hoc, `Config/Screenshots.entitlements`.
- **Mock data:** <each faked service and the type that fakes it>.
- **Proof of content:** <what each screen waits for before capturing>.
- **Screens:** <NN-slug: what it shows, one line each>.
- **Window size:** <width × height> points, top left.

## Not verified (check on the first Mac run, then move each item below with its date)

- The app launches signed ad hoc with `Config/Screenshots.entitlements`.
- `<App>Demo` symbols are absent from the Debug and Release binaries.
- <each menu title, window query and sheet the drive steps assume>.

## Found on real runs

- <YYYY-MM-DD>: <what a run showed, and the fix>.
