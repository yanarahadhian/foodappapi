class Joeyfood::V1::Users < Grape::API
  helpers Joeyfood::GlobalHelpers
  error_formatter :json, Joeyfood::GrapeErrorFormatter

  # before action callback
  # NOTE: all endpoints will call this, it's means all endpoints here must have Authorize header
  before do
    error! 'Invalid request', 400 unless headers['Authorize'].present?
    @user = current_user
  end

  version 'v1'
  default_format :json

  namespace :users, :desc => 'User accounts information' do
    #============================================
    # GET /users/profile
    desc 'Get complete current user profile.', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "user":
                {
                    "name": "Soap MacTavish",
                    "avatar": "http://img2.wikia.nocookie.net/__cb20120122010801/callofduty/images/b/b7/Soap_MW3_model.png",
                    "background": "http://img06.deviantart.net/f8c9/i/2011/325/f/7/call_of_duty__soap_and_ghost_by_decanandersen-d4gvfw7.jpg"
                    "location":
                    {
                        "country": "Indonesia",
                        "city": "Bandung"
                    },
                    "phone": "089656339415",
                    "love_count": 1,
                    "wide_smile_count": 2,
                    "smile_count": 3,
                    "flat_count": 4,
                    "nope_count": 5,
                    "follower_count": 0,
                    "following_count": 0,
                    "like_count": 2,
                    "created_at": "2015-08-03 03:21PM",
                    "homepage": "https://www.google.com",
                    "description": "Lorem ipsum dolor sit amet.",
                    "settings":
                    {
                        "email_subscribe": false
                    }
                },
                "items":
                [
                    items_object
                ],
                "status": { "code": 200, "message": "Call successfully" }
            }
      NOTES
    }
    get '/profile' do
      response = @user.qualify_profile_object
      respond_json response
    end

    #============================================
    # POST /users/profile/edit
    desc 'Edit current user profile.', {
      :http_codes => [
        [200, 'User updated successfully'],
        [400, "Invalid request / Field doesn't meet validation requirement"],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "user":
                {
                    "name": "Soap MacTavish",
                    "avatar": "http://img2.wikia.nocookie.net/__cb20120122010801/callofduty/images/b/b7/Soap_MW3_model.png",
                    "background": "http://img06.deviantart.net/f8c9/i/2011/325/f/7/call_of_duty__soap_and_ghost_by_decanandersen-d4gvfw7.jpg"
                    "location":
                    {
                        "country": "Indonesia",
                        "city": "Bandung"
                    },
                    "phone": "089656339415",
                    "love_count": 1,
                    "wide_smile_count": 2,
                    "smile_count": 3,
                    "flat_count": 4,
                    "nope_count": 5,
                    "follower_count": 0,
                    "following_count": 0,
                    "like_count": 2,
                    "created_at": "2015-08-03 03:21PM",
                    "homepage": "https://www.google.com",
                    "description": "Lorem ipsum dolor sit amet.",
                    "settings":
                    {
                        "email_subscribe": false
                    }
                },
                "items":
                [
                    items_object
                ],
                "status": { "code": 200, "message": "Call successfully" }
            }
      NOTES
    }
    params do
      requires :name, :type => String, :desc => 'User full name'
      requires :location, :type => String, :desc => 'Location string, separated by comma "city,country"'
      optional :avatar, :type => Rack::Multipart::UploadedFile, :desc => 'Avatar image'
      optional :background, :type => Rack::Multipart::UploadedFile, :desc => 'Background image'
      optional :description, :type => String, :desc => 'User description or about me'
      optional :homepage, :type => String, :desc => 'User defined homepage'
      optional :email_subscribe, :type => Integer, :desc => 'Email subscribe (1 for true, 0 for false)'
      optional :phone, :type => String, :desc => 'User phone contact number'
    end
    post '/profile/edit' do
      city, country = params[:location].split(',')

      settings = OpenStruct.new
      settings.email_subscribe = params[:email_subscribe] || false

      status = @user.update(:full_name => params[:name],
                            :country => country,
                            :city => city,
                            :about_me => params[:description],
                            :website_url => params[:homepage],
                            :phone => params[:phone],
                            :settings => settings)
      error! "Field doesn't meet validation requirement - #{@user.errors.first.join(' ')}", 400 unless status

      @user.avatar, @user.background = [params[:avatar], params[:background]]

      response = @user.qualify_profile_object
      respond_json response
    end

    #============================================
    # GET /users/:user_id/pickupaddresses
    desc 'Get stores owned by given user.', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized'],
        [404, 'User not found']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "stores":
                [
                    {
                        "id": 1,
                        "name": "Pizza Hut",
                        "country": "Indonesia",
                        "street": "Jl. Merdeka",
                        "latlong": "-6.908507,107.610747",
                        "location": "Bandung Indah Plaza Lt. 1",
                        "phone": "089678968123",
                        "city": "Bandung"
                    },
                    {
                        "id": 2,
                        "name": "Sinar Minang",
                        "country": "Indonesia",
                        "street": "Jl. Soekarno Hatta",
                        "latlong": "-6.9345037,107.5801149",
                        "location": "No.41No.41No.41No. 41 Bandung Kulon",
                        "phone": "(022) 6034643",
                        "city": "Bandung"
                    }
                ],
                "status": { "code": 200, "message": "Call successfully" }
            }
      NOTES
    }
    params do
      requires :user_id, :type => Integer, :desc => 'User ID to list the stores'
    end
    get '/:user_id/pickupaddresses' do
      user = User.find(params[:user_id]) rescue nil
      error! 'User not found', 404 if user.nil?

      response = { :stores => user.stores.map(&:qualify_response_object) }
      respond_json response
    end
  end
end
