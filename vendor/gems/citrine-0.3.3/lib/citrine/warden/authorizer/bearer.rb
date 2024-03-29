# frozen-string-literal: true
require "openssl"
require "time"

module Citrine
  module Warden
    module Authorizer
      class Bearer < Base
        def self.parse_token(request)
          bearer, token = request.headers["Authorization"].split(' ')
          access_key_id, signature = token.split(':')
          { bearer: bearer, access_key_id: access_key_id, signature: signature}
        end

        def default_bearer; "CTRN-HS256"; end
        def default_header_field_prefix; "X-Ctrn"; end
        def default_signature_algorithm; "SHA256"; end
        def default_datetime_format; "%Y-%m-%dT%H:%M:%S.%L"; end
        def default_content_checksum; "MD5"; end
        def default_empty_query_exclusion; false; end
  
        def content_checksum_enabled?
          !!options[:content_checksum]
        end
  
        def empty_query_excluded?
          !!options[:exclude_empty_query]
        end
  
        def header_field_datetime
          header_field("Date")
        end
  
        def header_field_content_checksum
          header_field("Content-#{options[:content_checksum].capitalize}")
        end
  
        def headers_to_sign
          @headers_to_sign ||= [/^#{options[:header_field_prefix]}.+/i]
        end
  
        def sign_request(request)
          signature_headers = extract_signature_headers(request)
          signature = sign(canonical_request(request, signature_headers))
          signature_headers['Authorization'] = authorization_header(signature)
          request.headers.merge!(signature_headers)
          request
        end
        
        protected
  
        def set_default_options
          @default_options ||= super.merge!(
            bearer: default_bearer,
            header_field_prefix: default_header_field_prefix, 
            signature_algorithm: default_signature_algorithm,
            datetime_format: default_datetime_format,
            content_checksum: default_content_checksum,
            exclude_empty_query: default_empty_query_exclusion
          )
        end
  
        def post_init
          unless options[:header_field_prefix].to_s.empty? or
            options[:header_field_prefix][-1] == '-'
            options[:header_field_prefix] += "-"
          end
        end
  
        def header_field(str)
          "#{options[:header_field_prefix]}#{str}"
        end
  
        def datetime
          Time.now.utc.strftime(options[:datetime_format])
        end
  
        def checksum(string)
          OpenSSL::Digest.const_get(options[:content_checksum])
                          .base64digest(string.encode("UTF-8")).strip
        end
  
        def extract_signature_headers(request)
          request.headers.each_with_object(sig_headers = {}) do |(k, v), h|
            h[k] = v if headers_to_sign.any? { |key| key === k }
          end
          sig_headers[header_field_datetime] ||= datetime
          if content_checksum_enabled?
            sig_headers[header_field_content_checksum] = checksum(request.body.to_s || "")
          end
          sig_headers
        end
  
        def canonical_request(request, signature_headers)
          [ request.method.to_s.upcase, 
            canonical_headers(signature_headers), 
            request.path
          ].tap do |creq| 
            unless empty_query_excluded? and request.query.empty?
              creq << request.query_string
            end
          end
        end
  
        def string_to_sign(creq)
          creq.join(canonical_delimiter)
        end 
  
        def canonical_headers(headers)
          headers.collect do |k, v| 
            [k.to_s.downcase, v]
          end.sort_by(&:first).map do |k, v| 
            "#{k}:#{v.to_s.strip}"
          end
        end
  
        def canonical_delimiter; "\n"; end
  
        def sign(creq)
          Base64.encode64(
            OpenSSL::HMAC.digest(options[:signature_algorithm],
                                 options[:secret_access_key],
                                 string_to_sign(creq).encode("UTF-8"))
          ).gsub("\n",'')
        end
  
        def authorization_header(signature)
          "#{options[:bearer]} #{options[:access_key_id]}:#{signature}"
        end

        def get_given_auth_token(request)
          request.headers["Authorization"]
        end

        def get_expected_auth_token(request)
          sign_request(request).headers["Authorization"]
        end
      end
    end
  end
end