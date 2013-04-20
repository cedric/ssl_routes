class PagesController < ApplicationController
  enforce_protocols do |config|
    config.parameter = :ssl
    config.secure_session = false
    config.enable_ssl = true
    #config.http_port = 3000
    #config.https_port = 3001
  end

  def secure
  end
end

