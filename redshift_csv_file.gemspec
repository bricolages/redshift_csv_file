Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'redshift_csv_file'
  s.version = '1.0.1'
  s.summary = 'Redshift unloaded CSV file parser'
  s.description = 'redshift_csv_file is a Redshift-specific CSV file parser.  Amazon Redshift generates non-standard CSV format, special handling is required.'
  s.license = 'MIT'

  s.author = ['Minero Aoki']
  s.email = 'aamine@loveruby.net'
  s.homepage = 'https://github.com/bricolages/redshift_csv_file'

  s.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  s.require_path = 'lib'

  s.required_ruby_version = '>= 2.3.0'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'rake'
end
