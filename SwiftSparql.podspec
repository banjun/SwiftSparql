Pod::Spec.new do |s|
  s.name             = 'SwiftSparql'
  s.version          = '0.1.0'
  s.summary          = 'Typed SPARQL query generator'
  s.description      = <<-DESC
  generates SPARQL query with Swift structures
                       DESC
  s.homepage         = 'https://github.com/banjun/SwiftSparql'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'banjun' => 'banjun@gmail.com' }
  s.source           = { :git => 'https://github.com/banjun/SwiftSparql.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/banjun'
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.12"
  s.swift_version = "4.2"
  s.source_files = 'SwiftSparql/Classes/**/*'
  
  s.dependency 'FootlessParser', '~> 0.5'
end
