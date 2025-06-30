# frozen_string_literal: true

require_relative 'lib/katex_on_rails/version'

Gem::Specification.new do |spec|
  spec.name = 'katex_on_rails'
  spec.version = KatexOnRails::VERSION
  spec.authors = ['Juraj Kostolansky']
  spec.email = ['juraj@kostolansky.sk']

  spec.summary = 'Convert LaTeX math formulas to HTML using KaTeX in Rails.'
  spec.homepage = 'https://github.com/jkostolansky/katex_on_rails'
  spec.license = 'MIT'

  spec.metadata = {
    'homepage_uri' => 'https://github.com/jkostolansky/katex_on_rails',
    'source_code_uri' => 'https://github.com/jkostolansky/katex_on_rails',
    'changelog_uri' => 'https://github.com/jkostolansky/katex_on_rails/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['README.md', 'LICENSE.txt', 'CHANGELOG.md', 'katex_on_rails.gemspec', 'lib/**/*.rb']

  spec.required_ruby_version = '>= 3.2.0'
  spec.add_dependency 'nodo', '>= 1.8.0'
  spec.add_dependency 'nokogiri', '>= 1.18.0'
end
