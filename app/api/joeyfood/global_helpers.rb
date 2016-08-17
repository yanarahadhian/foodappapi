# global helpers method goes here
module Joeyfood::GlobalHelpers
  extend Grape::API::Helpers

  # this method generate qualified response
  def respond_json(response_body, status_code = 200, status_message = 'Call successfully')
    response_body = nil unless response_body.class.eql? Hash
    status = { :status => { :code => status_code, :message => status_message } }
    response = response_body.nil? ? status : response_body.merge(status) rescue status
    response
  end

  # get current user from given token
  # NOTE: to prevent multiple database hit every calling this method, please store to local variable
  # IMP: maybe that can be avoided by using redis as cache to minimize database hit
  def current_user
    return nil unless headers['Authorize'].present?
    user = User.find_by_access_token(headers['Authorize'])
    error! 'Invalid token or unauthorized', 401 if user.nil? || !User.verify_token(headers['Authorize'])
    user
  end

  # smart choise for facebook authentication, auto decide register or signin
  def facebook_signup_or_signin(settings)
    raise 'Invalid settings given, instance of OpenStruct is required' unless settings.class.eql? OpenStruct

    error! 'Invalid request', 400 unless params[:token].present?
    fb_user = APIHelper.get_facebook_object(params[:token])
    error! 'Not authorized by service provider', 401 if fb_user.blank?
    user = User.find_by_facebook_id(fb_user['id'])
    is_new_user = false
    if user.nil?
      is_new_user = true
      user = User.create(:email => fb_user['email'],
                         :password => SecureRandom.urlsafe_base64,  # randomize user password
                         :full_name => params[:full_name],
                         :facebook_id => fb_user['id'],
                         :verified_fb => params[:token],
                         :settings => settings)
    end
    user.update(:verified_fb => params[:token]) unless user.verified_fb.eql? params[:token]
    error! "Field doesn't meet validation requirement - #{user.errors.first.join(' ')}", 400 unless user.valid?

    { :user => user, :is_new_user => is_new_user }
  end
end
