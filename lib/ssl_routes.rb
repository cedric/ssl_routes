module SslRoutes
  
  # Features:
  # - [DONE] enable/disable ssl
  # - [DONE] enforce protocol in controller
  # - [DONE] route parameter option
  # - [DONE] secure session (firesheep)
  # - [DONE] fix urls (paperclip)
  # - [DONE] fix urls (url_for - controller and view)
  # - presentation plugin
  #
  # Other:
  # - cross protocol form submits
  # - question: canonical urls?
  # - question: fractured pagerank?
  
  require 'ruby-debug'
  
  require 'ssl_routes/controller'
  require 'ssl_routes/paperclip' if defined?( Paperclip )
  
end
