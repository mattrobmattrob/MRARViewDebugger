#
# Be sure to run `pod lib lint MRARViewDebugger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MRARViewDebugger'
  s.version          = '0.1.0'
  s.summary          = 'MRARViewDebugger allows in place view hierarchy visualization using ARKit.'

s.description      = <<-DESC
MRARViewDebugger allows in place view hierarchy visualization of `UIViewController`s using ARKit.
The user is given the ability to separate layers by variable distances and scrub through the stack
using a slider similar to what Apple provides in Xcode's built in view debugger.

Debug your views on the device when something goes wrong vs. having to deal with reproducing and/or
attaching to the process in Xcode.
                       DESC

  s.homepage         = 'https://github.com/mattrobmattrob/MRARViewDebugger'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = '@mattrobmattrob'
  s.source           = { :git => 'https://github.com/mattrobmattrob/MRARViewDebugger.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/m4ttrob'

  s.ios.deployment_target = '11.0'

  s.source_files = 'MRARViewDebugger/Classes/**/*'

  s.frameworks = 'UIKit', 'ARKit', 'SceneKit'
end
