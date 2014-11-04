rails4_jquery_upload
====================

Rails mounted engine for uploading files with [jQuery File Uploader](http://blueimp.github.io/jQuery-File-Upload/).
Example usage is shown in the spec/dummy directory.



## Features
* Abstracts away the need for any additional code in the model
* Provides convenient helper methods for building the proper JSON response and a configurable upload form in the view
* Requires minimal JavaScript and controller setup
* File uploader agnostic, works with carrierwave, should work with dragonfly (untested)
* Encapsulates all needed gems in one engine
* Lets you define custom restrictions on the ability to upload, e.g. on model type or authentication based
* Uses the latest version of blueimp-file-upload, loaded from [rails-assets.org](https://rails-assets.org/)



## Installation
Add the rails4_jquery_upload engine and the rails-assets source to your `Gemfile`:    

    source "https://rails-assets.org"
    gem "rails4_jquery_upload", git: "alihuber/rails4_jquery_upload", branch: "master"
then `bundle install`.
    
In your `routes.rb` mount the engine to the destination you desire:    

    mount Rails4JqueryUpload::Engine => "/rails4_jquery_upload"    
Make sure to require the necessary Bootstrap/jQuery assets and the extra CSS and JavaScript:

    app/assets/javascripts/application.js:
    //= require jquery
    //= require bootstrap-sprockets
    //= require jquery_ujs
    ...
    //= require rails4_jquery_upload/application
    
    
    app/assets/stylesheets/application.css.scss:
    @import "bootstrap-sprockets";
    @import "bootstrap";
    ...
    *= require rails4_jquery_upload/application

and you're good to go! Note that the uploaded file will have to respond to the `thumb`-property, which is normally configured in the used file uploader itself, e.g. the `version :thumb` method in carrierwave.


## Usage
### View
The `jquery_fileupload` helper method includes all the necessary HTML for including the uploader form in your view and takes the following required arguments (note the '`/`' in front of the engine mountpoint, which is just like the above entry in `routes.rb`):

    = jquery_fileupload("/engine_mountpoint", "pluralized_model", "uploader_mountpoint")

The `uploader_mountpoint` refers to carrierwave's `mount_uploader :column, UploaderClass` method.
Say, you mounted the engine like above, have an "attachment" model with the carrierwave uploader mounted to the "file" column, so your call would look like this:

    = jquery_fileupload("/rails4_jquery_upload", "attachments", "file")

This gives you a "Basic Plus UI" uploader form with grey buttons.    

<img src="http://i.imgur.com/20BG5kB.png">


    
#### Options
The helper method takes the following options as named parameters:    

`auto_upload:`, defaults to `false`. Configures wether files have to be uploaded manually or are automatically uploaded after selecting them / dragging them into the browser window.    

`filetypes:`, defaults to `undefined`, so all filetypes are allowed. You can specify a list of allowed filetypes: `filetypes: "jpg jpeg gif png"`.    

`max_files:`, determines how many files can be uploaded at the same time. Defaults to `undefined`, so infinite uploads are possible.

`max_file_size_mb:`, defaults to `undefined`, so files up to 4GB are possible.    

`preview_max_width/height:`, defaults to `80`. The value specified will set the size of the generated thumbnail in the upload/download template.    

In some cases you don't want to provide the full UI, so the elements of the "Basic Plus" UI can be deactivated manually (all default to `true`):    

`start_all_button: true/false`    
`cancel_all_button: true/false`    
`delete_all_button: true/false`    
`checkboxes: true/false`

### JavaScript
rails4_jquery_upload handles the AJAX calls that upload the files in the background and stores them in the database via e.g. carrierwave, but in case you have more models involved more setup is necessary. To give a more realistic example, the demo application in the spec/dummy folder implements a simple belongs_to/has_many scenario between tasks and attachments: A task has many attachments, uploads are associated with the "file" column of attachments. To wire up the relationship and the correct associations by submitting the enclosing "task" model you have to handle the submit yourself.    
In your CoffeeScript file for the enclosing model you would do something like this:    

    $(document).ready ->
      $("#submit_enclosing_model").click ->
        ids = []
        $(".delete-elem").each ->
          ids.push $(this).attr("data-url").replace("/engine_mountpoint/uploads/pluralized_target_model/", "")
        $("[name='hidden_pluralized_target_model']").val ids

The uploader uses hidden fields to submit the target model name ("attachments") to the controller handling the assignment of AJAXy uploaded files (`tasks_controller.rb`).
For our tasks/attachments scenario the corresponding CoffeeScript looks like this:

    $(document).ready ->
      $("#submit_task").click ->
        ids = []
        $(".delete-elem").each ->
          ids.push $(this).attr("data-url").replace("/rails4_jquery_upload/uploads/attachments/", "")
        $("[name='hidden_attachments']").val ids


### Controller
In the controller you do the actual assignment of already AJAXy uploaded files to the enclosing model you are about to save. rails4_jquery_upload provides helper methods so you don't have to care about the JSON hash jQuery File Uploader requires from submitted data.    
First of all, calling the `has_jquery_uploads` class method enables you to use the following methods in any of your controllers:

`jquery_upload_json_response(upload_models, name, file_uploader_mountpoint, engine_mountpoint)`    
`jquery_upload_model_ids(hidden_field_name)`    

To continue the example from above, the necessary actions have to be taken in the `create`, `edit` and `update` actions of the `TasksController`. In `create` and `update` you handle the assignment of attachments to tasks, the `edit` action has to handle the retrieval of uploaded attachments via JSON so jQuery File Uploader understands it. Using the provided helper methods, the code for assigning attachments to tasks would look like this (`create` action accordingly):    

    def update
      @task = Task.find(params[:id])
      attachment_ids = jquery_upload_model_ids("hidden_attachments")
      @task.attachments = Attachment.find(attachment_ids)
      if @task.update(task_parameters)
      ...
As you can see, all you need to set up is the model name in plural with a `hidden_` prefix, as illustrated above.    
The code to drag all uploaded attachments for a given task from the database in a way the uploader understands would look like this:    

    def edit
      @task = Task.find(params[:id])
      respond_to do |format|
        format.html
        format.json {
          jquery_upload_json_response(@task.attachments, "attachments", "file", "/rails4_jquery_upload")
        }
      end
    end
You have to supply the objects to render themselves, the target model name in plural, the mountpoint of your file uploader and the engine mountpoint. No more manual fiddling with JSON is required!


### Model
Except of configuring your file uploader (carrierwave, dragonfly etc.) no additional setup is necessary.

### Restricting uploads
The uploader uses two methods to check for the ability to alter uploads:    
`can_upload?(model_name)`and     
`can_delete?(model_name)`.    
You have to define those in the `ApplicationController` of the enclosing app, and if you don't want to impose any restrictions, you just let them return `true`. Since in the `ApplicationController` you have access to authentication facilities like `current_user`, you can easily set up rules like this:    

    def can_upload?(model_name)
      current_user.admin? && model_name == "attachments"
    end

Keep in mind that not configuring any restrictions lets anyone target the `DELETE` request used by jQuery File Uploader which is not not preferable in most scenarios.

### To recap
* Call the `jquery_fileupload` helper method in your view
* Make sure you submit the ids of the already uploaded objects via JavaScript
* Call the `has_jquery_uploads` class method in your controller
* Fetch the ids of the uploaded objects in your `create` and `update` actions via `jquery_upload_model_ids`
* Use `jquery_upload_json_response` in your `edit` action to display uploaded objects
* Restrict uploads to not expose the `DELETE` request

## Coming real soon
* Support for multiple upload forms on one page
* Support for drop zone settings

