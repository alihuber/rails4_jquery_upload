$(document).ready ->
 $("#submit_task").click ->
   ids = []
   $(".delete-elem").each ->
     ids.push $(this).attr("data-url").replace("/rails4_jquery_upload/uploads/attachments/", "")
   $("[name='hidden_attachments']").val ids
