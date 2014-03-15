require "spec_helper"

feature "File uploading" do

  describe "Uploading attachments" do
    before(:each) do
      visit root_path
      click_link "New Task"
      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_no_css "span.preview"
    end

    scenario "add files and cancel the upload", :js do
      attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
      expect(page).to have_css "tr.template-upload.fade.in"
      expect(page).to have_css "span.preview"

      within "tr.template-upload.fade.in" do
        expect(page).to have_css "button.cancel"
        click_button "Cancel"
      end
      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_no_css "span.preview"

      attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
      attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")

      expect(page.all("tr.template-upload.fade.in").count).to eq 2
      expect(page.all("span.preview").count).to eq 2

      within("div.jquery-upload-buttonbar") do
        find("span.btn-default.cancel").click
      end

      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_no_css "span.preview"
    end


    scenario "upload files", :js do
      # Rails.root = /rails4_jquery_upload/spec/dummy
      # upload single file with global upload button
      attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")

      expect(page).to have_css "tr.template-upload.fade.in"
      expect(page).to have_css "span.preview"

      click_button "Start"
      expect(page).to have_css "button.delete-elem"

      expect(Attachment.count).to eql 1
      # /tmp/uploads/attachment/file/17/question_mark.png
      expect(page).to have_link("question_mark.png",
        href: "/tmp/uploads/attachment/file/#{Attachment.last.id}/question_mark.png")


      # upload multiple files by global upload button
      attach_file("files[]", ["#{Rails.root}/spec/fixtures/question_mark2.png",
                                "#{Rails.root}/spec/fixtures/question_mark.png"
      ])
      expect(page).to have_css "tr.template-upload.fade.in", count: 2
      within("div.jquery-upload-buttonbar") do
        find("span.btn-default.start").click
      end
      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_css "span.preview", count: 3
      expect(page).to have_css "button.delete.delete-elem", count: 3
      expect(page).to have_link("question_mark2.png")
      expect(Attachment.count).to eq 3


      # upload multiple files by click on individual start buttons
      attach_file("files[]", ["#{Rails.root}/spec/fixtures/question_mark.png",
                                "#{Rails.root}/spec/fixtures/question_mark.png"
      ])
      expect(page).to have_css "tr.template-upload.fade.in", count: 2
      page.all("button.btn.btn-default.start").each do |button|
        button.click
      end
      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_css "span.preview", count: 5
      expect(page).to have_css "button.delete.delete-elem", count: 5
      expect(page).to have_link("question_mark.png",
        href: "/tmp/uploads/attachment/file/#{Attachment.last.id}/question_mark.png")
      expect(Attachment.count).to eq 5
    end


    scenario "add files and delete them again", :js do
      attach_file("files[]", ["#{Rails.root}/spec/fixtures/question_mark.png",
                                "#{Rails.root}/spec/fixtures/question_mark2.png"
      ])
      expect(page).to have_css "tr.template-upload.fade.in", count: 2
      within("div.jquery-upload-buttonbar") do
        find("span.btn-default.start").click
      end
      expect(page).to have_no_css "tr.template-upload.fade.in"
      expect(page).to have_css "span.preview", count: 2
      expect(page).to have_css "button.delete.delete-elem", count: 2
      expect(page).to have_link("question_mark.png")
      expect(page).to have_link("question_mark2.png")
      expect(Attachment.count).to eq 2
    end
  end

end

