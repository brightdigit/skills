// The app target's entry point. Only the Screenshots configuration defines
// SCREENSHOTS, so Debug and Release never reach MyAppDemo or GrabSupport.

import MyApp
import SwiftUI

#if SCREENSHOTS
  import MyAppDemo
#endif

@main
internal struct Main: MyApp {
  @NSApplicationDelegateAdaptor(AppDelegate.self)
  private var delegate

  internal var appDelegate: AppDelegate {
    delegate
  }

  #if SCREENSHOTS
    // SwiftUI runs this before it creates the delegate. installScreenshotMode()
    // (in MyAppDemo) quits unless this is the .Screenshots build launched with
    // -MyScreenshots YES, then sets AppDelegate.makeDemoSession, a factory the
    // delegate calls from its own init(). Building the session here instead
    // crashes the launch.
    internal init() {
      AppDelegate.installScreenshotMode()
    }
  #endif
}
