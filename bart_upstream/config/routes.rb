Rails.application.routes.draw do
  
  devise_for :admins
  devise_for :users
  resources :bartstations

  resources :bartroutes

  resources :bartroutestations

  resources :bartjourneys
  
  get '/seed_stations' => 'bartstations#seed_bart_stations'

  get '/unseed_stations' => 'bartstations#unseed_bart_stations'

  get '/seed_bart_routes' => 'bartroutes#seed_bart_routes'

  get '/unseed_bart_routes' => 'bartroutes#unseed_bart_routes'

  get '/remove_bart_route_stations' => 'bartroutestations#remove_bart_route_stations'

  get '/testme' => 'bartjourneys#testme'

  root 'bartjourneys#new'

end
