require 'rubygems'
require 'rake'

require 'bundler'
Bundler::GemHelper.install_tasks

# Load tasks
Dir.glob('tasks/**/*.rake').each { |r| Rake.application.add_import r }

task :test => :spec
task :default => :spec
