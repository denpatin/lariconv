# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'lariconv'
  s.version = '0.2.0'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.0.0'
  s.author = 'Den Patin'
  s.email = 'den@hey.com'
  s.homepage = 'https://github.com/denpatin/lariconv'
  s.summary = 'World currencies to Georgian Lari converter'
  s.description = <<-DESC
    This gem converts different currencies to Georgian Lari based on
    the National Bank of Georgia's exchange rate for a given date.
    Compatible with the `money` gem.
  DESC
  s.license = 'MIT'

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/denpatin/lariconv'
  }

  s.files = 'lib/lariconv.rb', 'README.md', 'LICENSE', 'CHANGELOG.md'

  s.add_development_dependency 'rspec', '~> 3.12'
end
