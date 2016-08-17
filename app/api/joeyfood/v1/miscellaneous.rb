class Joeyfood::V1::Miscellaneous < Grape::API
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

  namespace :misc, :desc => 'Miscellaneous API feature function' do
    #============================================
    # GET /misc/categories
    desc 'Return the list of available categories.', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "categories": [
                    { "id": 1, "name": "Pizza" },
                    { "id": 2, "name": "Cake" },
                    { "id": 3, "name": "Snack" }
                ],
                "status": { "code": 200, "message": "Call successfully" }
            }
      NOTES
    }
    get '/categories' do
      response = { :categories => ItemCategory.select(:id, :name) }
      respond_json response
    end

    #============================================
    # GET /misc/countries
    desc 'FOR DEVELOPMENT ONLY', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**
      NOTES
    }
    get '/countries' do
      arr = []
      countries = [:id]

      countries.each do |country|
        cities = []
        provinces = CS.get country
        provinces.each do |province_code, province_name|
          CS.get(country, province_code).each do |city|
            cities << { :name => city }
          end
        end
        arr << { :country_id => country.upcase, :country_name => Country[country].name, :cities => cities }
      end

      response = { :countries => arr }
      respond_json response
    end
  end
end
