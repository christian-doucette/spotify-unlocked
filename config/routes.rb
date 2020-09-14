Rails.application.routes.draw do
  #Route for home page
  match("/",{ :controller => "application", :action => "home", :via => "get"})

  match("/song_data", { :controller => "application", :action => "song_data", :via => "get"})
  match("/song_data/:song_id", { :controller => "application", :action => "song_data_with_display", :via => "get"})
  match("/song_search", { :controller => "application", :action => "song_search", :via => "get"})


  match("/artist_data",{:controller => "application",:action => "artist_data", :via => "get"})
  match("/artist_data/:artist_id", { :controller => "application", :action => "artist_data_with_display", :via => "get"})
  match("/artist_search", { :controller => "application", :action => "artist_search", :via => "get"})



  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
