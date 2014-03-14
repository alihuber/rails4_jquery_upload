module Rails4JqueryUpload
  module HasUploadConcern
    extend ActiveSupport::Concern

    private

    def jquery_upload_json_response(upload_models, name, mountpoint)
      render :json => upload_models.map { |model|
        json_hash(name, model, mountpoint)
      }.to_json
    end

    def json_hash(name, model, mountpoint)
      {
        "name" => model.read_attribute("#{mountpoint}"),
        "size" => model.send("#{mountpoint}").size,
        "url" => model.send("#{mountpoint}").url,
        "thumbnail_url" => model.send("#{mountpoint}").thumb.url,
        "delete_url" => "/rails4_jquery_upload/uploads/#{name}/#{model.id}",
        "delete_type" => "DELETE"
      }
    end

    def jquery_upload_model_ids(hidden_field_name)
      params[hidden_field_name].split(",")
    end

  end
end
