source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target 'SlackKit OS X' do
	pod 'Starscream', :git => 'https://github.com/pvzig/Starscream.git', :branch => 'swift-23'
	pod 'Swifter', :git => 'https://github.com/pvzig/swifter.git', :branch => 'stable'
end

target 'SlackKit iOS' do
	pod 'Starscream', :git => 'https://github.com/pvzig/Starscream.git', :branch => 'swift-23'
	pod 'Swifter', :git => 'https://github.com/pvzig/swifter.git', :branch => 'stable'
end

target 'SlackKit tvOS' do
	pod 'Starscream', :git => 'https://github.com/pvzig/Starscream.git', :branch => 'swift-23'
	pod 'Swifter', :git => 'https://github.com/pvzig/swifter.git', :branch => 'stable'
end

# Set SWIFT_VERSION to 2.3 manually
post_install do |installer|
  installer.pods_project.targets.each do |target|
  	target.build_configurations.each do |config|
    	config.build_settings['SWIFT_VERSION'] = '2.3'
  	end
  end
end