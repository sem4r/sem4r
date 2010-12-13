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

require 'rexml/document'
require 'differ'
require 'differ/string'

# comparing xml is always a b-i-a-t-c-h in any testing environment.  here is a
# little snippet for ruby that, i think, it a good first pass at making it
# easier.  comment with your improvements please!
#
# http://drawohara.com/post/89110816/ruby-comparing-xml

def normalize_xml(expected_xml)
  if expected_xml.class != String
    expected_xml = expected_xml.to_s
  end

  if expected_xml.class == String
    expected_xml = expected_xml.gsub(/^\n/, "")  # erase empty lines
    # erase namespaces i.e. <ns1:tag> -> <tag>
    expected_xml = expected_xml.gsub(/\b(ns\d:|xsi:|s:|soapenv:|env:|soap:|^\n)/, "").strip
  end
  expected_normalized = Sem4r::pretty_print_xml_with_nokogiri(expected_xml)
  # erase namespaces i.e. <ns1:tag> -> <tag>
  expected_normalized.gsub(/(ns\d:|xsi:|s:|soapenv:|env:|soap:|^\n| {2,})/, "").strip
end

def diff_xml(expected_xml, xml)
  expected_normalized = normalize_xml(expected_xml)
  xml_normalized      = normalize_xml(xml)

  if xml_normalized == expected_normalized
    return nil
  end
  str =  "--- this xml \n"
  str << xml_normalized
  str << "\n--- expected to be equals to\n"
  str << expected_normalized

  str << "\n--- difference are:\n"

  diff = Differ.diff_by_line(xml_normalized, expected_normalized)
  
  str << diff.format_as(:ascii)
  str << "\n----differ end"
  str
end

def _xml_contains(expected_xml, xml)
  expected_normalized = normalize_xml(expected_xml)
  xml_normalized      = normalize_xml(xml)
  unless xml_normalized.match(expected_normalized)
    false
  else
    true
  end
end

RSpec::Matchers.define :xml_equivalent do |expected_xml|
  description do
    "checks if two xml are equivalent"
  end

  match do |xml|
    if xml.respond_to? :to_xml
      xml = xml.to_xml
    end
    if expected_xml.respond_to? :to_xml
      expected_xml = expected_xml.to_xml
    end
    @diff_result = diff_xml(expected_xml, xml)
    @diff_result.nil?  # no diff
  end

  failure_message_for_should do |expected_xml|
    "#{@diff_result}"
  end
end

RSpec::Matchers.define :xml_contains do |expected_xml|
  match do |xml|
    if xml.respond_to? :to_xml
      xml = xml.to_xml
    end
    if expected_xml.respond_to? :to_xml
      expected_xml = expected_xml.to_xml
    end
    _xml_contains(expected_xml, xml)
  end
end
