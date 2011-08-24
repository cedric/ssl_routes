module SslRoutes

  module ActionController

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
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

      def determine_protocols(options)
        current = self.request.ssl? ? 'https' : 'http'
        target = case options[self.parameter]
          when String then options[self.parameter]
          when TrueClass then 'https'
          else 'http'
        end
        target = current if [:all, :both].include? options[self.parameter]
        target = 'https' if self.secure_session && current_user
        target = options[:protocol] if options[:protocol]
        [ current, target.split(':').first ]
      end

      private

        def ensure_protocol
          routes = Rails.application.routes
          options = routes.recognize_path request.path, request.env
          current, target = determine_protocols(options)
          if current != target && !request.xhr? && request.get?
            flash.keep
            redirect_to "#{target}://#{request.host_with_port + request.fullpath}"
            return false
          end
        end

    end

  end

  module ActionDispatch

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :alias_method_chain, :url_for, :ssl_support
    end

    module InstanceMethods

      def url_for_with_ssl_support(options)
        ac = self.respond_to?(:controller) ? self.controller : self
        if ac.enable_ssl
          case options
            when Hash
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

end

ActionController::Base.send :include, SslRoutes::ActionController
ActionDispatch::Routing::UrlFor.send :include, SslRoutes::ActionDispatch
