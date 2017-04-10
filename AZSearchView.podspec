
Pod::Spec.new do |s|
  s.name         = "AZSearchView"
  s.version      = "1.0.3"
  s.summary      = "A search controller with auto-complete suggestions written in Swift 3.0"
  s.homepage     = "https://github.com/Minitour/AZSearchView"
  s.license      = "MIT"
  s.author       = { "Antonio Zaitoun" => "tony.z.1711@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Minitour/AZSearchView.git", :tag => "#{s.version}" }
  s.source_files  = "src/*.swift"
end
