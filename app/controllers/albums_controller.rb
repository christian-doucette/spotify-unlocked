class AlbumsController < ApplicationController
  require 'rspotify'

  def album_data
    #Displays search bar on album data page
    render ({:template => "albums/album_data.html.erb"})
  end

  def album_search
  #processes album search
    search_string = params.fetch(:album_from_query)
    album = ::RSpotify::Album.search(search_string).first
    if !album.blank?
      redirect_to("/album_data/#{album.id}")
    else
      redirect_to("/album_data")
    end
  end

  def album_data_with_display
  #displays the data for a searched albums
    album_id = params.fetch(:album_id)
    @album = RSpotify::Album.find(album_id)
    puts(@album.images.first["url"])
    puts("image url")
    render ({:template => "albums/album_data.html.erb"})
  end


end
