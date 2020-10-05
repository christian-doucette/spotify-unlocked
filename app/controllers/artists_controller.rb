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
    puts("artist id: ")
    puts(artist_id)
    puts("")
    @artist = RSpotify::Artist.find(artist_id)
    @extended_top_tracks = RSpotify::Track.search(@artist.name, limit: 50).sort_by {|track| 100-track.popularity}.filter {|track|
      puts(track.artists.first.id)
      puts(track.artists.first.id == @artist.id)
      track.artists.first.id == @artist.id}

    render({ :template => "artists/artist_data.html.erb" })
  end

end
