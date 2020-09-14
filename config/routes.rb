Rails.application.routes.draw do
  #Route for home page
  match("/",{ :controller => "application", :action => "home", :via => "get"})

  match("/song_data", { :controller => "application", :action => "song_data", :via => "get"})

  match("/artist_data",{:controller => "application",:action => "artist_data", :via => "get"})

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
