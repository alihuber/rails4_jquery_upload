class TasksController < ApplicationController

  has_jquery_uploads

  def index
    @tasks = Task.all
  end


  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_parameters)
    fetch_uploaded_ids
    @task.attachments << Attachment.find(@attachment_ids)
    if @task.save
      @tasks = Task.all
      render "index"
    else
      render "new"
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def edit
    @task = Task.find(params[:id])
    respond_to do |format|
      format.html
      format.json {
        jquery_upload_json_response(
          @task.attachments, "attachments", "file", "/rails4_jquery_upload"
        )
      }
    end
  end

  def update
    @task = Task.find(params[:id])
    fetch_uploaded_ids
    @task.attachments = Attachment.find(@attachment_ids)
    if @task.update(task_parameters)
      @tasks = Task.all
      render "index"
    else
      render "new"
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to root_path
  end

  private
  def task_parameters
    params.require(:task).permit(:title, :description)
  end

  def fetch_uploaded_ids
    @attachment_ids = jquery_upload_model_ids("hidden_attachments")
  end
end

