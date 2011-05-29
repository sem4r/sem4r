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

module Sem4r

  #
  # @private
  #
  class CampaignService < Sem4rSoap::SoapServiceV2010 

    def initialize(connector)
      @connector = connector
      @service_namespace = "https://adwords.google.com/api/adwords/cm/v201008"
      @header_namespace = @service_namespace
      
      @production_service_url = "https://adwords.google.com/api/adwords/cm/v201008/CampaignService"
      @sandbox_service_url = "https://adwords-sandbox.google.com/api/adwords/cm/v201008/CampaignService"
      init(@header_namespace, @service_namespace)      
    end

    soap_call :all,   :mutate => false
    soap_call :create
    soap_call :delete
      
    private

    def _all(statuses = [Campaign::ACTIVE, Campaign::PAUSED])
      str = <<-EOFS
      <get xmlns="#{@service_namespace}">
        <selector>
      EOFS
      statuses.each do |s|
        str += "<campaignStatuses>#{s}</campaignStatuses>"
      end
      str += <<-EOFS
          <statsSelector>
            <dateRange>
              <min>20090101</min>
              <max>20091231</max>
            </dateRange>
          </statsSelector>
        </selector>
      </get>
      EOFS
    end

    def _create(xml)
      <<-EOFS
      <mutate xmlns="#{@service_namespace}">
        <operations xsi:type="CampaignOperation">
          <operator>ADD</operator>
          <operand>
            #{xml}
          </operand>
        </operations>
      </mutate>
      EOFS
    end

    def _delete(id)
      <<-EOFS
      <mutate xmlns="#{@service_namespace}">
        <operations xsi:type="CampaignOperation">
          <operator>SET</operator>
          <operand>
            <id>#{id}</id>
            <status>DELETED</status>
          </operand>
        </operations>
      </mutate>
      EOFS
    end

  end
end
