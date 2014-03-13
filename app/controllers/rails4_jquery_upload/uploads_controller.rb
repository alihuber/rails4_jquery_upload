module Rails4JqueryUpload
  class UploadsController < ApplicationController

    def create
      names = params.keys.select { |key| key.start_with?("hidden") }
      names = names.map! { |name| name = name.gsub("hidden_", "") }
      models = names.map { |model| model.camelize.singularize.constantize }
      data = Hash[names.zip(models)]
      mountpoint = params.keys.select { |key| key.start_with?("uploader_mounted_to") }
      mountpoint = mountpoint.first.gsub("uploader_mounted_to_", "")

      data.each do |name, model|
        params[:files].each do |file|
          upload = model.new
          upload.send("#{mountpoint}=", file)
          if upload.save
            respond_to do |format|
              format.html {
                render :json => [json_hash(name, upload, mountpoint)].to_json,
                :content_type => "text/html",
                :layout => false
              }
              format.json {
                out = { "files" => [json_hash(name, upload, mountpoint)] }.to_json
                render :json => out
              }
            end
          else
            render :json => [{:error => "custom_failure"}], :status => 304 and return
          end
        end
      end
    end


    def destroy
      id    = params[:id]
      model = params[:model]
      model.camelize.singularize.constantize.find(id).destroy
      render :json => true
    end


    private
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

  end
end

