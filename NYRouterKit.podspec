Pod::Spec.new do |s|
  
  s.name         = "NYRouterKit"
  s.version      = "1.0.2"
  s.summary      = "供iOS开发组件化开发使用工具"

  s.description  = "供iOS开发组件化开发协同开发工具,有问题email akries@outlook.com"

  s.homepage     = "https://github.com/Akries/NYRouterKit.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Akries.NY" => "akries@outlook.com" }
  s.source       = { :git => "https://github.com/Akries/NYRouterKit.git", :tag =>'1.0.2' }

  s.platform     = :ios, '8.0'
  s.source_files  = "**/*.{h,m}"

  s.requires_arc = true

  s.dependency 'KVOController'
  s.dependency 'MJExtension'
  s.dependency 'RTRootNavigationController'


end
