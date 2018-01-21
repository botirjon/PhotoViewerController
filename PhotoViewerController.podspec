#
# Be sure to run `pod lib lint PhotoViewerController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhotoViewerController'
  s.version          = '0.1.2'
  s.summary          = 'A photo viewer controller for viewing photos.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
It can be used to view a sequence of photos. Its PhotoViewerControllerDelegate should be conformed by the client.
                       DESC

  s.homepage         = 'https://github.com/botirjon/PhotoViewerController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'botirjon.nasridinov@gmail.com' => 'botirjon.nasridinov@gmail.com' }
  s.source           = { :git => 'https://github.com/botirjon/PhotoViewerController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.swift_version = '4.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'PhotoViewerController/Classes/**/*'
  
  
  s.resources = 'PhotoViewerController/Classes/*.xib'
  s.resource_bundles = {
     'PhotoViewerController' => ['PhotoViewerController/**/*.xib']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
