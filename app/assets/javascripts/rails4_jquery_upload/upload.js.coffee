$(document).ready ->
  language = window.navigator.userLanguage || window.navigator.language
  targets = []
  $('*[data-target-model]').each ->
    targets.push $(this).data('target-model')
  for target in targets
    max_number_of_files    = $("##{target}-fileupload").data('max-files')
    max_size_of_files_mb   = $("##{target}-fileupload").data('max-filesize')
    max_file_size          = max_size_of_files_mb * 1000000

    preview_max_width      = $("##{target}-fileupload").data('preview-max-width')
    preview_max_height     = $("##{target}-fileupload").data('preview-max-height')

    filetypes = $("##{target}-fileupload").data('filetypes').split " "
    if filetypes != "undefined"
      regex_string = "(\\.|\\/)("
      for type in filetypes
        regex_string = regex_string + "|#{type}"
      regex_string = regex_string + ")$"
      filetypes = new RegExp(regex_string, "i")
    else
      filetypes = undefined

    $("##{target}-fileupload").fileupload
      dataType: "json"
      autoUpload: $(this).data('auto-upload')
      acceptFileTypes: filetypes
      maxNumberOfFiles: max_number_of_files
      maxFileSize: max_file_size
      disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator.userAgent)
      previewMaxWidth: preview_max_width
      previewMaxHeight: preview_max_height
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



    $("tbody.#{target}-files").on "DOMNodeInserted", (e) ->
      message = $(e.target).text()
      switch message
        when "File type not allowed"
          $(e.target).text("Dateityp nicht erlaubt") if language == "de"
        when "Maximum number of files exceeded"
          $(e.target).text("Maximale Anzahl von Dateien erreicht") if language == "de"
        when "File is too large"
          $(e.target).text("Die Datei ist zu groß") if language == "de"

