class Joeyfood::V1::Root < Grape::API
  mount Joeyfood::V1::Authentication
  mount Joeyfood::V1::Users
  mount Joeyfood::V1::Stores
  mount Joeyfood::V1::Items
  mount Joeyfood::V1::Miscellaneous

  version 'v1'
  default_format :json

  add_swagger_documentation(:base_path => '/',
                            :hide_documentation_path => true,
                            :api_version => self.version,
                            :markdown => GrapeSwagger::Markdown::KramdownAdapter)
end
