# -*- coding: utf-8 -*-
# -------------------------------------------------------------------
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
# -------------------------------------------------------------------

module Sem4rSoap

  class SoapService

    def initialize
      @soap_namespaces = {}
    end

    def init(header_namespace, service_namespace)
      @soap_namespaces = {}

      @header_namespace = header_namespace
      @soap_namespaces['xmlns'] = header_namespace if header_namespace

      @service_namespace = service_namespace
      @soap_namespaces['xmlns:s'] = service_namespace if service_namespace
    end

    def build_soap_message(soap_header, soap_body)
      soap_message = '<?xml version="1.0" encoding="utf-8" ?>'
      soap_message +=<<-EOFS
      <env:Envelope
         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
      EOFS

      @soap_namespaces.each do |name, value|
        soap_message += " #{name}=\"#{value}\""
      end
      soap_message += ">"

      soap_message += soap_header
      soap_message += "<env:Body>"
      soap_message += soap_body
      soap_message += "</env:Body>"

      soap_message += "</env:Envelope>"
      soap_message
    end

    def helper_call(api_version, credentials, soap_body)
      soap_action = ""

      case api_version
        when "v13"
          match_data = soap_body.match(/<(\w+)/m)
          if match_data
            soap_action = match_data[1]
          else
            raise "Soapaction not found in #{soap_body}"
          end
        when "v2010"
        else
          raise "unknown api version #{api_version}"
      end

      soap_xml = build_soap_message(build_soap_header(credentials), soap_body)
      if credentials.sandbox?
        _send(@sandbox_service_url, soap_action, soap_xml)
      else
        _send(@production_service_url, soap_action, soap_xml)
      end
    end

    def helper_call_raw(credentials, xml_message)
      soap_message = SoapMessageV2010.new(@connector, credentials)
      soap_message.init( @header_namespace, @service_namespace )
      if credentials.sandbox?
        soap_message.send_raw(@sandbox_service_url, xml_message)
      else
        soap_message.send_raw(@production_service_url, xml_message)
      end
    end

    def self._soap_call(api_version, method, options = {})
      options.assert_valid_keys(:mutate)
      mutate = options.delete :mutate
      if mutate.nil? or mutate
        smutate = "credentials.mutable?"
      else
        smutate = "true"
      end
      ruby_str =<<-EOFS
          define_method :#{method.to_sym} do |*args|
            credentials = args.shift
            if #{smutate}
              soap_body = send("_#{method}", *args)
              helper_call('#{api_version}', credentials, soap_body)
            else
              raise "mutate methods '#{method}' cannot be called on read_only profile"
            end
          end
      EOFS
      eval ruby_str

      ruby_str =<<-EOFS
          define_method :#{(method.to_s + "_raw").to_sym} do |*args|
            credentials = args.shift
            soap_message = args.shift
            if #{smutate}
              helper_call_raw('#{api_version}', credentials, soap_message)
            else
              raise "mutate methods '#{method}' cannot be called on read_only profile"
            end
          end
      EOFS
      eval ruby_str
    end

  end

end # module Sem4rSoap
