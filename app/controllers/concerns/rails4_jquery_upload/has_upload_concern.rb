module Rails4JqueryUpload
  module HasUploadConcern
    extend ActiveSupport::Concern

    private

    def jquery_upload_json_response(upload_models, name,
                                    uploader_mountpoint,
                                    engine_mountpoint)
      unless upload_models.respond_to? :map
        upload_models = [] << upload_models
      end
      if upload_models.any?
        render :json => upload_models.map { |model|
          json_hash(name, model, uploader_mountpoint, engine_mountpoint)
        }.to_json
      else
        render :json => {}.to_json
      end
    end

    def json_hash(name, model, uploader_mountpoint, engine_mountpoint)
      {
        "name" => model.read_attribute("#{uploader_mountpoint}"),
        "size" => model.send("#{uploader_mountpoint}").size,
        "url" => model.send("#{uploader_mountpoint}").url,
        "thumbnail_url" => model.send("#{uploader_mountpoint}").thumb.url,
        "delete_url" => "#{engine_mountpoint}/uploads/#{name}/#{model.id}",
        "delete_type" => "DELETE"
      }
    end

    def jquery_upload_model_ids(hidden_field_name)
      if params[hidden_field_name]
        params[hidden_field_name].split(",")
      else
        nil
      end
    end
  end
end
