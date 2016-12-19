 # -*- encoding : utf-8 -*-
require "ant/version"
require "openssl"
require "net/http"
require "net/https"
require "uri"
require "json"
require "addressable/uri"
require 'rest-client'

module Ant

  class API
    attr_accessor :apikey, :username, :nonce_v, :secret

    def initialize(username, apikey, secret)
      self.username = username
      self.apikey = apikey
      self.secret = secret
    end

    def api_call(method, params = {}, priv = false, is_json = true)
      url = "https://www.antpool.com/api/#{ method }"
      if priv
        self.nonce_v
        params.merge!(:key => self.apikey, :signature => self.signature.to_s.upcase, :nonce => self.nonce_v)
      end
      response = self.post(url, params)

      # unfortunately, the API does not always respond with JSON, so we must only
      # parse as JSON if is_json is true.
      if is_json
        JSON.parse(response)
      else
        response
      end
    end

    # Endpoints
    def account
      self.api_call('account.htm', {}, true)
    end

    def hashrate
      self.api_call('hashrate.htm', {}, true)
    end

    def pool_stats
      self.api_call('poolStats.htm')
    end

    def workers
      self.api_call('workers.htm')
    end

    private

    def nonce
      self.nonce_v = (Time.now.to_f * 1000000).to_i.to_s
    end

    def signature
      str = self.username + self.apikey + self.nonce_v
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), self.secret ,str)
    end

    def post(url, params)
      # 由于服务器采用不安全openssl
      # uri = URI.parse(url)
      # https = Net::HTTP.new(uri.host, uri.port)
      # https.use_ssl = false
      # params = Addressable::URI.new
      # params.query_values = param
      # https.post(uri.path, params.query).body
      RestClient.post(url, params)
    end
  end
end
