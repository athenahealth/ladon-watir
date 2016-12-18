require 'rubocop/rake_task'
require 'rubygems/tasks'
require 'rspec/core/rake_task'

# Run "rake rubocop" to run rubocop.
# Run "rake rubocop:auto_correct" to run rubocop and auto-fix where possible.
RuboCop::RakeTask.new(:rubocop)

# Run "rake spec" to execute all RSpec tests.
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

Gem::Tasks.new(push: false)
