# frozen_string_literal: true

require("json")
require_relative("./authenticator.rb")
require_relative("../token_managers/cp4d_token_manager.rb")
require_relative("../utils.rb")

module IBMCloudSdkCore
  # Basic Authenticator
  class CloudPakForDataAuthenticator < Authenticator
    @authentication_type = "cp4d"

    attr_accessor :authentication_type
    def initialize(vars)
      defaults = {
        username: nil,
        password: nil,
        url: nil,
        disable_ssl_verification: false
      }
      vars = defaults.merge(vars)

      @username = vars[:username]
      @password = vars[:password]
      @url = vars[:url]
      @disable_ssl_verification = vars[:disable_ssl_verification]

      validate
      @token_manager = CP4DTokenManager.new(
        username: @username,
        password: @password,
        url: @url,
        disable_ssl_verification: @disable_ssl_verification
      )
    end

    # Adds the Authorization header, if possible
    def authenticate(connector)
      connector.default_options.headers.add("Authorization", "Bearer #{@token_manager.access_token}")
    end

    # Checks if all the inputs needed are present
    def validate
      raise ArgumentError.new("The username or password shouldn\'t be None.") if @username.nil? || @password.nil?
      raise ArgumentError.new('The username shouldn\'t start or end with curly brackets or quotes. Be sure to remove any {} and \" characters surrounding your username') if check_bad_first_or_last_char(@username)
      raise ArgumentError.new('The password shouldn\'t start or end with curly brackets or quotes. Be sure to remove any {} and \" characters surrounding your username') if check_bad_first_or_last_char(@password)
    end
  end
end
