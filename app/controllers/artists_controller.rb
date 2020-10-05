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
    @all_top_tracks = RSpotify::Track.search(@artist.name, limit: 50).sort_by {|track| 100-track.popularity}.filter {|track| track.artists.first.id == @artist.id}

    #This thing gets all of an artists songs by getting all albums then all songs from those albums.
    #Its cool but makes too many API requests. May be able to improve it later

    #@all_top_tracks = Array.new
    #@artist.albums(limit: 50, album_type: 'album,single').each do |album|
    #  @all_top_tracks.concat(album.tracks)
    #end
    #@all_top_tracks = all_tracks.sort_by {|track| 100-track.popularity}


    render({ :template => "artists/artist_data.html.erb" })
  end

end
