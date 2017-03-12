Pod::Spec.new do |s|
  s.name             = 'MantleArrayExtension'
  s.version          = '1.0.0'
  s.summary          = 'MantleArrayExtension support mutual conversion between Model object and character-delimited String with Mantle.'
  s.homepage         = 'https://github.com/soranoba/MantleArrayExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'soranoba' => 'soranoba@gmail.com' }
  s.source           = { :git => 'https://github.com/soranoba/MantleArrayExtension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files         = 'MantleArrayExtension/Classes/**/*.{m,h}'
  s.private_header_files = 'MantleArrayExtension/Classes/Private/*.h'

  s.dependency 'Mantle', '~> 2.0'
end
