Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  mount Joeyfood::Root => '/'
  mount GrapeSwaggerRails::Engine => '/:version/documentations'

  root 'home#index'
end
