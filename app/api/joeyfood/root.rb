class Joeyfood::Root < Grape::API
  mount Joeyfood::V1::Root
end
