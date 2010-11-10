module SslRoutes::UrlFor

  def self.included(base)
    raise "#{base}#url_for in undefined" unless base.method_defined?(:url_for)
    base.send :include, InstanceMethods
    base.send :alias_method_chain, :url_for, :ssl_support
  end

  module InstanceMethods
    
    def url_for_with_ssl_support(options)
      case options
        when Hash
          # determine protocol
          current_protocol = request.protocol.split(':').first
          target_protocol  = extract_protocol(options)
          # fix protocol mismatch
          if current_protocol != target_protocol
            options.merge!({ :protocol => target_protocol, :only_path => false })
          end
      end
      url_for_without_ssl_support(options)
    end
    
    private
      
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

ActionController::Base.send :include, SslRoutes::UrlFor
# ActionView::Base.send :include, SslRoutes::UrlFor
