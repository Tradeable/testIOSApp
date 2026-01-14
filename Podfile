platform :ios, '13.0'

flutter_module_path = 'flutter_module'

unless File.exist?(flutter_module_path)
  system("git clone https://github.com/deepakgrandhi/tradeable_flutter_sdk_module.git #{flutter_module_path}")
end

system("cd #{flutter_module_path} && git pull origin main && flutter pub get")

flutter_podhelper = File.join(flutter_module_path, '.ios', 'Flutter', 'podhelper.rb')
if File.exist?(flutter_podhelper)
  load flutter_podhelper
end

target 'testingIosApp' do
  use_frameworks!
  
  install_all_flutter_pods(flutter_module_path)
  
  pod 'tradeableIOSWrapper', :git => 'https://github.com/deepakgrandhi/tradeableIOSWrapper.git'
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
end
