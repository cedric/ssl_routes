module SslRoutes::ActsAs
  
  # TO DO:
  # - enable/disable ssl
  # - fix urls (url_for)
  # - fix urls (paperclip)
  # - prefer http or allow both
  # - secure session (firesheep)
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    attr_accessor :protocol_option, :enable_ssl
    def enforce_route_protocols(&block)
      # default options
      self.protocol_option = :protocol
      self.enable_ssl = true
      # yield block
      yield self if block_given?
      # apply before filter
      before_filter :ensure_proper_protocol if self.enable_ssl
    end
  end
    
  private
    
    def ensure_proper_protocol
      # recognize request route
      route = ActionController::Routing::Routes.recognize_path(
        request.path,
        ActionController::Routing::Routes.extract_request_environment(request)
      )
      # determine proper protocol
      protocol = route.has_key?(:protocol) ? route[:protocol] : 'http'
      # redirect to proper protocol
      if protocol && request.protocol != "#{protocol}://"
        flash.keep
        redirect_to "#{protocol}://#{request.host_with_port + request.request_uri}"
        return false
      end
    end
    
end

ActionController::Base.send :include, SslRoutes::ActsAs
