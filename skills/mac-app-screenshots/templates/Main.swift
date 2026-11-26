// The app target's entry point. Every launch decides at runtime whether it
// runs in screenshot mode; there is no compile gate.

import MyApp
import MyAppDemo
import SwiftUI

@main
internal struct Main: MyApp {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  private var delegate

  internal var appDelegate: AppDelegate {
    delegate
  }

  // SwiftUI runs this before it creates the delegate. installScreenshotMode()
  // (in MyAppDemo) asks GrabLaunchDecision: the real app runs live and
  // ignores -MyScreenshots; the .Screenshots build launched with
  // -MyScreenshots YES sets AppDelegate.makeDemoSession, a factory the
  // delegate calls from its own init(); the .Screenshots build without it
  // quits. Building the session here instead crashes the launch.
  internal init() {
    AppDelegate.installScreenshotMode()
  }
}
