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
  # Report Definition (v201008 api)
  #
  class CommandRepDef < OptParseCommand::CliCommand

    def self.command
      "repdef"
    end

    def self.subcommands
      %w{fields list create}
    end

    def self.description
      "manage report definition (subcommands: #{subcommands.join(", ")})"
    end

    def initialize(sem4r_cli)
      @sem4r_cli = sem4r_cli
    end

    def command_opt_parser(options)
      opt_parser        = OptionParser.new
      opt_parser.banner = "Usage #{self.class.command} [command_options ] [#{self.class.subcommands.join("|")}]"
      opt_parser.separator ""
      opt_parser.separator "#{self.class.description}"
      opt_parser.on("-h", "--help", "show this message") do
        puts opt_parser
        options.exit = true
      end
    end

    def parse_and_run(argv)
      options = OpenStruct.new
      rest    = command_opt_parser(options).parse(argv)
      if options.exit
        return false
      end

      if rest.empty?
        puts "missing command"
        return false
      end

      account         = @sem4r_cli.account
      ret             = true
      subcommand      = rest[0]
      subcommand_args = rest[1..-1]
      case subcommand
        when "fields"
          report_type = ReportDefinition::AD_PERFORMANCE_REPORT
          puts "Fields for #{report_type}"
          Sem4rCli::report(account.report_fields(report_type), :field_name, :field_type)

        when "list"
          Sem4rCli::report(account.report_definitions, :id, :name)

        when "delete"
          report_definition_id = rest[1]
          account.report_definition_delete(report_definition_id)

        when "create"
          ret = create(account)
        else
          puts "unknow subcommand '#{subcommand}'; must be one of #{subcommands.join(", ")}"
          return false
      end
      account.adwords.p_counters
      ret
    end

    private

    def create(account)
      rd = account.report_definition do
        name "Keywords performance report #1290336379254"
        type "KEYWORDS_PERFORMANCE_REPORT"
        date_range "CUSTOM_DATE"
        from "20100101"
        to "20100110"
        format "CSV"

        field "AdGroupId"
        field "Id"
        field "KeywordText"
        field "KeywordMatchType"
        field "Impressions"
        field "Clicks"
        field "Cost"
      end
      rd.save
      puts rd.id
      puts rd.to_s
      account.p_report_definitions
      true
    end

  end
end
