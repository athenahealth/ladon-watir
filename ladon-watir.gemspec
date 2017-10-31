Gem::Specification.new do |s|
  s.name        = 'ladon-watir'
  s.version     = '1.0.0.rc.8'
  s.date        = '2017-09-15'
  s.summary     = 'Ladon Watir'
  s.description = <<-HEREDOC
    Use Ladon and Watir to automate end-to-end web application workflows.
  HEREDOC
  s.authors     = ['Reagan Eggert', 'Kevin Weaver', 'Shayne Snow']
  s.email       = 'kweaver@athenahealth.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://rubygems.org/gems/ladon-watir'
  s.license     = 'MIT' # TODO

  s.required_ruby_version = '>= 2.1.0' # due to use of required keyword args

  s.add_runtime_dependency 'ladon', '1.1.1.rc.1'
  s.add_runtime_dependency 'page-object', '2.2.4'
  s.add_runtime_dependency 'selenium-webdriver', '3.6.0'
  s.add_runtime_dependency 'watir', '6.8.4'

  s.add_development_dependency 'rake', '~> 11.3' # for convenient rake tasks
  s.add_development_dependency 'rspec', '~> 3.6' # for specs
  s.add_development_dependency 'rubocop', '~> 0.49' # for linting
end
