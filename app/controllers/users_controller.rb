class UsersController < ApplicationController
  require 'rspotify'
  #isnt working right now, but will never be run from home
  def user_data
    user = RSpotify::Artist.find("jmdoucette-no")
    render({:template => "users/user_data.html.erb"})
  end


  def spotify_callback
    @user = RSpotify::User.new(request.env['omniauth.auth'])
    @top_tracks = @user.top_tracks(limit: 50, offset: 0, time_range: 'long_term')

    #top_songs = spotify_user.top_tracks(limit: 20, offset: 0, time_range: 'short_term').size #=> (Track array)

    #hash = spotify_user.to_hash
    #session[:user_hash] = hash

    #puts(spotify_user.playlists.first.tracks.first.name)
    render({:template => "users/user_page.html.erb"})

  end


end
