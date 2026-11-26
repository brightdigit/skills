// MyAppScreenshots/Screen.swift: one case per design, in the design's order.

public import GrabSupport
public import GrabTesting
import MyAppAccessibility
public import XCTest

extension GrabLaunchArguments {
  /// MyApp's flags: -MyScreenshots, -MyAppearance.
  public static let myApp = GrabLaunchArguments(prefix: "My")
}

public enum Screen: String, CaseIterable, Sendable {
  case editor
  case menus
  case about
}

// An @MainActor extension, so the drive helpers share GrabScreen's isolation.
@MainActor
extension Screen: GrabScreen {
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
    case .menus:
      let edit = app.menuBars.menuBarItems["Edit"]
      try edit.waitToExist("Edit menu").click()
      try app.menuBars.menuItems["Substitutions"].waitToExist("Substitutions").hover()
      try app.menuBars.menuItems["Smart Quotes"].waitToExist("Substitutions submenu")
      // Crop to the window plus the menu's title (an open menu's own frame can
      // run to the bottom of the screen), and leave the pointer on the menu
      // item, or its submenu closes.
      return GrabTarget(window: window, extras: [edit], parksPointer: false)
    case .about:
      try app.menuBars.menuBarItems["MyApp"].waitToExist("app menu").click()
      try app.menuBars.menuItems["About MyApp"].waitToExist("About MyApp").click()
      // The standard About panel is a dialog to accessibility, not a window.
      let panel = try app.dialogs.firstMatch.waitToExist("About panel")
      return GrabTarget(window: panel, checksWindowSize: false)
    }
  }
}
