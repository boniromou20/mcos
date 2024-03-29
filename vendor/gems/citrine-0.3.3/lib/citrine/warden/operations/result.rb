# frozen-string-literal: true
module Citrine
  module Warden
    class Base
      module Operations
        class InvalidAuthorizationToken < Citrine::Operation::Result
          define_attribute(:given_auth_token) { |ctx| ctx[:given_auth_token] }
          define_attribute(:expected_auth_token) { |ctx| ctx[:expected_auth_token] }

          message do |ctx|
            "The request is unauthorized due to invalid authorization token - " +
            "expected authorization: #{expected_auth_token};" +
            "given authorization: #{given_auth_token}"
          end
        end

        class UndefinedAuthorization < Citrine::Operation::Result
          message "The request is unauthorized due to undefined authorization."
        end

        class ExpiredAuthorizationToken < Citrine::Operation::Result
          define_attribute(:expired_at) { |ctx| ctx[:expired_at] }
          message do |ctx|
            "The request is unauthorized due to expired authorization token - " +
            "expired at: #{expired_at}"
          end
        end
      end
    end
  end
end
