$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "els_bootstrap/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "els_bootstrap"
  s.version     = ElsBootstrap::VERSION
  s.authors     = ["Neil Chambers"]
  s.email       = ["neil.chambers@teamaol.com"]
  s.homepage    = "http://wiki.office.aol.com/wiki/Els_Bootstrap"
  s.summary     = "Rails engine providing ELS auth"
  s.description = "Makes developing, testing and deploying Rails,
                    with and without ELS, a lot less hacky"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  #s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "jquery-rails"
  s.add_dependency 'coffee-rails', '~> 3.2.1'
  s.add_dependency "els_token", "~> 1.2.2"
end
