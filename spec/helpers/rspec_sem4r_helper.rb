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

module Sem4rSpecHelper

  require "stringio"

#  def with_stdout_captured
#    old_stdout = $stdout
#    out        = StringIO.new
#    $stdout    = out
#    begin
#      yield
#    ensure
#      $stdout = old_stdout
#    end
#    out.string
#  end

#
# Capture $stdout and $stderr of a block
#
  def capture_out
    old_stdout, old_stderr = $stdout, $stderr
    out, err = StringIO.new, StringIO.new
    $stdout, $stderr = out, err
    begin
      yield
    ensure
      $stdout, $stderr = old_stdout, old_stderr
    end
    OpenStruct.new(:out => out.string, :err => err.string)
  end

  #############################################################################

  def read_xml(service, file_name)
    xml_filepath = File.expand_path File.join(File.dirname(__FILE__), "..", "sem4r", service, "fixtures", file_name)
    unless File.exist?(xml_filepath)
      raise "file #{xml_filepath} not exists"
    end
    contents = File.open(xml_filepath).read
    contents.gsub!(/\b(ns\d:|xsi:|s:|soapenv:|env:|soap:)/, "")
    contents.gsub!(/xmlns=["'].*?['"]/, '')
    contents
  end

  def write_xml(service, file_name, xml)
    fixture_dir = File.expand_path File.join(File.dirname(__FILE__), "..", "sem4r", service, "fixtures")
    FileUtils.mkdir_p(fixture_dir) unless File.directory?(fixture_dir)
    pathname = File.join(fixture_dir, file_name)
    puts "writing to #{pathname}"
    File.open(pathname, "w") { |f|
      f.puts xml
    }
  end

  def read_model(xpath, service, xml_file, &blk)
    contents     = read_xml(service, xml_file)
    xml_document = Nokogiri::XML::Document.parse(contents)
    if xpath && blk
      el = xml_document.xpath(xpath).each do |node|
        yield node
      end
    elsif xpath
      el = xml_document.xpath(xpath).first
    else
      el = xml_document.root.children.to_a.first
    end
    if el.nil?
      raise "xml element not found '#{xpath}'"
    end
    el
  end

  def read_xml_document(service, xml_file)
    contents = read_xml(service, xml_file)
    Nokogiri::XML::Document.parse(contents)
  end

  def read_xml_document_with_rexml(service, xml_file)
    contents = read_xml(service, xml_file)
    REXML::Document.new(contents)
  end

end
