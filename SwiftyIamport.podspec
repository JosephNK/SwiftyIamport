Pod::Spec.new do |s|  
  s.name         = "SwiftyIamport"
  s.version      = "4.2.1"
  s.summary      = "I'mport in Swift"

  s.description  = "Swift I'mport for iOS (Swift 4)"

  s.homepage     = "https://github.com/JosephNK/SwiftyIamport"
  s.license      = "MIT"
  s.author       = { "JosephNK" => "nkw0608@gmail.com" }

  s.source       = { :git => "https://github.com/JosephNK/SwiftyIamport.git", :tag => s.version }
  s.source_files = "SwiftyIamport/Source/*.swift"
  s.resources    = "SwiftyIamport/Resource/*.{html}"
  s.framework    = "UIKit"

  s.requires_arc = true
  s.platform = :ios, "8.0"
end
