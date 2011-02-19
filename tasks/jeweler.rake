##
## jeweler
##
#begin
#  require 'jeweler'
#  Jeweler::Tasks.new do |gem|
#
#    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
#    gem.name = "sem4r"
#    gem.summary = %Q{Library to access google adwords api. Works with ruby 1.9 and ruby 1.8}
#    gem.description = %Q{
#       Sem4r is a library to access google adwords api.
#       It will works with ruby 1.9 and ruby 1.8 without soap4r.
#       It uses a high level model instead of a low level api.
#       You think about clients, campaigns, keywords and not about operations, operands, selectors, service calls.
#
#       This is a ALPHA version.rb don't use in production.
#       If you are interested in this project let me now: install it and update periodically, so the gemcutter
#       download counter go up. Or subscribe to my feed at sem4r.com. Or watch the project on github.
#       Or simply drop me a line in email. However I will know there is someone out of here.
#    }
#
#    gem.authors = ["Sem4r"]
#    gem.email = "sem4ruby@gmail.com"
#    gem.homepage = "http://www.sem4r.com"
#
#    #
#    # dependecies
#    #
#    # gem.add_dependency 'patron'
#    gem.add_dependency 'builder'
#    gem.add_dependency 'nokogiri'
#    gem.add_development_dependency 'rspec'
#    gem.add_development_dependency 'differ'
#
#    #
#    # files
#    #
#    gem.files  = %w{LICENSE README.rdoc Rakefile VERSION.yml sem4r.gemspec Gemfile Gemfile.lock}
#    gem.files << 'config/sem4r.example.yml'
#    gem.files.concat Dir['examples_sem4r/*.rb']
#    gem.files.concat Dir['examples_blog/*.rb']
#    gem.files.concat Dir['tasks/**/*.rake']
#    gem.files.concat Dir['lib/**/*.rb']
#
#    #
#    # test files
#    #
#    gem.test_files = Dir['spec/**/*.rb']
#    gem.test_files.concat Dir['spec/**/*.xml']
#    gem.test_files.concat Dir['spec/fixtures/**/*']
#
#    #
#    # rubyforge
#    #
#    # gem.rubyforge_project = 'sem'
#  end
#
#  # Jeweler::RubyforgeTasks.new do |rubyforge|
#  #   rubyforge.doc_task = "rdoc"
#  # end
#
#  Jeweler::GemcutterTasks.new
#rescue LoadError
#  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
#end
