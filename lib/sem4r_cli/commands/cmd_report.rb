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

module Sem4rCli

  #
  # report (v13 api)
  #
  class CommandReport < OptParseCommand::CliCommand

    def self.command
      "report"
    end

    def self.description
      "manage v13 report"
    end

    def initialize(common_args)
      @common_args = common_args
      @subcommands = %w{list download schedule}
    end

    def parse_and_run(argv)
      options = OpenStruct.new
      rest    = command_opt_parser(options).parse(argv)
      return false if options.exit

      if rest.length == 0
        puts "missing sub command"
        return false
      end

      ret = true
      subcommand = rest[0]
      subcommand_args = rest[1..-1]
      case subcommand
        when "list"
          Sem4rCli::report(@common_args.account.reports, :id, :name, :status)

        when "download"
          ret = download(subcommand_args)

        when "schedule"
          ret = schedule(subcommand_args)
          
        else
          puts "unknow subcommand '#{subcommand}'; must be one of #{@subcomands.join(", ")}"
          return false
      end

      @common_args.account.adwords.p_counters
      ret
    end

    private

    def command_opt_parser(options)
      opt_parser        = OptionParser.new
      opt_parser.banner = "Usage #{self.class.command} [command_options ] [#{@subcommands.join("|")}]"
      opt_parser.separator ""
      opt_parser.separator "#{self.class.description}"

      opt_parser.on("-h", "--help", "show this message") do
        puts opt_parser
        options.exit = true
      end
    end

    #
    # download a v13 report
    #
    def download(args)
      if args.length != 1
        puts "missing report id for 'download' subcommand"
        return false
      end

      report_id = args[0].to_i
      report    = @common_args.account.reports.find { |r| r.id == report_id }
      if report.nil?
        puts "report '#{report_id}' not found"
        return false
      end

      if report.status != 'Completed'
        puts "cannot download report with status '#{report.status}'"
        return false
      end

      path_name = "test_report.xml"
      puts "Download report #{report.id} in #{path_name}"
      report.download(path_name)
      true
    end

    #
    # schedule and download a v13 report
    #
    def schedule(argv)

      report = @account.report do
        name            'boh'
        type            'Url'
        aggregation     'Daily'
        cross_client    true
        zero_impression true

        start_day '2010-01-01'
        end_day   '2010-01-30'

        column "CustomerName"
        column "ExternalCustomerId"
        column "CampaignStatus"
        column "Campaign"
        column "CampaignId"
        column "AdGroup"
        column "AdGroupId"
        column "AdGroupStatus"
        column "QualityScore"
        column "FirstPageCpc"
        column "Keyword"
        column "KeywordId"
        column "KeywordTypeDisplay"
        column "DestinationURL"
        column "Impressions"
        column "Clicks"
        column "CTR"
        column "CPC"
        column "MaximumCPC"
        column "Cost"
        column "AveragePosition"
      end

      unless report.validate
        puts "report not valid"
        exit
      end
      puts "scheduled job"
      job = report.schedule
      job.wait(10) { |report, status| puts "status #{status}" }
      report.download("test_report.xml")
      true
    end

  end
end
