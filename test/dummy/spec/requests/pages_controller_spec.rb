require 'spec_helper'

describe "Given the http_port and https_port options of ssl_routes are specified, " do
  describe "SslRoutes::ActionController::ClassMethods.enforce_protocols" do
    it "should redirect to the https version of a secured page if the request env is http" do
      get 'http://www.example.com/pages/secure'
      expect(request.env['HTTPS']).to eq('off')
      expect(response).to redirect_to('https://www.example.com/pages/secure')
    end

    it "should just render a secured page if the request env is https" do
      get 'https://www.example.com/pages/secure'
      expect(request.env['HTTPS']).to eq('on')
      expect(response).to be_success
    end
  end
end

