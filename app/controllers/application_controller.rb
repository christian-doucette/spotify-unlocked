class ApplicationController < ActionController::Base
  require 'rspotify'

  def home
    render({:template => "general/home.html.erb"})
  end

  def song_data
    render({ :template => "general/song_data.html.erb" })
  end

  def song_search
    search_string = params.fetch(:song_from_query)
    song = RSpotify::Track.search(search_string).first

    if !song.blank?
      redirect_to("/song_data/#{song.id}")
    else
      redirect_to("/song_data")
    end
  end


  def song_data_with_display
    song_id = params.fetch(:song_id)
    @song = RSpotify::Track.find(song_id)
    @audio_features = RSpotify::AudioFeatures.find(song_id)
    render({ :template => "general/song_data.html.erb" })
  end
  

  def artist_data
    artist_search = params.fetch("artist_from_query",nil)

    if !artist_search.blank?
      @artist = RSpotify::Artist.search(artist_search).first
    end

    render({:template => "general/artist_data.html.erb"})
  end




end
