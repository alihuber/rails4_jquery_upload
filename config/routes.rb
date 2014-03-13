Rails4JqueryUpload::Engine.routes.draw do
  post   "uploads",            to: "uploads#create"
  delete "uploads/:model/:id", to: "uploads#destroy"
  patch  "uploads",            to: "uploads#create"
end
