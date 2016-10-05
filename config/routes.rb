Rails.application.routes.draw do
  resources :reminders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # messenger
  get "messenger/incoming", to: "messenger#incoming"
  post "messenger/incoming", to: "messenger#incoming"
end
