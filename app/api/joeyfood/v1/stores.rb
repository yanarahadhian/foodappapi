class Joeyfood::V1::Stores < Grape::API
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

  namespace :stores, :desc => 'Food item stores.' do
    #============================================
    # POST /stores/add
    desc 'Create new store for current user', {
      :http_codes => [
        [201, 'Store created successfully'],
        [400, "Invalid request / Field doesn't meet validation requirement"],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "item":
                {
                    "id": 1,
                    "name": "Cibaduyut Shoes",
                    "country": "Indonesia",
                    "city": "Bandung",
                    "latlong": "5,-12",
                    "location": "Gigireun SPBU",
                    "phone": "123456789",
                    "seller_id": 1
                },
                "status": { "code": 201, "message": "Store created successfully" }
            }
      NOTES
    }
    params do
      requires :name, :type => String, :desc => 'Store name'
      requires :country, :type => String, :desc => 'Country where the store is located'
      requires :street, :type => String, :desc => 'Street name'
      requires :latlong, :type => String, :desc => 'Coordinate (separated by comma)'
      requires :location, :type => String, :desc => 'Location detail'
      requires :city, :type => String, :desc => 'City where the store is located'
      optional :phone, :type => String, :desc => 'Store phone number'
    end
    post '/add' do
      store = @user.stores.build(:name => params[:name], :country => params[:country],
                                 :street => params[:street], :latlong => params[:latlong],
                                 :location => params[:location], :phone => params[:phone],
                                 :city => params[:city])
      error! "Field doesn't meet validation requirement - #{store.errors.first.join(' ')}", 400 unless store.save

      response = { :store => store.qualify_response_object }
      respond_json response, 201, 'Store created successfully'
    end

    #============================================
    # POST /stores/:store_id/edit
    desc 'Edit store owned by current user.', {
      :http_codes => [
        [200, 'Store updated successfully'],
        [400, "Invalid request / Field doesn't meet validation requirement"],
        [401, 'Invalid token or unauthorized'],
        [404, 'Store not found']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "item":
                {
                    "id": 1,
                    "name": "Cibaduyut Shoes",
                    "country": "Indonesia",
                    "city": "Bandung",
                    "latlong": "5,-12",
                    "location": "Gigireun SPBU",
                    "phone": "123456789",
                    "seller_id": 1
                },
                "status": { "code": 200, "message": "Store updated successfully" }
            }
      NOTES
    }
    params do
      requires :store_id, :type => Integer, :desc => 'Store ID to be edited'
      requires :name, :type => String, :desc => 'Store name'
      requires :country, :type => String, :desc => 'Country where the store is located'
      requires :street, :type => String, :desc => 'Street name'
      requires :latlong, :type => String, :desc => 'Coordinate (separated by comma)'
      requires :location, :type => String, :desc => 'Location detail'
      requires :city, :type => String, :desc => 'City where the store is located'
      optional :phone, :type => String, :desc => 'Store phone number'
    end
    post '/:store_id/edit' do
      store = @user.stores.find(params[:store_id]) rescue nil
      error! 'Store not found', 404 if store.nil?

      status = store.update(:name => params[:name],
                            :country => params[:country],
                            :street => params[:street],
                            :latlong => params[:latlong],
                            :location => params[:location],
                            :phone => params[:phone],
                            :city => params[:city])
      error! "Field doesn't meet validation requirement - #{store.errors.first.join(' ')}", 400 unless status

      response = { :store => store.qualify_response_object }
      respond_json response
    end

    #============================================
    # DELETE /stores/:store_id/delete
    desc 'Delete store owned by current user.', {
      :http_codes => [
        [200, 'Store deleted successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized'],
        [404, 'Store not found']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "status": { "code": 200, "message": "Store deleted successfully"
            }
      NOTES
    }
    params do
      requires :store_id, :type => Integer, :desc => 'Store ID to be deleted'
    end
    delete '/:store_id/delete' do
      store = @user.stores.find(params[:store_id]) rescue nil
      error! 'Store not found', 404 if store.nil?
      store.destroy

      respond_json nil, 200, 'Store deleted successfully'
    end
  end
end
