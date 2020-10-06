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

    #@all_top_tracks = RSpotify::Track.search(@artist.name, limit: 50).sort_by {|track| 100-track.popularity}.filter {|track| track.artists.first.id == @artist.id}
    @all_tracks = get_all_tracks(@artist)
    @all_tracks.sort_by! {|track| 100-track.popularity}


    render({ :template => "artists/artist_data.html.erb" })
  end




  #----------------------------------------------------------------------------#
  #-------Business logic functions that would usually go in a model------------#
  #----------------------------------------------------------------------------#


  def get_all_tracks(artist)
    #This functions gets all the US artists
    all_tracks_ids = %w() #empty string array
    artist.albums(limit: 50, album_type: 'album,single', market: 'US').each do |album|
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

end
