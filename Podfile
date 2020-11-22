# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'umiiiku' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for umiiiku
pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'

pod 'Nuke'
pod 'PKHUD'

pod 'Alamofire', '~> 5.2'

  target 'umiiikuTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'umiiikuUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
