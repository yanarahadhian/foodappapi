class Joeyfood::V1::Authentication < Grape::API
  helpers Joeyfood::GlobalHelpers
  error_formatter :json, Joeyfood::GrapeErrorFormatter

  version 'v1'
  default_format :json

  namespace :auth, :desc => 'User authorization' do
    #============================================
    # POST /auth/login
    desc 'Authorize user credentials to get token for accessing the entire application.', {
      :http_codes => [
        [200, 'User logged in successfully'],
        [400, 'Invalid request'],
        [401, 'Not authorized by service provider / User not registered'],
        [403, 'Invalid email or password']
      ],
      :notes => <<-NOTES
        If provider is email, then email and password parameters is required. Otherwise if provider is facebook or gplus, then token parameter is required. Below is response sample:

            {
                "user":
                {
                    "id": "1",
                    "email": "jeremyclarkson@mailinator.com",
                    "full_name": "Jeremy Clarkson",
                    "access_token": "32 characters unique token",
                    "token_generated_at": "2015-08-03T03:21:34.287Z",
                    "new_user": false
                },
                "status": { "code": 200, "message": "User logged in successfully" }
            }
      NOTES
    }
    params do
      requires :provider, :type => String, :desc => 'Login provider', :values => %w(email facebook gplus)
      optional :token, :type => String, :desc => 'Token for NON email provider'
      optional :email, :type => String, :desc => 'User email'
      optional :password, :type => String, :desc => 'User password'
    end
    post '/login' do
      is_new_user = false

      case params[:provider]
      when 'email'
        user = User.find_by_email(params[:email])
        error! 'Invalid email or password', 403 if user.nil? || !user.authenticate(params[:password])

      when 'facebook'
        # setup settings struct
        settings = OpenStruct.new
        settings.email_subscribe = false
        raw = facebook_signup_or_signin(settings)
        user = raw[:user]
        is_new_user = raw[:is_new_user]

      when 'gplus'
        # TODO
        error! 'Not authorized by service provider', 401

      else
        error! 'Invalid request', 400
      end

      user.generate_access_token
      response = { :user => user.qualify_auth_object(is_new_user) }
      respond_json response, 200, 'User logged in successfully'
    end

    #============================================
    # POST /auth/logout
    desc 'Expiry and destroy the user token.', {
      :http_codes => [
        [204, 'User logged out successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**
      NOTES
    }
    post '/logout' do
      error! 'Invalid request', 400 unless headers['Authorize'].present?
      current_user.expiry_token
      status 204
    end

    #============================================
    # POST /auth/signup
    desc 'Create new account to get access to the application.', {
      :http_codes => [
        [201, 'User created successfully'],
        [400, "Invalid request / Field doesn't meet validation requirement"],
        [401, 'Not authorized by service provider']
      ],
      :notes => <<-NOTES
        If provider is email, then email and password parameters is required. Otherwise if provider is facebook or gplus, then token parameter is required. Below is response sample:

            {
                "user":
                {
                    "id": "1",
                    "email": "jeremyclarkson@mailinator.com",
                    "full_name": "Jeremy Clarkson",
                    "access_token": "32 characters unique token",
                    "token_generated_at": "2015-08-03T03:21:34.287Z",
                    "new_user": true
                },
                "status": { "code": 200, "message": "User logged in successfully" }
            }
      NOTES
    }
    params do
      requires :full_name, :type => String, :desc => 'User full name'
      requires :provider, :type => String, :desc => 'Login provider', :values => %w(email facebook gplus)
      optional :token, :type => String, :desc => 'Token for NON email provider'
      optional :email, :type => String, :desc => 'User email'
      optional :password, :type => String, :desc => 'User password'
      optional :email_subscribe, :type => Boolean, :desc => 'Is user subscribe to email updates?'
    end
    post '/signup' do
      is_new_user = true
      # setup settings struct
      settings = OpenStruct.new
      settings.email_subscribe = params[:email_subscribe] || false

      case params[:provider]
      when 'email'
        error! 'Invalid request', 400 unless params[:email].present? && params[:password].present?
        user = User.create(:email => params[:email],
                           :password => params[:password],
                           :full_name => params[:full_name],
                           :settings => settings) rescue nil
        error! 'User already exist', 403 if user.nil?
        error! "Field doesn't meet validation requirement - #{user.errors.first.join(' ')}", 400 unless user.valid?

      when 'facebook'
        raw = facebook_signup_or_signin(settings)
        user = raw[:user]
        is_new_user = raw[:is_new_user]

      when 'gplus'
        # TODO
        error! 'Not authorized by service provider', 401

      else
        error! 'Invalid request', 400
      end

      user.generate_access_token
      response = { :user => user.qualify_auth_object(is_new_user) }
      respond_json response, 201, 'User created successfully'
    end

    #============================================
    # GET /auth/verify_token
    desc 'Verify user access token, is still valid or not.', {
      :http_codes => [
        [200, 'Call successfully'],
        [400, 'Invalid request']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "token_validity": false,
                "status": { "code": 200, "message": "Call successfully" }
            }

      NOTES
    }
    get '/verify_token' do
      # self implementation for token verification
      error! 'Invalid request', 400 unless headers['Authorize'].present?
      user = User.find_by_access_token(headers['Authorize'])
      validity = !user.nil? && User.verify_token(headers['Authorize'])
      respond_json({ :token_validity => validity })
    end

    #============================================
    # POST /auth/change_password
    desc 'Change current user password.', {
      :http_codes => [
        [200, 'Password changed successfully'],
        [400, 'Invalid request'],
        [401, 'Invalid token or unauthorized']
      ],
      :notes => <<-NOTES
        **REQUIRE: send access token via HTTP header with 'authorize' header name**

        Estimated response:

            {
                "status": { "code": 200, "message": "Password changed successfully" }
            }

      NOTES
    }
    params do
      requires :new_password, :type => String, :desc => 'New user password'
    end
    post '/change_password' do
      error! 'Invalid request', 400 unless headers['Authorize'].present?
      user = current_user
      user.update(:password => params[:new_password])

      respond_json(nil, 200, 'Password changed successfully')
    end
  end
end
