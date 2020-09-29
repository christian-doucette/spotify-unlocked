class ApplicationController < ActionController::Base
  require 'rspotify'

  def home
    render({:template => "general/home.html.erb"})
  end



end
