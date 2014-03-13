class AttachmentsController < ApplicationController

  def index
    @attachments = Attachment.all
  end

  def create
    params[:files].each do |file|
      attachment = Attachment.new
      attachment.file = file
      if attachment.save
        respond_to do |format|
          format.html {
            render :json => [attachment.to_jq_upload].to_json,
            :content_type => "text/html",
            :layout => false
          }
          format.json {
            out = {"files" => [attachment.to_jq_upload]}.to_json
            render :json => out
          }
        end
      else
        render :json => [{:error => "custom_failure"}], :status => 304 and return
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    render :json => true
  end

end
