Rails.application.routes.draw do

  #Routes for application controller
  match("/",{ :controller => "application", :action => "home", :via => "get"})


  #------------------------------
  #Routes for songs controller
  match("/song_data", { :controller => "songs", :action => "song_data", :via => "get"})
  match("/song_data/:song_id", { :controller => "songs", :action => "song_data_with_display", :via => "get"})
  match("/song_search", { :controller => "songs", :action => "song_search", :via => "get"})


  #------------------------------
  #Routes for artists controller
  match("/artist_data",{:controller => "artists",:action => "artist_data", :via => "get"})
  match("/artist_data/:artist_id", { :controller => "artists", :action => "artist_data_with_display", :via => "get"})
  match("/artist_search", { :controller => "artists", :action => "artist_search", :via => "get"})


  #------------------------------
  #Routes for albums AlbumsController
  match("/album_data",{:controller => "albums",:action => "album_data",:via =>"get"})
  match("/album_data/:album_id", { :controller => "albums", :action => "album_data_with_display", :via => "get"})
  match("/album_search", { :controller => "albums", :action => "album_search", :via => "get"})



  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
