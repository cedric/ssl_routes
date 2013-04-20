Dummy::Application.routes.draw do
  resources :secured_pages, ssl: true
  resources :non_secured_pages, ssl: false
end
