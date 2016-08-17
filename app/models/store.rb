class Store < ActiveRecord::Base
  # relations
  belongs_to :seller, :foreign_key => 'user_id', :class_name => 'User'
  has_and_belongs_to_many :items

  # validations
  validates :name, :country, :city, :street, :latlong, :location, :presence => true

  # return qualified object (JSON) for API user
  def qualify_response_object
    self.attributes.except('user_id', 'created_at', 'updated_at').merge({ :seller_id => self.user_id })
  end
end
