require "jquery-rails"
require "jquery-turbolinks"
require "jquery-ui-rails"
require "rails-assets-blueimp-load-image"
require "rails-assets-blueimp-canvas-to-blob"
require "rails-assets-blueimp-file-upload"
require "rails-assets-blueimp-tmpl"
require "jquery-turbolinks"

module Rails4JqueryUpload
  class Engine < ::Rails::Engine
    isolate_namespace Rails4JqueryUpload


    config.to_prepare do
      ::ApplicationController.class_eval do

        helper Rails4JqueryUpload::Engine.helpers
      end
    end

  end
end
