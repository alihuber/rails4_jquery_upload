$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails4_jquery_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails4_jquery_upload"
  s.version     = Rails4JqueryUpload::VERSION
  s.authors     = ["Alexander Huber", "Tilo Dietrich"]
  s.email       = ["alih83@gmx.de", "tilodietrich@posteo.de"]
  s.summary     = "jQuery Fileuploader for Rails 4"
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails",        "4.0.3"
  s.add_dependency "coffee-rails", "~> 4.0.1"
  s.add_dependency "sass-rails",   "~> 4.0.1"
  s.add_dependency "uglifier",     "~> 2.4"

  s.add_dependency "jquery-rails"
  s.add_dependency "jquery-turbolinks"
  s.add_dependency "jquery-ui-rails"
  s.add_dependency "rails-assets-blueimp-load-image"
  s.add_dependency "rails-assets-blueimp-canvas-to-blob"
  s.add_dependency "rails-assets-blueimp-file-upload"
  s.add_dependency "rails-assets-blueimp-tmpl"

  s.add_development_dependency "capybara"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "pg"
end

