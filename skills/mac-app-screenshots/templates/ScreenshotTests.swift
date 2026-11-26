// ScreenshotTests/ScreenshotTests.swift: the thin UI test target. Everything
// but the list of screens lives in the MyAppScreenshots package target.

import GrabSupport
import GrabTesting
import MyAppScreenshots
import XCTest

internal final class ScreenshotTests: XCTestCase {
  @MainActor private var runner: GrabRunner {
    // The window size the demo composition sets, in points.
    GrabRunner(launchArguments: .myApp, windowSize: CGSize(width: 1_280, height: 800))
  }

  override internal func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

  @MainActor
  internal func test01Editor() throws {
    try runner.capture(Screen.editor, in: self)
  }

  @MainActor
  internal func test02About() throws {
    try runner.capture(Screen.about, in: self)
  }
}
