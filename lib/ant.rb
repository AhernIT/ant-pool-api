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
    attr_accessor :api_key, :username, :nonce_v, :api_secret

    def initialize(username, api_key, api_secret)
      self.username = username
      self.api_key = api_key
      self.api_secret = api_secret
    end

    def api_call(method, param = {}, priv = false, is_json = true)
      url = "https://www.antpool.com/api/#{ method }"
      if priv
        self.nonce
        param.merge!(:key => self.api_key, :signature => self.signature.to_s.upcase, :nonce => self.nonce_v)
      end
      answer = self.post(url, param)

      # unfortunately, the API does not always respond with JSON, so we must only
      # parse as JSON if is_json is true.
      if is_json
        JSON.parse(answer)
      else
        answer
      end
    end

    def account
      self.api_call('account.htm', {}, true)
    end

    def hashrate
      self.api_call('hashrate.htm', {}, true)
    end

    def pool_stats
      self.api_call('poolStats.htm', {}, true)
    end

    def workers
      self.api_call('workers.htm', {}, true)
    end

    def nonce
      self.nonce_v = (Time.now.to_f * 1000000).to_i.to_s
    end

    def signature
      str = self.username + self.api_key + self.nonce_v
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha256'), self.api_secret ,str)
    end

    def post(url, param)
      # 由于服务器采用不安全openssl
      # uri = URI.parse(url)
      # https = Net::HTTP.new(uri.host, uri.port)
      # https.use_ssl = false
      # params = Addressable::URI.new
      # params.query_values = param
      # https.post(uri.path, params.query).body
      RestClient.post(url, param)
    end
  end
end
