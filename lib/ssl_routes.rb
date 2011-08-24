module SslRoutes
  
  require 'ssl_routes/rails3' if ::Rails::VERSION::MAJOR == 3
  require 'ssl_routes/rails2' if ::Rails::VERSION::MAJOR == 2
  require 'ssl_routes/paperclip' if defined?( ::Paperclip )
  
end
