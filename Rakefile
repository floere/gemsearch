require 'picky/tasks'

unless RACK_ENV == 'production'
  require 'rspec'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new :spec
end