Gem::Specification.new do |s|
  s.name        = 'ladon-watir'
  s.version     = '0.0.1'
  s.date        = '2016-11-08'
  s.summary     = 'Ladon Watir'
  s.description = <<-EOF
    Use Ladon and Watir to automate end-to-end web application workflows.
  EOF
  s.authors     = ['Reagan Eggert', 'Kevin Weaver']
  s.email       = 'kweaver@athenahealth.com'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://rubygems.org/gems/ladon-watir'
  s.license     = 'MIT' # TODO
  # s.executables << 'ladon-run'
  s.required_ruby_version = '>= 2.1.0' # due to use of required keyword args
  # s.add_runtime_dependency 'pry', '~> 0.10' # for interactive mode support in ladon-run
  s.add_development_dependency 'rspec', '~> 3.5' # for specs
  # s.add_development_dependency 'rubocop', '~> 0.45' # for linting
end
