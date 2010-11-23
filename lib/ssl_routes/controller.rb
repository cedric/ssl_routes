module SslRoutes::Controller

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.send :alias_method_chain, :url_for, :ssl_support
  end

  module ClassMethods

    def enforce_protocols(&block)
      cattr_accessor :parameter, :secure_session, :enable_ssl
      self.parameter        = :protocol
      self.secure_session   = false
      self.enable_ssl       = false
      yield self if block_given?
      before_filter :ensure_protocol if self.enable_ssl
    end

  end

  module InstanceMethods

    def url_for_with_ssl_support(options)
      if self.enable_ssl
        case options
          when Hash
            current = request.protocol.split(':').first
            target  = extract_protocol(options, 'http')
            if current != target
              options.merge!({ :protocol => target, :only_path => false })
            end
        end
      end
      url_for_without_ssl_support(options)
    end

    private

      def ensure_protocol
        options = ActionController::Routing::Routes.recognize_path(
          request.path,
          ActionController::Routing::Routes.extract_request_environment(request)
        )
        current = request.protocol.split(':').first
        target  = extract_protocol(options, current)
        if current != target
          flash.keep
          redirect_to "#{target}://#{request.host_with_port + request.request_uri}"
          return false
        end
      end

      def extract_protocol(options, default_protocol)
        protocol = case options[self.parameter]
          when String then options[self.parameter]
          when TrueClass then 'https'
          else default_protocol
        end
        protocol = 'https' if self.secure_session && current_user
        protocol = options[:protocol] if options[:protocol]
        return protocol.split(':').first
      end

  end

end

ActionController::Base.send :include, SslRoutes::Controller
