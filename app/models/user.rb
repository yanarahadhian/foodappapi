class User < ActiveRecord::Base
  has_secure_password

  # convert content from database into OpenStruct ruby class
  serialize :settings, OpenStruct

  # relations
  has_many :stores, :dependent => :destroy
  has_many :items, :dependent => :destroy
  has_many :images, :dependent => :destroy

  # return true if access_token is still valid
  def self.verify_token(token)
    user = User.find_by_access_token(token)
    return false if user.nil?

    # simple validation, TODO: improve this validation
    !user.token_generated_at.blank? && user.access_token.split('').count.eql?(32)
  end

  # return qualified object (JSON) for API user
  def qualify_auth_object(as_new_user = false)
    raw = self.attributes.slice('id', 'email', 'full_name', 'access_token', 'token_generated_at').merge({ :new_user => as_new_user })
    raw['token_generated_at'] = self.token_generated_at.to_s
    raw
  end

  # return qualified object (JSON) for API user
  def qualify_profile_object
    items = self.items.map(&:qualify_response_object)
    email_subscribe = self.settings.email_subscribe ? true : false
    avatar_url = self.avatar.url rescue ''
    background_url = self.background.url rescue ''

    {
      :user => {
        :name => self.full_name,
        :avatar => url_absolute(avatar_url),
        :background => url_absolute(background_url),
        :location => {
          :country => self.country,
          :city => self.city
        },
        :phone => self.phone,
        :love_count => 0,
        :wide_smile_count => 0,
        :smile_count => 0,
        :flat_count => 0,
        :nope_count => 0,
        :follower_count => 0,
        :following_count => 0,
        :like_count => 0,
        :created_at => self.created_at.to_s,
        :homepage => self.website_url,
        :description => self.about_me,
        :settings => {
          :email_subscribe => email_subscribe
        }
      },
      :items => items
    }
  end

  # return or generate token for mobile apps
  def generate_access_token
    if User.verify_token(self.access_token)
      self.access_token
    else
      loop do
        token = SecureRandom.urlsafe_base64(24)
        status = self.update(:access_token => token) rescue false
        self.update(:token_generated_at => DateTime.now) and break token if status
      end
    end
  end

  # expire generated token
  def expiry_token
    self.update(:access_token => nil, :token_generated_at => nil) if User.verify_token(self.access_token)
  end

  # helper method to get avatar image storage
  def avatar
    self.images.find_or_create_by(:flag => 'avatar').storage
  end

  # helper method to get background image storage
  def background
    self.images.find_or_create_by(:flag => 'background').storage
  end

  # helper method to set avatar image storage
  def avatar=(image)
    self.images.find_or_create_by(:flag => 'avatar').update(:storage => image) rescue nil
  end

  # helper method to set background image storage
  def background=(image)
    self.images.find_or_create_by(:flag => 'background').update(:storage => image) rescue nil
  end
end
