module SslRoutes::ActsAs
  
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods

    def enforce_protocols(&block)
      cattr_accessor :parameter, :secure_session, :strict, :ssl
      self.parameter      = :protocol
      self.secure_session = false
      self.strict         = false
      self.ssl            = true
      yield self if block_given?
      before_filter :ensure_protocol if self.ssl
    end

  end
  
  module InstanceMethods

    private

      def ensure_protocol
        # recognize route
        options = ActionController::Routing::Routes.recognize_path(
          request.path,
          ActionController::Routing::Routes.extract_request_environment(request)
        )
        # determine protocol
        current_protocol = request.protocol.split(':').first
        target_protocol  = extract_protocol(options, self.strict ? 'http' : current_protocol)
        # fix protocol mismatch
        if current_protocol != target_protocol
          flash.keep
          redirect_to "#{target_protocol}://#{request.host_with_port + request.request_uri}"
          return false
        end
      end

      def extract_protocol(options, default_protocol='http')
        # preferred protocol
        protocol = case options[self.parameter]
          when String then options[self.parameter]
          when true then 'https'
          when false then 'http'
          else default_protocol
        end
        # secure session
        protocol = 'https' if self.secure_session && current_user
        # return
        protocol
      end

  end
end

ActionController::Base.send :include, SslRoutes::ActsAs
