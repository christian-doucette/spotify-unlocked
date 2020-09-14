Rails.application.routes.draw do
  #Route for home page
  match("/", { :controller => "application", :action => "homepage", :via => "get"})

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
