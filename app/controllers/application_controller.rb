class ApplicationController < ActionController::Base
  require 'rspotify'

  def home
    render({:template => "general/home.html.erb"})
  end

  def song_data
    song_search = params.fetch("song_from_query", nil)

    if !song_search.blank?
      @song = RSpotify::Track.search(song_search).first
      if !@song.nil?
        @audio_features = RSpotify::AudioFeatures.find(@song.id)
      end
    end

    render({ :template => "general/song_data.html.erb" })

  end

  def artist_data
    render({:template => "general/artist_data.html.erb"})
  end



end
