
workspace 'MantleArrayExtension.xcworkspace'
project   'MantleArrayExtension.xcodeproj'

use_frameworks!
target :MantleArrayExtensionTests do
  inherit! :search_paths

  pod 'Mantle',             '2.1.0'
  pod 'MantleArrayExtension', :path => '.'

  pod 'Quick',  '0.10.0'
  pod 'Nimble', '5.1.1'
  pod 'OCMock', '3.3.1'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end