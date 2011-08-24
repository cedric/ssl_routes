module SslRoutes::Controller

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.send :alias_method_chain, :url_for, :ssl_support
  end

  module ClassMethods

    def enforce_protocols(&block)
      cattr_accessor :parameter, :secure_session, :enable_ssl
      self.parameter      = :protocol
      self.secure_session = false
      self.enable_ssl     = false
      yield self if block_given?
      before_filter :ensure_protocol if self.enable_ssl
    end

  end

  module InstanceMethods

    def url_for_with_ssl_support(options)
      if self.enable_ssl
        case options
          when Hash
            current_protocol = request.protocol.split(':').first
            target_protocol  = determine_target_protocol(current_protocol, options)
            if current_protocol != target_protocol
              options.merge!({ :protocol => target_protocol, :only_path => false })
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
        current_protocol = request.protocol.split(':').first
        target_protocol  = determine_target_protocol(current_protocol, options)
        if current_protocol != target_protocol && !request.xhr? && request.get?
          flash.keep
          redirect_to "#{target_protocol}://#{request.host_with_port + request.request_uri}"
          return false
        end
      end

      def determine_target_protocol(current_protocol, options)
        protocol = case options[self.parameter]
          when String then options[self.parameter]
          when TrueClass then 'https'
          else 'http'
        end
        protocol = current_protocol if [:all, :both].include? options[self.parameter]
        protocol = 'https' if self.secure_session && current_user
        protocol = options[:protocol] if options[:protocol]
        return protocol.split(':').first
      end

  end

end

ActionController::Base.send :include, SslRoutes::Controller
ActionController::Routing::Routes.send :remove_recognize_optimized!
