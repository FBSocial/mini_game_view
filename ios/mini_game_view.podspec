#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mini_game_view.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mini_game_view'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  #s.resource = '**/*.{sp}'
  s.resource_bundles = {'mini_game_view' => ['**/*.{sp}']}
  s.dependency 'Flutter'
  s.dependency 'SudMGP_Lite', '1.3.8'
  s.dependency 'SudMGPWrapper_Lite', '1.3.8'
  s.dependency 'Masonry','1.1.0'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
