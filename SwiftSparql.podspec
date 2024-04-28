Pod::Spec.new do |s|
  s.name             = 'SwiftSparql'
  s.version          = '0.12.0'
  s.summary          = 'Typed SPARQL query generator / decodable parser'
  s.description      = <<-DESC
  generates SPARQL query with Swift structures / parse query response using Decodable
                       DESC
  s.homepage         = 'https://github.com/banjun/SwiftSparql'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'banjun' => 'banjun@gmail.com' }
  s.source           = { :git => 'https://github.com/banjun/SwiftSparql.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/banjun'
  s.ios.deployment_target = "15.0"
  s.osx.deployment_target = "12.0"
  # s.visionos.deployment_target = "1.0"
  s.swift_version = "5.0"
  s.source_files = 'SwiftSparql/Classes/**/*'
  s.dependency 'FootlessParser', '~> 0.5'
end
