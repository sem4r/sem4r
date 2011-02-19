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

module Sem4r

  #def pretty_xml(xml)
  #  normalized = Class.new(REXML::Formatters::Pretty) do
  #    def write_text(node, output)
  #      super(node.to_s.strip, output)
  #    end
  #  end
  #  normalized.new(0, false).write(xml, xml_pretty='')
  #  xml_pretty
  #end

  def self.pretty_print_xml_with_rexml(xml)
    # TODO: using nokogiri also for pretty print xml ?
    require 'rexml/document'
    begin
      xml_document = REXML::Document.new(xml)
      f            = REXML::Formatters::Pretty.new
      out          = String.new
      f.write(xml_document, out)
      # remove xml directive
      out.gsub("<?xml version.rb='1.0' encoding='UTF-8'?>", "")
    rescue
      #    rescue RuntimeError
      puts "----------------------------------"
      puts xml
      puts "----------------------------------"
      raise
    end
    out
  end

  @_nokogiri_xsl =<<-EOFS
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes"/>
  <xsl:param name="indent-increment" select="'   '"/>

  <xsl:template name="newline">
    <xsl:text disable-output-escaping="yes">
</xsl:text>
  </xsl:template>

  <xsl:template match="comment() | processing-instruction()">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:copy />
  </xsl:template>

  <xsl:template match="text()">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="text()[normalize-space(.)='']"/>

  <xsl:template match="*">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
      <xsl:choose>
       <xsl:when test="count(child::*) > 0">
        <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="*|text()">
           <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
         </xsl:apply-templates>
         <xsl:call-template name="newline"/>
         <xsl:value-of select="$indent"/>
        </xsl:copy>
       </xsl:when>
       <xsl:otherwise>
        <xsl:copy-of select="."/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
  EOFS

  def self.pretty_print_xml_with_nokogiri(xml)
    doc  = Nokogiri::XML(xml)
    xslt = Nokogiri::XSLT(@_nokogiri_xsl)
    out  = xslt.transform(doc).root.to_xml # using root omit the xml declaration
    # out.gsub(/<\?xml version.rb=('|")1.0('|") encoding=('|")UTF-8('|")\?>/, "")
  end

end
