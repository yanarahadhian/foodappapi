# if you need custom method that globally accessed, put it here

# return absolute URL from a relative url
def url_absolute(relative_url)
  unless relative_url.blank?
    case Rails.env
    when 'development'
      host = 'http://localhost:3000'
    when 'staging'
      host = 'http://apifoodapp.stagingapps.net'
    when 'production'
      host = '**CHANGE HOSTNAME HERE**'
    end

    URI::join(host, relative_url).to_s
  end
end

# return currency code based on given ISO-1366 2 chars country code
def currency_of(country)
  Country.find_country_by_name.currency.code rescue 'USD'
end

Date::DATE_FORMATS[:default] = '%Y-%m-%d'
Time::DATE_FORMATS[:default] = '%Y-%m-%d %H:%M'
