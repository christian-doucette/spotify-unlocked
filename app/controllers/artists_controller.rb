class ArtistsController < ApplicationController
  require 'rspotify'


  def artist_data
    #Displays search bar on artist data page
    render({:template => "general/artist_data.html.erb"})
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
    render({ :template => "general/artist_data.html.erb" })
  end

end
