Rails4JqueryUpload::Engine.routes.draw do
  resources :uploads, :only => [:create, :destroy]
  patch "uploads", to: "uploads#create"
end
