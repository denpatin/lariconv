# frozen_string_literal: true

Gem::Specification.new do |s|
  s.author = 'Den Patin'
  s.description = <<-DESC
    `lariconv` is a gem that converts different currencies to Georgian Lari
    based on the National Bank of Georgia's exchange rate for a given date.
  DESC
  s.email = 'den@hey.com'
  s.files = Dir['lib/**/*.rb']
  s.homepage = 'https://github.com/denpatin/lariconv'
  s.license = 'MIT'
  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/denpatin/lariconv'
  }
  s.name = 'lariconv'
  s.required_ruby_version = '>= 3.0.0'
  s.summary = 'World currencies to Georgian Lari converter'
  s.version = '0.1.0'
end
