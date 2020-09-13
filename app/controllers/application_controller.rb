class ApplicationController < ActionController::Base
  require 'rspotify'

  def homepage
    playlist = RSpotify::Playlist.find('usernameistakenistaken', '4GFyJzIlynP7mjBNnRe1sA')

    puts(playlist.tracks_added_at)
    @am_popularity = RSpotify::Artist.search('Arctic Monkeys').first.popularity
    render({ :template => "general/homepage.html.erb" })
  end
end
