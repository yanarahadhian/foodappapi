class Image < ActiveRecord::Base
  mount_uploader :storage, ImageUploader

  # relations
  belongs_to :item
  belongs_to :user
end
