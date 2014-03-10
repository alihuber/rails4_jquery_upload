$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails4_jquery_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails4_jquery_upload"
  s.version     = Rails4JqueryUpload::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Rails4JqueryUpload."
  s.description = "TODO: Description of Rails4JqueryUpload."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.0.rc1"

  s.add_development_dependency "pg"
end
