require 'spec_helper'

describe "SslRoutes::ActionController::ClassMethods.enforce_protocols, " do
  context "given the http_port and https_port options of ssl_routes are specified, " do
    before do
      ApplicationController.enforce_protocols do |config|
        config.parameter = :ssl
        config.secure_session = false
        config.enable_ssl = true
        config.http_port = 3000
        config.https_port = 3001
      end
    end

    it "should redirect to the https version of a secured page if the request env is http" do
      get 'http://www.example.com:3000/secured_pages'
      expect(request.env['HTTPS']).to eq('off')
      expect(response).to redirect_to('https://www.example.com:3001/secured_pages')
    end

    it "should just render a secured page if the request env is https" do
      get 'https://www.example.com:3001/secured_pages'
      expect(request.env['HTTPS']).to eq('on')
      expect(response).to be_success
    end

    it "should redirect to the http version of a non-secured page if the request env is https" do
      get 'https://www.example.com:3001/non_secured_pages'
      expect(request.env['HTTPS']).to eq('on')
      expect(response).to redirect_to('http://www.example.com:3000/non_secured_pages')
    end

    it "should just render a secured page if the request env is https" do
      get 'http://www.example.com:3000/non_secured_pages'
      expect(request.env['HTTPS']).to eq('off')
      expect(response).to be_success
    end

    it "should append the https port to a secured page link if the current page is not secured" do
      get 'http://www.example.com:3000/non_secured_pages'
      expect(response.body).to include("<a href=\"https://www.example.com:3001/secured_pages\">")
    end

    it "should render a link to a secured page without https protocol and port if the current page is secured" do
      get 'https://www.example.com:3001/secured_pages'
      expect(response.body).to include("<a href=\"/secured_pages\">")
    end

    it "should append the http port to a non-secured page link if the current page is secured" do
      get 'https://www.example.com:3001/secured_pages'
      expect(response.body).to include("<a href=\"http://www.example.com:3000/non_secured_pages\">")
    end

    it "should render a link to a non-secured page without http protocol and port if the current page is non-secured" do
      get 'http://www.example.com:3000/non_secured_pages'
      expect(response.body).to include("<a href=\"/non_secured_pages\">")
    end
  end

  context "given the http_port and https_port options of ssl_routes are not specified, " do
    before do
      ApplicationController.enforce_protocols do |config|
        config.parameter = :ssl
        config.secure_session = false
        config.enable_ssl = true
        config.http_port = nil
        config.https_port = nil
      end
    end

    it "should redirect to the https version of a secured page if the request env is http" do
      get 'http://www.example.com/secured_pages'
      expect(request.env['HTTPS']).to eq('off')
      expect(response).to redirect_to('https://www.example.com/secured_pages')
    end

    it "should just render a secured page if the request env is https" do
      get 'https://www.example.com/secured_pages'
      expect(request.env['HTTPS']).to eq('on')
      expect(response).to be_success
    end

    it "should redirect to the http version of a non-secured page if the request env is https" do
      get 'https://www.example.com/non_secured_pages'
      expect(request.env['HTTPS']).to eq('on')
      expect(response).to redirect_to('http://www.example.com/non_secured_pages')
    end

    it "should just render a secured page if the request env is https" do
      get 'http://www.example.com/non_secured_pages'
      expect(request.env['HTTPS']).to eq('off')
      expect(response).to be_success
    end

    it "should append the https protocol to a secured page link if the current page is not secured" do
      get 'http://www.example.com/non_secured_pages'
      expect(response.body).to include("<a href=\"https://www.example.com/secured_pages\">")
    end

    it "should render a link to a secured page without https protocol if the current page is secured" do
      get 'https://www.example.com/secured_pages'
      expect(response.body).to include("<a href=\"/secured_pages\">")
    end

    it "should append the http protocol to a non-secured page link if the current page is secured" do
      get 'https://www.example.com/secured_pages'
      expect(response.body).to include("<a href=\"http://www.example.com/non_secured_pages\">")
    end

    it "should render a link to a non-secured page without http protocol if the current page is non-secured" do
      get 'http://www.example.com/non_secured_pages'
      expect(response.body).to include("<a href=\"/non_secured_pages\">")
    end
  end
end

