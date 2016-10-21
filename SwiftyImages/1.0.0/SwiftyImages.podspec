Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '9.3'
s.name = "SwiftyImages"
s.summary = "A set of efficient extensions and classes for manipulating images and colors."
s.requires_arc = true
s.version = "1.0.0"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Nyx0uf" => "benjgodard@me.com" }
s.homepage = "https://github.com/Nyx0uf/SwiftyImages"
s.source = { :git => "https://github.com/Nyx0uf/SwiftyImages.git", :tag => "#{s.version}"}
s.frameworks = "UIKit", "ImageIO", "MobileCoreServices"
s.source_files = "src/**/*.{swift,h}"

end
