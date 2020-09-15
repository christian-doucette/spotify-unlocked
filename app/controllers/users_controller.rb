class UsersController < ApplicationController
  require 'rspotify'
  #isnt working right now, but will never be run from home
  def user_data
    user = RSpotify::Artist.find("jmdoucette-no")
    render({:template => "users/user_data.html.erb"})
  end

end
