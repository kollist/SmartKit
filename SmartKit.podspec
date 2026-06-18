Pod::Spec.new do |s|
  s.name             = "SmartKit"
  s.version          = "0.1.0"
  s.summary          = "Drop-in SwiftUI components powered by Foundation Models, with graceful fallback."
  s.description      = <<-DESC
    SmartKit ships SummaryView and SmartTagView, two SwiftUI components backed by
    Apple's on-device Foundation Models framework, plus the fallback-detection logic
    every app shipping this feature needs: OS version, hardware eligibility, Apple
    Intelligence enablement (which is also how region support surfaces), model asset
    readiness, and locale support all collapse into one check, so the views degrade
    gracefully instead of crashing on unsupported devices, OS versions, or regions.
  DESC
  s.homepage         = "https://github.com/kollist/SmartKit"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Khalid Alaoui" => "125976275+kollist@users.noreply.github.com" }
  s.source           = { :git => "https://github.com/kollist/SmartKit.git", :tag => s.version.to_s }

  s.ios.deployment_target     = "17.0"
  s.osx.deployment_target     = "14.0"

  s.swift_version    = "6.0"
  s.source_files     = "Sources/SmartKit/**/*.swift"
end
