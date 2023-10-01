Pod::Spec.new do |spec|

  spec.name         = "ConvertedinMobileSDK"
  spec.version      = "1.0.8"
  spec.summary      = "This is a simple framework for convertedin partners"

  spec.homepage     = "https://github.com/iOS-convertedin-eslamali/iOS_ConvertedinMobileSDK"
  spec.license      = "MIT"
  spec.author             = { "Eslam Ali" => "e.ali@converted.in" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/iOS-convertedin-eslamali/iOS_ConvertedinMobileSDK.git", :tag => spec.version.to_s }
  spec.source_files  = "ConvertedinMobileSDK/**/*.{swift}"
  spec.swift_versions = "5.0"
end
