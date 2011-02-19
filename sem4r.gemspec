# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sem4r/version.rb"

Gem::Specification.new do |gem|
  gem.name = "sem4r"
  gem.version = Sem4r::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.summary = %Q{Library to access google adwords api. Works with ruby 1.9 and ruby 1.8}
  gem.description = %Q{
     Sem4r is a library to access google adwords api.
     It will works with ruby 1.9 and ruby 1.8 without soap4r.
     It uses a high level model instead of a low level api.
     You think about clients, campaigns, keywords and not about operations, operands, selectors, service calls.

     This is a ALPHA version.rb don't use in production.
     If you are interested in this project let me now: install it and update periodically, so the gemcutter
     download counter go up. Or subscribe to my feed at sem4r.com. Or watch the project on github.
     Or simply drop me a line in email. However I will know there is someone out of here.
  }

  gem.authors = ["Sem4r"]
  gem.email = "sem4ruby@gmail.com"
  gem.homepage = "http://www.sem4r.com"

  #
  # dependencies
  #
  gem.add_runtime_dependency(%q<builder>, [">= 0"])
  gem.add_runtime_dependency(%q<nokogiri>, [">= 0"])
  gem.add_runtime_dependency(%q<httpclient>, [">= 0"])
  gem.add_runtime_dependency(%q<highline>, [">= 0"])
  gem.add_runtime_dependency(%q<builder>, [">= 0"])
  gem.add_runtime_dependency(%q<nokogiri>, [">= 0"])
  gem.add_runtime_dependency(%q<optparse-command>, [ "0.1.5"])

  gem.add_development_dependency(%q<rake>, [">= 0"])
  gem.add_development_dependency(%q<yard>, [">= 0"])
  gem.add_development_dependency(%q<bundler>, [">= 0"])
  gem.add_development_dependency(%q<rspec>, [">= 0"])
  gem.add_development_dependency(%q<differ>, [">= 0"])

#platforms :jruby do
#  gem 'jruby-openssl'
#end
#

  #
  # bin
  #
  gem.executables = %w{ sem }
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  gem.extra_rdoc_files = [
      "LICENSE",
      "README.rdoc"
  ]

  #
  # files
  #
  # s.files         = `git ls-files`.split("\n")
  gem.files = %w{LICENSE README.rdoc Rakefile sem4r.gemspec .gemtest Gemfile Gemfile.lock}
  gem.files << 'config/sem4r.example.yml'
  gem.files.concat Dir['examples_sem4r/*.rb']
  gem.files.concat Dir['examples_blog/*.rb']
  gem.files.concat Dir['tasks/**/*.rake']
  gem.files.concat Dir['lib/**/*.rb']

  #
  # test files
  #
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.test_files = Dir['spec/**/*.rb']
  gem.test_files.concat Dir['spec/**/*.xml']
  gem.test_files.concat Dir['spec/fixtures/**/*']


  # gem.require_paths = ["lib"]
end
