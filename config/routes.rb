Rails.application.routes.draw do
  namespace :api, { format: 'json' } do
    namespace :v1 do
      get '/idea', to: 'api#get'
      post '/idea', to: 'api#create'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
