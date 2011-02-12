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
  # Manage Sem4r profiles
  #
  class CommandProfile < OptParseCommand::CliCommand

    def self.command
      "profile"
    end

    def self.description
      "manage sem4r profiles (subcommands: #{subcommands.join(', ')})"
    end

    def self.usage
      "usage profile"
    end

    def self.subcommands
      %w{list create}
    end


    def command_opt_parser(options)
      opt_parser        = OptionParser.new
      opt_parser.banner = "Usage #{self.class.command} [command_options] [#{self.class.subcommands.join("|")}]"
      opt_parser.separator ""
      opt_parser.separator "#{self.class.description}"
      opt_parser.on("-h", "--help", "show this message") do
        puts opt_parser
        options.exit = true
      end
    end

    def exec(sem4r_cli, options, rest)
      options = OpenStruct.new
      rest    = command_opt_parser(options).parse(rest)
      return false if options.exit
      if rest.empty?
        # puts "missing command"
        # return false
        rest << "list" # default command
      end

      ret             = true
      subcommand      = rest[0]
      subcommand_args = rest[1..-1]
      adwords         = sem4r_cli.adwords
      case subcommand
        when "list"
          puts "Profiles:"

          items    = []
          profiles = adwords.profiles
          names    = profiles.keys.map &:to_s
          names.sort.each do |s|
            o             = OpenStruct.new
            o.name        = s
            o.email       = profiles[s]['email']
            o.mutable     = profiles[s]['mutable']
            o.environment = profiles[s]['environment']
            items << o
          end
          OptParseCommand::report(items, :name, :environment, :email, :mutable)
        when "create"
          puts "Tobe done :-)"

        else
          puts "unknow subcommand '#{subcommand}'; must be one of #{self.class.subcommands.join(", ")}"
          return false
      end
      ret
    end

    private

    #
    # read credentials from console (create profile?)
    #
    def read_credentials_from_console
      unless @options.environment
        # The new and improved choose()...
        say("\nThis is the new mode (default)...")
        choose do |menu|
          menu.prompt = "Please choose your favorite programming language?  "

          menu.choice :ruby do
            say("Good choice!")
          end
          menu.choices(:python, :perl) do
            say("Not from around here, are you?")
          end
        end
      end

      @options.email           ||= ask("Enter adwords email:     ")
      @options.password        ||= ask("Enter adwords password:  ") { |q| q.echo = "x" }
      @options.developer_token ||= ask("Enter adwords developer_token:  ")

      config                   = {
          :environment     => @options.environment,
          :email           => @options.email,
          :password        => @options.password,
          :developer_token => @options.developer_token
      }

      pp config
      unless agree("credentials are correct?")
        exit
      end
      config
    end

  end
end
