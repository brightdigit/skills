// Tuist/ProjectDescriptionHelpers/ConfigurationName+Screenshots.swift
import ProjectDescription

extension ConfigurationName {
  /// The configuration `make screenshots` builds. Named plainly: the gate is
  /// SCREENSHOTS on the app target, not DEBUG in the packages.
  public static var screenshots: Self {
    .configuration("Screenshots")
  }
}
