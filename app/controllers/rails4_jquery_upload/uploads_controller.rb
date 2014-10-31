module Rails4JqueryUpload
  class UploadsController < ApplicationController
    include HasUploadConcern

    def create
      names = params.keys.select { |key| key.start_with?("hidden") }
      names = names.map! { |name| name = name.gsub("hidden_", "") }
      models = names.map { |model| model.camelize.singularize.constantize }
      data = Hash[names.zip(models)]
      uploader_mountpoint =
        params.keys.select { |key| key.start_with?("uploader_mounted_to") }
      uploader_mountpoint =
        uploader_mountpoint.first.gsub("uploader_mounted_to_", "")
      engine_mountpoint =
        params.keys.select { |key| key.start_with?("engine_mounted_to") }
      engine_mountpoint =
        engine_mountpoint.first.gsub("engine_mounted_to_", "")

      data.each do |model_name, model|
        if can_upload?(model_name)
          data.each do |name, model|
            params[:files].each do |file|
              upload = model.new
              upload.send("#{uploader_mountpoint}=", file)
              if upload.save
                respond_to do |format|
                  format.html {
                    render :json => [json_hash(
                      name, upload, uploader_mountpoint, engine_mountpoint
                    )].to_json,
                    :content_type => "text/html",
                    :layout => false
                  }
                  format.json {
                    out = { "files" => [json_hash(
                        name, upload, uploader_mountpoint, engine_mountpoint
                      )] }.to_json
                    render :json => out
                  }
                end
              else
                render :json => [{:error => "custom_failure"}], :status => 304 and return
              end
            end
          end
        else
          render :json => [{:error => "not_allowed"}], :status => 502
        end
      end
    end


    def destroy
      id    = params[:id]
      model = params[:model]
      if can_delete?(model)
        model.camelize.singularize.constantize.find(id).destroy
        render :json => true
      else
        render :json => [{:error => "not_allowed"}], :status => 502
      end
    end
  end
end

