// Tuist/ProjectDescriptionHelpers/ConfigurationName+Screenshots.swift
import ProjectDescription

extension ConfigurationName {
  /// The configuration `make screenshots` builds. Its packages get Release
  /// settings (no DEBUG), so screenshot code never sits behind #if DEBUG.
  public static var screenshots: Self {
    .configuration("Screenshots")
  }
}
