$(document).ready ->
  targets = []
  $('*[data-target-model]').each ->
    targets.push $(this).data('target-model')
  for target in targets
    $("##{target}-fileupload").fileupload
      dataType: "json"
      autoUpload: $(this).data('auto-upload')
      acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i
      maxFileSize: 5000000
      disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent)
      previewMaxWidth: 100
      previewMaxHeight: 100
      previewCrop: true
      filesContainer: $("tbody.#{target}-files")

    # load existing files
    $.getJSON $("##{target}-fileupload").prop("action"), (files) ->
      fu = $("##{target}-fileupload").data("blueimp-fileupload")
      template = fu._renderDownload(files)
      $("tbody.#{target}-files").append(template)

      # Force reflow:
      fu._reflow = fu._transition and template.length and template[0].offsetWidth
      template.addClass "in"
      $("#loading").remove()


    # we have to handle these ourselves
    $(".start").on "click", ->
      $("tbody.#{target}-files").find(".start").click()

    $(".cancel").on "click", ->
      $("tbody.#{target}-files").find(".cancel").click()

    $(".delete-toggle").click ->
      if $(this).is(":checked")
        $("tbody.#{target}-files").find(".toggle").prop "checked", true
      else
        $("tbody.#{target}-files").find(".toggle").prop "checked", false

    $(".delete").click ->
      $("tbody.#{target}-files").find(".toggle:checked").closest(".template-download").find(".delete").click()
      $(".delete-toggle").prop "checked", false


    $("#submit_task").click ->
      ids = []
      $(".delete-elem").each ->
        ids.push $(this).attr("data-url").replace("/#{target}/", "")
      $("#submitted_#{target}").val ids
