require "spec_helper"


describe ApplicationController do
  it "responds to can_upload?" do
    expect(ApplicationController.new.respond_to? :can_upload?).to be true
  end

  it "responds to can_delete?" do
    expect(ApplicationController.new.respond_to? :can_delete?).to be true
  end
end


feature "Restrictions on uploading" do
  describe "uploading attachments with restrictions" do

    context "with restriction checks returning true", :js do
      allow_any_instance_of(ApplicationController)
        .to receive(:can_upload?).and_return(true)
      allow_any_instance_of(ApplicationController)
        .to receive(:can_delete?).and_return(true)

      scenario "attachments can be uploaded" do
        visit root_path
        click_link "New Task"
        attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
        expect(page).to have_css "tr.template-upload.fade.in"
        expect(page).to have_css "span.preview"
        click_button "Start"
        wait_for_ajax
        expect(Attachment.count).to eql 1
      end

      scenario "attachments can be deleted" do
        visit root_path
        click_link "New Task"
        attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
        expect(page).to have_css "tr.template-upload.fade.in"
        expect(page).to have_css "span.preview"
        click_button "Start"
        wait_for_ajax
        expect(Attachment.count).to eql 1

        click_button("Delete")
        wait_for_ajax
        expect(Attachment.count).to eq 0
      end
    end

    context "with restriction checks returning false", :js do
      scenario "attachments can not be uploaded" do
        allow_any_instance_of(ApplicationController)
          .to receive(:can_upload?).and_return(false)
        visit root_path
        click_link "New Task"
        attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
        expect(page).to have_css "tr.template-upload.fade.in"
        expect(page).to have_css "span.preview"
        click_button "Start"
        expect(page).to have_text "Error"
        expect(page).to have_text "Bad Gateway"
      end

      scenario "attachments can be uploaded but not deleted" do
        allow_any_instance_of(ApplicationController)
          .to receive(:can_upload?).and_return(true)
        allow_any_instance_of(ApplicationController)
          .to receive(:can_delete?).and_return(false)

        visit root_path
        click_link "New Task"
        attach_file("files[]", "#{Rails.root}/spec/fixtures/question_mark.png")
        expect(page).to have_css "tr.template-upload.fade.in"
        expect(page).to have_css "span.preview"
        click_button "Start"
        wait_for_ajax
        expect(Attachment.count).to eql 1
        click_button("Delete")
        expect(Attachment.count).to eql 1
        expect(page).to have_css "span.preview"
      end
    end

  end
end

