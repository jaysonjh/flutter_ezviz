#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ezviz'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project for ezviz sdk.'
  s.description      = <<-DESC
萤石云插件-Flutter
                       DESC
  s.homepage         = 'https://github.com/jaysonjh/flutter_ezviz.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Guangzhou Zhiye Tech Limit.' => 'jayson@zhiyesoft.com' }
  s.source           = { :git => "https://github.com/jaysonjh/flutter_ezviz.git", :tag => "master" }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
  # 本地加载第三方库
  s.vendored_frameworks = ['Frameworks/EZOpenSDKFramework.framework']
end

