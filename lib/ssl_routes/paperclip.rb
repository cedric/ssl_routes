# Pollute Thread.current so we can fix S3 urls.
ActionController::Base.class_eval do
  before_filter :set_protocol
  private
    def set_protocol
      Thread.current[:protocol] = request && request.ssl? ? 'https' : 'http'
    end
end

# Fix protocol in S3 urls.
module Paperclip::Storage::S3
  def s3_protocol
    Thread.current[:protocol] ||= @s3_protocol
  end
end
