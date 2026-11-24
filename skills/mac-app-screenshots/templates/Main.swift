// The app target's entry point. Only the Screenshots configuration defines
// SCREENSHOTS, so Debug and Release never reference MyAppDemo or GrabSupport.

import MyApp

#if SCREENSHOTS
  import GrabSupport
  import MyAppDemo
#endif

@main
internal struct Main: MyApp {
  #if SCREENSHOTS
    // Quits unless this is the .Screenshots build launched with
    // -MyScreenshots YES, before anything touches data.
    internal static var composition: AppComposition {
      GrabLaunchDecision(launchArguments: .myApp).requireScreenshotMode()
      return DemoComposition.make()
    }
  #endif
}
