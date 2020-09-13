class ApplicationController < ActionController::Base
  require 'rspotify'

  def homepage
    #playlist = RSpotify::Playlist.find('usernameistakenistaken', '4GFyJzIlynP7mjBNnRe1sA')
    #puts(playlist.name)
    #@song = RSpotify::Track.search('Tighten Up').first
    @song = RSpotify::Track.find('1SDiiE3v2z89VxC3aVRKHQ')
    @audio_features = RSpotify::AudioFeatures.find('1SDiiE3v2z89VxC3aVRKHQ')
    render({ :template => "general/homepage.html.erb" })
  end
end
