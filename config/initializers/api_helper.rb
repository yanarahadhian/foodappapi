# this class is used for API helper, if you need to call a REST to other API, put it here
class APIHelper
  # return facebook user object by giving facebook access token
  def self.get_facebook_object(token)
    return nil if token.blank?
    response = RestClient.get('https://graph.facebook.com/me', { :params => { :access_token => token } }) rescue nil
    JSON.parse(response) rescue nil
  end
end
