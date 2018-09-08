#
# Be sure to run `pod lib lint ShiftViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ShiftViewController'
  s.version          = '1.0.0'
  s.summary          = 'A controller to display cards like Tinder app'

  s.description      = <<-DESC
    A view controller to display cards like Tinder app. Allows to swipe in any direction and notify that
    result to allow you to perform actions in this way
                       DESC

  s.homepage         = 'https://github.com/daviwiki/swift-shiftviewcontroller.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'daviwiki' => 'david.martinez@innocv.com' }
  s.source           = { :git => 'https://github.com/daviwiki/swift-shiftviewcontroller.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ShiftViewController/Classes/**/*'

end
