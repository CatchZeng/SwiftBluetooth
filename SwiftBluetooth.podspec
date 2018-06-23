#
# Be sure to run `pod lib lint SwiftBluetooth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftBluetooth'
  s.version          = '0.2.0'
  s.summary          = 'A simple framework for building BLE apps.'
  s.homepage         = 'https://github.com/CatchZeng/SwiftBluetooth'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CatchZeng' => '891793848@qq.com' }
  s.source           = { :git => 'https://github.com/CatchZeng/SwiftBluetooth.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'SwiftBluetooth/Classes/**/*'
  s.frameworks = 'UIKit', 'CoreBluetooth'
end
