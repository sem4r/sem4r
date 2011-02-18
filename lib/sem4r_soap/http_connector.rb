# -*- coding: utf-8 -*-
# -------------------------------------------------------------------------
# Copyright (c) 2009-2010 Sem4r sem4ruby@gmail.com
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# -------------------------------------------------------------------------

module Sem4rSoap

  module HttpConnector

    def self.get(logger = nil, type = :http_client)
      case type
        when :http_client
          ConnectorHttpClient.new(logger)
        when :net_http
          ConnectorNetHttp.new(logger)
        else
          raise "unknow connector type"
      end
    end

    #
    # use Net::HTTP standard library http client
    #
    class ConnectorNetHttp
      include SoapDumper

      def initialize(logger = nil)
        @logger = logger
      end

      def logger=(log)
        @logger = log
      end

      #
      # Send a soap request
      # 
      # @raise [URI::InvalidURIError] when service_url is incorrect
      #
      def send(service_url, soap_action, soap_request_xml)
        uri     = URI.parse(service_url) # might raise URI::InvalidURIError

        headers = {
            "Content-Type"   => "text/xml; charset=utf-8",
            "Content-Length" => soap_request_xml.length.to_s,
            "SOAPAction"     => soap_action}

        @logger.info("Post to #{uri.path} (#{soap_action})") if @logger
        dump_soap_request(service_url, soap_request_xml)
        response = post(uri, soap_request_xml, headers)
        unless response
          raise Sem4rError, "Connection Error"
        end
        response_xml = response.body
        dump_soap_response(service_url, response_xml)
        response_xml
      end

      #
      # Downloads content at url in path_name
      #
      def download(url, path_name)
        uri     = URI.parse(url)
        http    = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        request.initialize_http_header({"User-Agent" => "My Ruby Script"})
        response = http.request(request)
        File.open(path_name, "w") { |f| f.write(response.body) }
      end

      def post(uri, str, headers)
        unless uri.respond_to? :path
          uri     = URI.parse(uri) # might raise URI::InvalidURIError
        end
        retries = 0; response = nil
        while retries <= MAX_RETRIES and response.nil?
          retries += 1
          begin
            client   = client_for_uri(uri)
            response = client.post(uri.path, str, headers)
            status   = response.code.to_i
            # pp response.class.to_s
            # pp "status: #{status}"
          rescue StandardError => e
            @logger.warn("request_post retries!!! #{e.to_s}") if @logger
            invalidate_client_for_uri(uri)
            sleep(1 * retries) # wait
          end
        end

        unless response
          raise "Connection Error, Network is down?? :-((("
        end
        response
      end

      private

      MAX_RETRIES = 2

      def client_for_uri(uri)
        @clients ||= {}
        key      = uri.scheme + "://" + uri.host
        client   = @clients[key]
        unless client
          client = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == "https"
            client.use_ssl     = (uri.scheme == "https")
            client.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          @clients[key] = client
        end
        client
      end

      def invalidate_client_for_uri(uri)
        key = uri.scheme + "://" + uri.host
        @clients[uri.host] = nil if  @clients[key]
      end

    end

    class ConnectorHttpClient
      include SoapDumper

      def initialize(logger = nil)
        @logger = logger
      end

      def logger=(log)
        @logger = log
      end

      #
      # Send a soap request
      # @return [String] soap xml response
      # @raise [URI::InvalidURIError] when service_url is incorrect
      #
      def send(service_url, soap_action, request_xml)
        uri     = URI.parse(service_url)

        headers = {
            "Content-Type"   => "text/xml; charset=utf-8",
            "Content-Length" => request_xml.length.to_s,
            "SOAPAction"     => soap_action}

        @logger.info("Post to #{uri.path} (#{soap_action})") if @logger
        dump_soap_request(service_url, request_xml)
        response = post(service_url, request_xml, headers)
        unless response
          raise Sem4rError, "Connection Error"
        end
        response_xml = response.content
        dump_soap_response(service_url, response_xml)
        response_xml
      end

      #
      # Downloads content at url in path_name
      #
      def download(url, path_name)
        client = HTTPClient.new(:agent_name => 'Ruby')
        File.open(path_name, "w") do |file|
          client.get_content(url) do |chunk|
            file.write chunk
          end
        end
      end

      #
      # @return [Object, #status, #body] must respond to :status and :body
      #
      def post(service_url, body, headers)
        client   = HTTPClient.new(:agent_name => 'Ruby')
        response = client.post(service_url, body, headers)
        unless response
          raise "Connection Error, Network is down?? :-((("
        end
        response.instance_eval { def body; content; end}
        response
      end
    end

  end

end # module Sem4rSoap
