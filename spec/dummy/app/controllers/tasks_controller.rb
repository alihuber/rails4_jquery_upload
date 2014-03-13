class TasksController < ApplicationController

  def index
    @tasks = Task.all
  end


  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_parameters)
    attachment_ids = params[:hidden_attachments].split(",")
    @task.attachments << Attachment.find(attachment_ids)
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
    mountpoint = "file"
    name = "attachments"
    respond_to do |format|
      format.html
      format.json {
        render :json => @task.attachments.collect { |a| json_hash(name, a, mountpoint) }.to_json
      }
    end
  end

  def update
    @task = Task.find(params[:id])
    attachment_ids = params[:hidden_attachments].split(",")
    @task.attachments = Attachment.find(attachment_ids)
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


  def json_hash(name, model, mountpoint)
    {
      "name" => model.read_attribute("#{mountpoint}"),
      "size" => model.send("#{mountpoint}").size,
      "url" => model.send("#{mountpoint}").url,
      "thumbnail_url" => model.send("#{mountpoint}").thumb.url,
      "delete_url" => "/#{name}/#{model.id}",
      "delete_type" => "DELETE"
    }
  end

end
