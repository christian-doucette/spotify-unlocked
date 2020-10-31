class ApplicationController < ActionController::Base
  require 'rspotify'
  add_flash_types :info, :error, :warning

  def home
    render({:template => "general/home.html.erb"})
  end



end
