class Joeyfood::V1::Items < Grape::API
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

  namespace :items, :desc => 'Food items' do
    #============================================
    # GET /items/top
    desc 'Get the most top and popular items in the given country or city, or in the given coordinate.', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        # DON'T USE, UNDER CONSTRUCTION!!!

        **REQUIRE: send access token via HTTP header with 'authorize' header name**
      NOTES
    }
    params do
      optional :country, :type => String, :desc => 'Specify by country'
      optional :city, :type => String, :desc => 'Specify by city'
      optional :latlong, :type => String, :desc => 'Specify by coordinate (separated by comma)'
    end
    get '/top' do
      error! 'Under construction', 501
    end

    #============================================
    # POST /items/add
    desc 'Create new food item for current user.', {
      :http_codes => [
        [201, 'Item created successfully'],
        [400, "Invalid request / Field doesn't meet validation requirement"],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "item": {
                    "id": 1,
                    "category":
                    {
                        "id": 1,
                        "name": "Pizza"
                    },
                    "seller":
                    {
                        "id": 2,
                        "full_name": "Soap MacTavish",
                        "avatar": "http://img2.wikia.nocookie.net/__cb20120122010801/callofduty/images/b/b7/Soap_MW3_model.png",
                        "background": "http://img06.deviantart.net/f8c9/i/2011/325/f/7/call_of_duty__soap_and_ghost_by_decanandersen-d4gvfw7.jpg",
                        "contact": "0222078787"
                    },
                    "name": "Meat Lovers",
                    "price": "10.00",
                    "currency": "SGD",
                    "delivery_price": "0.50",
                    "description": "The only one Pizza full with meat",
                    "like_count": 120,
                    "liked": false,
                    "images":
                    [
                        "http://www.thepizzabox.com.au/images/Meatlovers.png",
                        "http://www.mypizzahouse.com/wp-content/uploads/2012/02/meatloverpizza.jpg",
                        "https://thingsboganslike.files.wordpress.com/2011/04/meat-lovers-pizza.jpg"
                    ],
                    "pickup_locations":
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
                          "location": "No. 41 Bandung Kulon",
                          "phone": "(022) 6034643",
                          "city": "Bandung"
                        }
                    ],
                    "created_at": "2015-08-03 03:21PM"
                },
                "status": { "code": 201, "message": "Item created successfully" }
            }
      NOTES
    }
    params do
      requires :category_id, :type => Integer, :desc => 'Category id for this food item'
      requires :store_ids, :type => Integer, :desc => 'Store list where this item is sold'
      requires :name, :type => String, :desc => 'Food item name'
      optional :delivery_fee, :type => Float, :desc => 'Specify delivery fee'
      requires :price, :type => Float, :desc => 'Set food item price'
      optional :description, :type => String, :desc => 'Description for this food'
      requires :images, :type => Array[Rack::Multipart::UploadedFile], :desc => 'An array of food item images'
    end
    post '/add' do
      item = @user.items.build(:item_category_id => params[:category_id],
                               :name => params[:name],
                               :delivery_fee => params[:delivery_fee],
                               :price => params[:price],
                               :description => params[:description],
                               :store_ids => params[:store_ids])

      # process uploaded images
      params[:images].each do |image|
        storage = item.images.build(:storage => image)
        unless storage.save
          item.images.destroy_all
          error! "Field doesn't meet validation requirement - #{storage.errors.first.join(' ')}", 400
        end
      end

      error! "Field doesn't meet validation requirement - #{item.errors.first.join(' ')}", 400 unless item.save

      response = { :item => item.qualify_response_object }
      respond_json response, 201, 'Item created successfully'
    end
  end
end
