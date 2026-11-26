// Project.swift: the UI test target and scheme to add. The app target lists
// .appScreenshots among its configurations; nothing else about it changes.

.target(
  name: "MyAppScreenshotTests",
  destinations: [.mac],
  product: .uiTests,
  bundleId: "com.example.MyApp.ScreenshotTests",
  deploymentTargets: .macOS("27.0"),
  infoPlist: .default,
  sources: ["ScreenshotTests/**"],
  dependencies: [
    .target(name: "MyApp"),
    .package(product: "MyAppScreenshots"),
    .package(product: "GrabTesting"),
  ],
  settings: .uiTestSettings
),

// schemes:
.scheme(
  name: "MyAppScreenshots",
  shared: true,
  buildAction: .buildAction(targets: [.target("MyApp")]),
  testAction: .targets(
    [.testableTarget(target: .target("MyAppScreenshotTests"))],
    configuration: .screenshots
  ),
  runAction: .runAction(
    configuration: .screenshots,
    executable: .target("MyApp"),
    arguments: .arguments(launchArguments: [
      .launchArgument(name: "-MyScreenshots YES", isEnabled: true)
    ])
  )
)
