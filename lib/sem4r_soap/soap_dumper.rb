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
# 
# -------------------------------------------------------------------------

module Sem4rSoap

  module SoapDumper

    def initialize
      @soap_dump     = false
      @soap_dump_log = nil
    end

    #
    # set the options for the dumping soap message
    #
    # @param [Hash] options
    # @option options [String] :directory
    # @option options [String] :file
    # @option options [String] :format
    # @option options [String] :interceptor
    #
    def dump_soap_options(options)
      @soap_dump     = true
      @soap_dump_log = nil

      if options[:directory]
        @soap_dump_dir = options[:directory]
      else
        @soap_dump_log = File.open(options[:file], "w")
      end
      @soap_dump_format = false || options[:format]

      @soap_dump_interceptor = options[:interceptor] if options[:interceptor]
    end

    # TODO: request_xml might be a doc object as Nokogiri::doc
    def dump_soap_request(service_url, request_xml)
      return unless @soap_dump
      %w{email password developerToken authToken clientEmail}.each do |tag|
        request_xml = request_xml.gsub(/<#{tag}([^>]*)>.*<\/#{tag}>/, "<#{tag}\\1>***censured***</#{tag}>")
      end
      str = ""
      str << "<!-- Post to '#{service_url}' -->\n"
      str << xml_to_s(request_xml) << "\n"
      dump(service_url, "req", str)
    end

    # TODO: response_xml might be a doc object as Nokogiri::doc
    def dump_soap_response(service_url, response_xml)
      return unless @soap_dump
      response_xml.gsub(/<email[^>]*>.+<\/email>/, "<email>**censured**</email>")
      str = ""
      str << "<!-- response -->\n" unless @soap_dump_dir
      str << xml_to_s(response_xml) << "\n"
      str << "<!-- end -->" unless @soap_dump_dir
      dump(service_url, "res", str)
    end

    private

    def dump(service_url, type, str)

      @soap_dump_interceptor.call(service_url, type, str) if @soap_dump_interceptor

      if @soap_dump_dir
        service  = service_url.match(/\/([^\/]*)$/)[1]
        filename = Time.now.strftime "%Y%m%d-%H%M%S-%L-#{service}-#{type}.xml"

        FileUtils.mkdir_p(@soap_dump_dir) unless File.directory?(@soap_dump_dir)
        pathname = File.join(@soap_dump_dir, filename)
        File.open(pathname, "w") { |f|
          f.puts str
        }
      else
        @soap_dump_log.puts str
        @soap_dump_log.flush
      end
    end

    def xml_to_s(xml)
      if !@soap_dump_format
        xml
      else
        Sem4r::pretty_print_xml_with_nokogiri(xml)
      end
    end
  end

end # module Sem4rSoap
