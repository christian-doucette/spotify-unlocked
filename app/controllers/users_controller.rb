class UsersController < ApplicationController
  require 'rspotify'

  before_action :spotify_auth #runs the spotify_auth function at the beginning of every user controller function
  skip_before_action(:spotify_auth, { :only => [:spotify_callback] }) #except for spotify_callback


  def spotify_auth
    #if user is not stored in session, get spotify authentication
    #otherwise sets user in @user instance variable
    if !session.key?(:user_hash)
      redirect_to('/auth/spotify')
    else
      user_hash = session[:user_hash]
      @user = RSpotify::User.new(user_hash)
    end
  end


  def spotify_callback
    user = RSpotify::User.new(request.env['omniauth.auth'])
    session[:user_hash] = user.to_hash
    redirect_to("/user_page")
  end


  def user_page
    render({:template => "users/user_page.html.erb"})
  end


  def top_songs_page
    @top_tracks = @user.top_tracks(limit: 50, offset: 0, time_range: 'long_term')
    @top_tracks_and_afs = get_tracks_and_afs(@top_tracks)
    @top_decades = get_top_decades(@top_tracks)
    print(@top_decades)
    render({:template => "users/top_songs.html.erb"})
  end


  def top_artists_page
    @top_artists = @user.top_artists(limit: 50, offset:0,time_range: 'long_term')
    @top_genres = get_top_genres(@top_artists)
    render({:template => "users/top_artists.html.erb"})
  end


  def playlists_page
    @playlists = @user.playlists(limit:20, offset:0)
    render({:template => "users/playlists.html.erb"})
  end


  def create_top_songs_playlist
    top_tracks_playlist = @user.create_playlist!('All Time Top Songs', description: 'My 50 most played songs of all time. Compiled by Spotify Unlocked.')
    top_tracks = @user.top_tracks(limit: 50, offset: 0, time_range: 'long_term')
    top_tracks_playlist.add_tracks!(top_tracks)
    #redirect_to("/user_top_songs")
    redirect_to("/user_top_songs", alert: "Playlist Created Successfully")
  end


  def recommendations_form
    render({:template => "users/recommendations.html.erb"})
  end


  def recommendations_display
    song1 = get_song_id_from_name(params.fetch("song1_from_query"))
    song2 = get_song_id_from_name(params.fetch("song2_from_query"))
    song3 = get_song_id_from_name(params.fetch("song3_from_query"))
    song4 = get_song_id_from_name(params.fetch("song4_from_query"))
    song5 = get_song_id_from_name(params.fetch("song5_from_query"))
    songs = [song1, song2, song3, song4, song5]
    @recs = RSpotify::Recommendations.generate(limit: 20, seed_tracks: songs, market: 'US', min_energy: 0.8).tracks
    render({:template => "users/display_recommendations.html.erb"})
  end


  #----------------------------------------------------------------------------#
  #-------Business logic functions that would usually go in a model------------#
  #----------------------------------------------------------------------------#

  def get_tracks_and_afs(tracks)
    tracks_ids = get_tracks_ids(tracks)
    afs = RSpotify::AudioFeatures.find(tracks_ids[0, 50])

    tracks_and_afs = Array.new
    i = 0
    while i < tracks_ids.length()
      tracks_and_afs.append([tracks[i], afs[i]])
      i += 1
    end

    return tracks_and_afs

  end



  def get_top_genres(artists)
    #Returns array of [key, value] pairs for top ten genres
    genres_hash = Hash.new
    artists.each do |artist|
      artist.genres.each do |artist_genre|
        if genres_hash.key?(artist_genre)
          genres_hash[artist_genre] += 1
        else
          genres_hash[artist_genre] = 1
        end
      end
    end

    top_ten_genres = genres_hash.sort_by {|k,v| -v}.first(10)
    return top_ten_genres
  end




  def get_top_decades(tracks)
    #Returns array of [key, value] pairs for top three decades from list of tracks
    decades_hash = Hash.new
    tracks.each do |track|
      release_date = track.album.release_date
      decade = "#{release_date[0, 3]}0s"

      if decades_hash.key?(decade)
        puts("{Adding one to #{decade}}")
        decades_hash[decade] += 1
      else
        puts("{Adding key #{decade}}")

        decades_hash[decade] = 1
      end
    end

    top_three_decades = decades_hash.sort_by {|k,v| -v}.first(3)
    return top_three_decades
  end



  def get_tracks_ids(tracks_array)
    tracks_ids = %w()
    tracks_array.each do |track|
      tracks_ids.append(track.id.to_s)
    end
    return tracks_ids
  end


  def get_song_id_from_name(name)
    track = RSpotify::Track.search(name)
    return track.first.id.to_s
  end




end
