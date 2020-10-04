class UsersController < ApplicationController
  require 'rspotify'


  def spotify_callback
    @user = RSpotify::User.new(request.env['omniauth.auth'])
    @top_tracks = @user.top_tracks(limit: 20, offset: 0, time_range: 'long_term')
    @top_artists = @user.top_artists(limit:20, offset:0,time_range: 'long_term')
    @playlists = @user.playlists(limit:20, offset:0)

    #top_songs = spotify_user.top_tracks(limit: 20, offset: 0, time_range: 'short_term').size #=> (Track array)

    #hash = spotify_user.to_hash
    #session[:user_hash] = hash

    #puts(spotify_user.playlists.first.tracks.first.name)
    render({:template => "users/user_page.html.erb"})

  end


end
