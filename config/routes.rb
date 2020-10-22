Rails.application.routes.draw do

  #Routes for application controller
  match("/",{ :controller => "application", :action => "home", :via => "get"})




  #------------------------------
  #Routes for songs controller
  match("/song_data", { :controller => "songs", :action => "song_data", :via => "get"})
  match("/song_data/:song_id", { :controller => "songs", :action => "song_data_with_display", :via => "get"})
  match("/song_search", { :controller => "songs", :action => "song_search", :via => "get"})
  match("song_data/chords/:song_id", { :controller => "songs", :action => "chords_page", :via => "get"})
  match("song_data/lyrics/:song_id", { :controller => "songs", :action => "lyrics_page", :via => "get"})




  #------------------------------
  #Routes for artists controller
  match("/artist_data",{:controller => "artists",:action => "artist_data", :via => "get"})
  match("/artist_data/:artist_id", { :controller => "artists", :action => "artist_data_with_display", :via => "get"})
  match("/artist_search", { :controller => "artists", :action => "artist_search", :via => "get"})
  match("/artist_data/details/:artist_id", { :controller => "artists", :action => "artist_details", :via => "get"})



  #------------------------------
  #Routes for albums  controller
  match("/album_data",{:controller => "albums",:action => "album_data",:via =>"get"})
  match("/album_data/:album_id", { :controller => "albums", :action => "album_data_with_display", :via => "get"})
  match("/album_search", { :controller => "albums", :action => "album_search", :via => "get"})


  #------------------------------
  #Routes for users controller
  match("/user_data",{:controller => "users",:action => "user_data",:via =>"get"})
  match("/user_page",{:controller => "users",:action => "user_page",:via =>"get"})
  match("/user_top_songs",{:controller => "users",:action => "top_songs_page",:via =>"get"})
  match("/user_top_artists",{:controller => "users",:action => "top_artists_page",:via =>"get"})
  match("/user_playlists",{:controller => "users",:action => "playlists_page",:via =>"get"})




  match("/auth/spotify/callback", { :controller => "users", :action => "spotify_callback", :via => "get"})




  #------------------------------
end
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
