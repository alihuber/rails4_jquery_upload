Rails.application.routes.draw do

  mount Rails4JqueryUpload::Engine => "/rails4_jquery_upload"

  root "tasks#index"
  resources :tasks
end
