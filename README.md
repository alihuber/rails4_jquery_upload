rails4_jquery_upload
====================

Rails mounted engine for uploading files with [jQuery File Uploader](http://blueimp.github.io/jQuery-File-Upload/).
Example usage is shown in the spec/dummy directory.



## Features
* Abstracts away the need for any additional code in the model
* Provides convienient helper methods for building the proper JSON response and a configurable upload form in the view
* Requires minimal JavaScript and controller setup
* File uploader agnostic, works with carrierwave, should work with dragonfly (untested)
* Encapsulates all needed gems in one engine
* Lets you define custom restrictions on the ability to upload, e.g. on model type or authentication based
* Uses the latest version of blueimp-file-upload, loaded from [rails-assets.org](https://rails-assets.org/)



## Installation
Add the engine and the rails-assets source to your `Gemfile`:    

    source "https://rails-assets.org"
    gem "rails4_jquery_upload", git: "alihuber/rails4_jquery_upload", branch: "master"
then `bundle install`.
    
In your `routes.rb` mount the uploader to the destination you desire:    

    mount Rails4JqueryUpload::Engine => "/rails4_jquery_upload"    
Require the extra CSS and JavaScript:

    // app/assets/javascripts/application.js:
    //= require rails4_jquery_upload/application
    
    /* app/assets/stylesheets/application.css.scss: */
     *= require rails4_jquery_upload/application

and you're good to go!


## Usage
### View
The `jquery_fileupload` helper method includes all the necessary HTML for including the uploader form in your view and takes the following required arguments:

        = jquery_fileupload("/engine_mountpoint", "model_name_plural", "uploader_attached_attribute")

Say, you mounted the engine like above, have an "`attachment`"-model with the carrierwave uploader mounted to the "`file`"-column, so your call would look like this:

    = jquery_fileupload("/rails4_jquery_upload", "attachments", "file")

This gives you a "Basic Plus UI" uploader form with grey buttons:    

[<img src="http://i.imgur.com/20BG5kB.png">]


    
#### Options
The helper method takes the following options as named parameters:    

`auto_upload:`, defaults to `false`. Configures wether files have to be uploaded manually or are automatically uploaded after selecting them / dragging them into the browser window.    

`filetypes:`, defaults to `undefined`, so all filetypes are allowed. You can specify a list of allowed filetypes: `filetypes: "jpg jpeg gif png"`.    

`max_files:`, defaults to `undefined`, so infinite uploads are possible.

`max_file_size_mb:`, defaults to `undefined`, so files up to 4GB are possible.    

`preview_max_width/height:`, defaults to `80`. The value specified will set the size of the generated thumbnail in the upload/download template.    

In some cases you don't want to provide the full UI, so the elements of the "Basic Plus" UI can be deactivated manually (all default to `true`):    

`start_all_button: true/false`    
`cancel_all_button: true/false`    
`delete_all_button: true/false`    
`checkboxes: true/false`

### JavaScript
The uploader handles the AJAX calls that upload the files and stores them via e.g. carrierwave, but in case you have more models involved more setup is necessary. The demo application in the `spec/dummy` folder implements a simple `belongs_to`/`has_many` scenario between tasks and attachments, and to wire up the relationship and the correct associations by submitting the enclosing model you have to handle the submit yourself.    
The uploader uses hidden fields to submit the target model name to the controller handling the assignment of uploaded files. In your CoffeeScript file for the enclosing model you would do something like this:    

    $(document).ready ->
      $("#submit_enclosing_model").click ->
        ids = []
        $(".delete-elem").each ->
          ids.push $(this).attr("data-url").replace("/engine_mountpoint/uploads/target_model_plural/", "")
        $("[name='hidden_target_model_plural']").val ids

For our tasks/attachments scenario the corresponding CoffeeScript looks like this:

    $(document).ready ->
      $("#submit_task").click ->
        ids = []
        $(".delete-elem").each ->
          ids.push $(this).attr("data-url").replace("/rails4_jquery_upload/uploads/attachments/", "")
        $("[name='hidden_attachments']").val ids

That way, minimal setup is required in the `TasksController` for assigning uploaded attachments to the submitted task.

### Controller
In the controller you do the actual assignment of already uploaded files to the submitted enclosing model. The engine provides helper methods defined in the `has_upload_concern.rb` file so you don't have to care about the JSON hash the jQuery File Uploader requires from submitted data.    
First of all, by calling the `has_jquery_uploads` class method which is defined in the engine's `ApplicationController` enables you to use the following methods in any of your controllers:    

`jquery_upload_json_response(upload_models, name, mountpoint)`    
`jquery_upload_model_ids(hidden_field_name)`    

To continue the example from above, the necessary actions have to be taken in the `create`, `edit` and `update` actions of the `TasksController`. In `create` and `update` you handle the assignment of attachments to tasks, the `edit` action has to handle the retrieval of uploaded attachments in a JSON-fashion the uploader understands. Using the provided helper methods, the code for assigning attachments to tasks would look like this (`edit` action accordingly):    

    def update
      @task = Task.find(params[:id])
      attachment_ids = jquery_upload_model_ids("hidden_attachments")
      @task.attachments = Attachment.find(attachment_ids)
      if @task.update(task_parameters)
      ...
As you can see, all you need to set up is the model name in plural with a `hidden_`-prefix, as illustrated above.    
The code to drag all uploaded attachments for a given task from the database in a way the uploader understands would look like this:    

    def edit
      @task = Task.find(params[:id])
      respond_to do |format|
        format.html
        format.json {
          jquery_upload_json_response(@task.attachments, "attachments", "file")
        }
      end
    end
You have to supply the objects themselves, and again the target model name in plural and the mountpoint of your file uploader. No more manual fiddling with JSON is required! 


### Model
Except of mounting your file uploader (carrierwave, dragonfly etc.) no additional setup is necessary.

### Restricting uploads
The uploader uses two methods to check for the ability to alter uploads:   
`can_upload?(model_name)`and     
`can_delete?(model_name)`.    
You have to define those in the `ApplicationController` of the enclosing app, and if you don't want to impose any restrictions, you just let return them `true`. Since in the `ApplicationController` you have access to authentication facilities like `current_user`, you can easily set up rules like this:    

    def can_upload?(model_name)
      current_user.admin? && model_name == "attachments"
    end

## Coming real soon
* Support for multiple upload forms on one page
* Support for drop zone settings
