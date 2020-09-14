class SongsController < ApplicationController
  require 'rspotify'


  def song_data
    #Displays search bar on song data page
    render({ :template => "general/song_data.html.erb" })
  end


  def song_search
    #Processes the song search form submission
    search_string = params.fetch(:song_from_query)
    song = RSpotify::Track.search(search_string).first
    if !song.blank?
      redirect_to("/song_data/#{song.id}")
    else
      redirect_to("/song_data")
    end
  end


  def song_data_with_display
    #Displays a song and search bar on song data page, given song_id
    song_id = params.fetch(:song_id)
    @song = RSpotify::Track.find(song_id)
    @audio_features = RSpotify::AudioFeatures.find(song_id)
    render({ :template => "general/song_data.html.erb" })
  end
end
