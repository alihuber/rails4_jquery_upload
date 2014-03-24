require "jquery-rails"
require "jquery-ui-rails"
require "rails-assets-blueimp-load-image"
require "rails-assets-blueimp-canvas-to-blob"
require "rails-assets-blueimp-file-upload"
require "rails-assets-blueimp-tmpl"

module Rails4JqueryUpload
  class Engine < ::Rails::Engine
    isolate_namespace Rails4JqueryUpload


    config.to_prepare do
      ::ApplicationController.class_eval do

        helper Rails4JqueryUpload::Engine.helpers

        def self.has_jquery_uploads
          include Rails4JqueryUpload::HasUploadConcern
        end
      end
    end

  end
end
