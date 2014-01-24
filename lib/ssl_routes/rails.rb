module SslRoutes

  module ActionController

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def enforce_protocols(&block)
        cattr_accessor :parameter, :secure_session, :enable_ssl
        self.parameter      = :protocol
        self.secure_session = true
        self.enable_ssl     = false
        yield self if block_given?
        before_filter :ensure_protocol if self.enable_ssl
      end

    end

    def determine_protocols(options)
      current = self.request.ssl? ? 'https' : 'http'
      target  = case options[self.parameter]
        when String then options[self.parameter]
        when TrueClass then 'https'
        when FalseClass then 'http'
        else current
      end
      target = 'https' if self.secure_session && current_user
      target = options[:protocol] if options[:protocol]
      [ current, target.split(':').first ]
    end

    private

      def ensure_protocol
        router = Rails.application.routes.router
        options = recognize_request(router, self.request)
        current, target = determine_protocols(options)
        if (current != target && !request.xhr? && request.get?)
          flash.keep
          response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
          response.headers['Pragma'] = 'no-cache'
          redirect_to "#{target}://#{request.host_with_port + request.fullpath}"
          return false
        end
      end

      Constraints = ::ActionDispatch::Routing::Mapper::Constraints
      Dispatcher = ::ActionDispatch::Routing::RouteSet::Dispatcher

      def recognize_request(router, req)
        router.recognize(req) do |route, matches, params|
          params.each do |key, value|
            if value.is_a?(String)
              value = value.dup.force_encoding(Encoding::BINARY) if value.encoding_aware?
              params[key] = URI.parser.unescape(value)
            end
          end

          dispatcher = route.app
          while dispatcher.is_a?(Constraints) && dispatcher.matches?(env) do
            dispatcher = dispatcher.app
          end

          if dispatcher.is_a?(Dispatcher) && dispatcher.controller(params, false)
            dispatcher.prepare_params!(params)
            return params
          end
        end

        raise ActionController::RoutingError, "No route matches #{path.inspect}"
      end
  end

  module ActionDispatch

    def self.included(base)
      base.send :alias_method_chain, :url_for, :ssl_support
    end

    def url_for_with_ssl_support(options)
      ac = self.respond_to?(:controller) ? self.controller : self
      if ac.respond_to?(:enable_ssl) && ac.enable_ssl
        if options.is_a?(Hash)
          current, target = ac.determine_protocols(options)
          if current != target
            options.merge!({ :protocol => target, :only_path => false })
          end
        end
      end
      url_for_without_ssl_support(options)
    end

  end

end

ActionController::Base.send :include, SslRoutes::ActionController
ActionDispatch::Routing::UrlFor.send :include, SslRoutes::ActionDispatch
