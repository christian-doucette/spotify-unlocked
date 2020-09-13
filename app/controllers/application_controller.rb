class ApplicationController < ActionController::Base
  require 'rspotify'

  def homepage
    render({ :template => "general/homepage.html.erb" })
  end

  def homepage_with_query
    song_search = params.fetch(:song_from_query)
    @song = RSpotify::Track.search(song_search).first
    if @song.nil?
      redirect_to("/", { :alert => "No song returned" })
    else
    @audio_features = RSpotify::AudioFeatures.find(@song.id)
    render({ :template => "general/homepage.html.erb" })
    end
  end
end
