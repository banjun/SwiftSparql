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
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.12"
  s.swift_version = "5.0"
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'SwiftSparql/Classes/**/*'
    ss.dependency 'FootlessParser', '~> 0.5'
  end

  s.subspec 'BrightFutures' do |ss|
    ss.source_files = 'SwiftSparql/BrightFutures/**/*'
    ss.dependency 'SwiftSparql/Core'
    ss.dependency 'BrightFutures', '~> 8.0'
  end
end
