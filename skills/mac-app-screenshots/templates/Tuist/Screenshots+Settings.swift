// Tuist/ProjectDescriptionHelpers: the Screenshots pieces to merge into the
// project's existing helpers.
import ProjectDescription

extension SettingsDictionary {
  /// Ad hoc signing: no team, no profile, so no secrets and no portal.
  public static var signingAdHoc: SettingsDictionary {
    [
      "CODE_SIGN_STYLE": "Manual",
      "CODE_SIGN_IDENTITY": "-",
      "DEVELOPMENT_TEAM": "",
      "PROVISIONING_PROFILE_SPECIFIER": "",
    ]
  }
}

extension Configuration {
  /// The app target's Screenshots configuration: Debug-based, the
  /// .Screenshots bundle ID, ad hoc, the SCREENSHOTS condition, and an
  /// entitlements file with only profile-free entitlements.
  public static var appScreenshots: Self {
    .debug(
      name: .screenshots,
      settings: SettingsDictionary.signingAdHoc.merging([
        "PRODUCT_BUNDLE_IDENTIFIER": "com.example.MyApp.Screenshots",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG SCREENSHOTS",
        "CODE_SIGN_ENTITLEMENTS": "Config/Screenshots.entitlements",
      ]) { $1 },
      xcconfig: .relativeToRoot("Config/App.xcconfig")
    )
  }
}

extension Settings {
  /// Add `.debug(name: .screenshots)` to the project's configurations too.
  public static var uiTestSettings: Self {
    .settings(
      base: SettingsDictionary.signingAdHoc.merging([
        "TEST_TARGET_NAME": "MyApp"
      ]) { $1 },
      configurations: [
        .debug(name: "Debug"),
        .release(name: "Release"),
        .debug(name: .screenshots),
      ]
    )
  }
}
