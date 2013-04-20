class ApplicationController < ActionController::Base
  protect_from_forgery

  enforce_protocols do |config|
    config.parameter = :ssl
    config.secure_session = false
    config.enable_ssl = true
    config.http_port = 3000
    config.https_port = 3001
  end
end
