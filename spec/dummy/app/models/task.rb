class Task < ActiveRecord::Base
  has_many :attachments, dependent: :destroy
end
