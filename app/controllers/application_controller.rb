class ApplicationController < ActionController::Base
  require 'rspotify'

  def homepage
    song_search = params.fetch("song_from_query", nil)

    if !song_search.blank?
      @song = RSpotify::Track.search(song_search).first
      if !@song.nil?
        @audio_features = RSpotify::AudioFeatures.find(@song.id)
      end
    end

    render({ :template => "general/homepage.html.erb" })

  end


end
