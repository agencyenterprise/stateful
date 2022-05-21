Pod::Spec.new do |s|
  s.name          = "Stateful"
  s.version       = "1"
  s.summary       = "A short description of Stateful."
  s.description   = "iOS lib for handling view state."
  s.homepage      = "http://EXAMPLE/Stateful"
  s.license       = "MIT"
  s.author        = { 'Lucas Assis Rodrigues' => 'lucas.assis.ro@gmail.com' }
  s.source        = { :git => "https://github.com/agencyenterprise/stateful.git", :tag => "#{s.version}" }
  s.source_files  = "Stateful/**/*.{h,m, swift}"
  s.exclude_files = "Stateful/StatefulExample", "Stateful/**/*.{xcodeproj}"
end
