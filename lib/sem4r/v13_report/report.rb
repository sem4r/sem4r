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
  class Report < Base

    enum :AggregationTypes, [ 
      :Summary,
      :Daily,     :Weekly,  :Monthly,  :Quarterly,  :Yearly,
      :DayOfWeek,
      :HourlyByDate, :HourlyRegardlessDate,
      :Campaign, :AdGroup, :Keyword,
      :Creative
    ]

    enum :Columns, [
      :Campaign,
      :AdGroup,
      :Keyword,
      :KeywordTypeDisplay]

    enum :ReportTypes, [
      :Account,           # Account Performance
      :AdGroup,           # Ad Group Performance
      :Campaign,          # Campaign Performance
      :Demographic,       # Demographic Performance
      :ContentPlacement,  # Placement Performance
      :Creative,          # Ad Performance
      :Geographic,        # Geographic Performance
      :Keyword,           # Placement / Keyword Performance
      :Query,             # Search Query Performance
      :ReachAndFrequency, # Reach and Frequency Performance
      :Structure,         # Account Structure
      :Url                # URL Performance
    ]

    enum :Statuses, [ :Pending, :InProgress, :Completed, :Failed ]

    ###########################################################################

    attr_reader :id
    attr_reader :account

    g_accessor :name

    g_accessor :start_day
    g_accessor :end_day

    def days(start_day, end_day)
      self.start_day start_day
      self.end_day end_day
    end

    g_accessor :aggregation
    g_accessor :type
    g_accessor :cross_client,    {:default => false}
    g_accessor :zero_impression, {:default => false}
    g_accessor :client_emails, {:default => []}

    g_reader   :status

    g_set_accessor :column

    ###########################################################################

    def initialize(account, &block)
      super( account.adwords, account.credentials )
      @account = account
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end

    def to_s
      "#{id} '#{name}' #{status}"
    end

    def xml(t)
      t.name                name
      t.selectedReportType  type
      t.startDay            start_day
      t.endDay              end_day
      t.aggregationTypes    aggregation

      t.crossClient           cross_client
      t.includeZeroImpression zero_impression

      client_emails.each do |email|
        t.clientEmails email
      end unless client_emails.empty?

      columns.each do |column|
        t.selectedColumns column
      end
    end

    def to_xml
      builder = Builder::XmlMarkup.new
      builder.job("xsi:type" => "DefinedReportJob") do |t|
        xml(t)
        #        job.name                name
        #        job.selectedReportType  type
        #        job.startDay            start_day
        #        job.endDay              end_day
        #        job.aggregationTypes    aggregation
        #
        #        job.crossClient           cross_client
        #        job.includeZeroImpression zero_impression
        #
        #        columns.each do |column|
        #          job.selectedColumns column
        #        end
      end
    end

    def self.from_element(account, el)
      new(account) do
        @id       = el.at_xpath("id").text.strip.to_i # id is read only
        name        el.at_xpath("name").text.strip
        start_day   el.at_xpath("startDay").text.strip
        end_day     el.at_xpath("endDay").text.strip
        @status   = el.at_xpath("status").text.strip # status is read only
      end
    end

    ############################################################################

    def status(refresh = false)
      return @status unless refresh
      soap_message = service.report.status(credentials, @id)
      add_counters( soap_message.counters )
      el = soap_message.response.xpath("//getReportJobStatusResponse/getReportJobStatusReturn").first
      @status = el.text
    end

    # Validate the report definition to make sure it is valid.
    # If it is not, an AdWords::Error::ApiError will be thrown.
    def validate
      begin
        service.report.validate(credentials, to_xml)
        return true
      rescue SoapError => e
        puts e
      end
      return false
    end

    def schedule
      soap_message = service.report.schedule(credentials, to_xml)
      add_counters( soap_message.counters )
      el = soap_message.response.xpath("//scheduleReportJobResponse/scheduleReportJobReturn").first
      @id = el.text
      # puts "requested report assigned job nr. #{@job_id}"
      ReportJob.new(self, @id)
    end

    def url
      soap_message = service.report.url(credentials, @id)
      add_counters( soap_message.counters )
      el = soap_message.response.xpath("//getReportDownloadUrlResponse/getReportDownloadUrlReturn").first
      url = el.text
      url
    end

    def download(path_name)
      service.report.download(url, path_name)
    end
    
  end
end
