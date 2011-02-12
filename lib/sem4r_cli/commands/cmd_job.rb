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
  # BulkMutateJob
  #
  class CommandJob < OptParseCommand::CliCommand

    def self.command
      "job"
    end

    def self.subcommands
      %w{list submit submit_pending delete}
    end

    def self.description
      "manage bulk mutate job (subcommands: #{subcommands.join(', ')})"
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
      return false if options.exit

      if rest.empty?
        puts "missing command"
        return false
      end

      account         = @sem4r_cli.account
      ret             = true
      subcommand      = rest[0]
      subcommand_args = rest[1..-1]
      case subcommand

        when "list"
          Sem4rCli::report(account.jobs, :id, :status)

        when "delete"
          job_id = rest[1]
          account.job_delete(job_id)

        when "submit"
          ret = create(account)

        when "submit_pending"
          ret = create(account, true)
        else
          puts "unknow subcommand '#{subcommand}'; must be one of #{self.class.subcommands.join(", ")}"
          return false
      end
      account.adwords.p_counters
      ret
    end

    private

    def create(account, pending = false)
      puts "creating example job"
      campaign, ad_group = template_campaign_and_ad_group(account)
      job = template_bulk_mutate_job(campaign, ad_group)
      if pending
        job.num_parts = 3
      end
      result_job = account.job_mutate(JobOperation.add(job))
      puts result_job.to_s
      account.p_jobs
      true
    end

  end
end
