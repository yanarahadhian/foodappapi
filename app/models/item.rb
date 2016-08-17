class Item < ActiveRecord::Base
  # relations
  has_many :images, :dependent => :destroy
  belongs_to :item_category
  belongs_to :seller, :foreign_key => 'user_id', :class_name => 'User'
  has_and_belongs_to_many :stores

  # validation
  validates :item_category, :name, :price, :images, :presence => true

  # return qualified object (JSON) for API user
  def qualify_response_object
    {
      :id => self.id,
      :category => { :id => self.item_category.id, :name => self.item_category.name },
      :seller => {
        :id => self.seller.id,
        :full_name => self.seller.full_name,
        :avatar => url_absolute(self.seller.avatar.url),
        :background => url_absolute(self.seller.background.url),
        :contact => self.seller.phone
      },
      :name => self.name,
      :price => sprintf('%.2f', self.price),
      :currency => currency_of(self.seller.country),
      :delivery_price => self.delivery_fee,
      :description => self.description,
      :like_count => 10,
      :liked => false,
      :images => self.images.map { |img| url_absolute(img.storage.url) },
      :pickup_locations => self.stores.map(&:qualify_response_object),
      :created_at => self.created_at.to_s
    }
  end
end
