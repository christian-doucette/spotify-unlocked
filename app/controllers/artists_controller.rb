class ArtistsController < ApplicationController
  require 'rspotify'


  def artist_data
    #Displays search bar on artist data page
    render({:template => "artists/artist_data.html.erb"})
  end


  def artist_search
    #Processes the artist search form submission
    search_string = params.fetch(:artist_from_query)
    artist = RSpotify::Artist.search(search_string).first
    if !artist.blank?
      redirect_to("/artist_data/#{artist.id}")
    else
      redirect_to("/artist_data")
    end
  end


  def artist_data_with_display
    #Displays an artist and search bar on artist data page, given artist_id
    artist_id = params.fetch(:artist_id)
    @artist = RSpotify::Artist.find(artist_id)
    render({ :template => "artists/artist_data.html.erb" })
  end


  def artist_details
    #Displays an artist and search bar on artist data page, given artist_id
    artist_id = params.fetch(:artist_id)
    @artist = RSpotify::Artist.find(artist_id)
    @all_albums = @artist.albums(limit: 50, album_type: 'album', market: 'US')
    @all_tracks = get_all_tracks(@artist)
    @all_tracks_and_afs = get_all_tracks_and_afs(@all_tracks)

    render({ :template => "artists/artist_details.html.erb" })
  end



  #----------------------------------------------------------------------------#
  #-------Business logic functions that would usually go in a model------------#
  #----------------------------------------------------------------------------#

  def get_all_tracks(artist)
    #Returns a list of all the tracks of an artist
    all_tracks_ids = %w() #empty string array
    artist.albums(limit: 50, album_type: 'album', market: 'US').each do |album|
      album.tracks.each do |track|
        all_tracks_ids.append(track.id.to_s)
      end
    end

    all_tracks = Array.new
    i = 0
    while i < all_tracks_ids.length()
      next_fifty_tracks = RSpotify::Track.find(all_tracks_ids[i, 50])
      all_tracks.concat(next_fifty_tracks)
      i += 50
    end

    return all_tracks
  end



  def get_all_tracks_and_afs(tracks)
    #Returns an array of pairs [Track, AudioFeature]
    tracks_ids = %w() #empty string array
    tracks.each do |track|
      tracks_ids.append(track.id.to_s)
    end

    all_audio_features = Array.new
    i = 0
    while i < tracks_ids.length()
      next_fifty_audio_features = RSpotify::AudioFeatures.find(tracks_ids[i, 50])
      all_audio_features.concat(next_fifty_audio_features)
      i += 50
    end

    combined = Array.new
    i = 0
    while i < tracks_ids.length()
      combined.append([tracks[i], all_audio_features[i]])
      i += 1
    end

    return combined
  end



end
