GrapeSwaggerRails.options.app_name = 'Joey Food API'
GrapeSwaggerRails.options.app_url = '/'
GrapeSwaggerRails.options.before_filter do |request|
  version = params[:version]
  GrapeSwaggerRails.options.url = version + '/swagger_doc'
end
