// MyAppScreenshots/Screen.swift: one case per design, in the design's order.

public import GrabSupport
public import GrabTesting
import MyAppAccessibility
public import XCTest

extension GrabLaunchArguments {
  /// MyApp's flags: -MyScreenshots, -MyAppearance.
  public static let myApp = GrabLaunchArguments(prefix: "My")
}

@MainActor
public enum Screen: String, CaseIterable, GrabScreen {
  case editor
  case about

  public var baseName: String {
    GrabNaming.baseName(number: (Self.allCases.firstIndex(of: self) ?? 0) + 1, slug: rawValue)
  }

  public func launchArguments(appearance: GrabAppearance) -> [String] {
    GrabLaunchArguments.myApp.launchArguments(appearance: appearance)
  }

  public func launchEnvironment() throws -> [String: String] {
    ["MY_SCREENSHOT_TEXT": try GrabFixture(name: "sample", subdirectory: "Fixtures").text(in: .module)]
  }

  public func drive(_ app: XCUIApplication) throws -> GrabTarget {
    let window = try app.windows.firstMatch.waitToExist("window")
    // Prove the mock fed the window: wait until it shows the fixture.
    let expected = try GrabFixture(name: "sample", subdirectory: "Fixtures").text(in: .module)
    try app.element(AccessibilityID.editorText)
      .waitUntil("editor showing the fixture") { ($0.value as? String) == expected }
    switch self {
    case .editor:
      return GrabTarget(window: window)
    case .about:
      try app.menuBars.menuBarItems["MyApp"].waitToExist("app menu").click()
      try app.menuBars.menuItems["About MyApp"].waitToExist("About MyApp").click()
      let panel = try app.windows.element(boundBy: 1).waitToExist("About panel")
      return GrabTarget(window: panel)
    }
  }
}
