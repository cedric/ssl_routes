module SslRoutes
  
  # Features:
  # - [DONE] enable/disable ssl
  # - [DONE] enforce protocol in controller
  # - [DONE] route parameter option
  # - [DONE] fix urls (url_for)
  # - [DONE] fix urls (paperclip)
  # - [DONE] secure session (firesheep)
  # - presentation plugin
  
  require 'ruby-debug'
  
  require 'ssl_routes/acts_as'
  require 'ssl_routes/url_for'
  require 'ssl_routes/paperclip' if defined?( Paperclip )
  
end
