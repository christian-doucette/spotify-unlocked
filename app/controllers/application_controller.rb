class ApplicationController < ActionController::Base
  require 'rspotify'

  def homepage
    #playlist = RSpotify::Playlist.find('usernameistakenistaken', '4GFyJzIlynP7mjBNnRe1sA')
    #puts(playlist.name)
    song_id = RSpotify::Track.search('Howlin').first.id
    #song_id = '1SDiiE3v2z89VxC3aVRKHQ'
    @song = RSpotify::Track.find(song_id)
    @audio_features = RSpotify::AudioFeatures.find(song_id)
    render({ :template => "general/homepage.html.erb" })
  end
end
