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

module Sem4rCli

  #
  # Macro helper for define new sem4r command
  #
  def self.define_command_sem4r(command_name, description, &block)
    OptParseCommand::define_command(command_name, description) do |cli, options, rest|
      account = cli.account
      unless account
        puts "please select a valid account!"
        false
      else
        block.call(account)
      end
    end
  end

  #
  # CliSem Driver
  #   parses common options
  #   finds command and instantiate command
  #   passes the unparsed parameter to command
  #   leaves control to command
  #
  class CliSem < OptParseCommand::CliMain

    def self.command
      "sem4r"
    end

    def self.description
      "Sem is a simple command line interface using the sem4r library.\n" +
          "It's alpha software, please don't use in production or use it at your risk!\n" +
          "Code https://github.com/sem4r/sem4r. Feedback to sem4ruby@gmail.com\n" +
          "Further information: http://www.sem4r.com\n\n"
    end

    def self.version
      Sem4r::VERSION
    end

    def defaults
      OpenStruct.new({:verbose         => true,
                      :force           => false,
                      :default_logging => true,
                      # :dump_soap_to_file => true,
                      # :dump_soap_to_directory => true,
                      :profile         => 'sandbox',
                      :ask_password    => false
                     })
    end

    def option_parser(options)
      parser = super(options)

      parser.separator "execute COMMAND to an adwords account using google adwords api"
      parser.separator "To view help and options for a particular command, use 'sem COMMAND -h'"

      #
      # common options
      #
      parser.on("-v", "--[no-]verbose", "run verbosely") do |v|
        options.verbose = v
      end

      parser.on("-q", "--quiet", "quiet mode as --no-verbose") do |v|
        options.verbose = false
      end

      #
      # Logging
      #
      parser.separator ""
      parser.separator "logging options: "
      parser.separator ""

      parser.on("--log FILE", "log sem4r messages to file") do |v|
        options.logger = v
      end

      parser.on("--dump-file FILE", "dump soap conversation to file") do |v|
        options.dump_soap_to_file = v
      end

      str = "dump soap conversation to directory: each \n"
      str << (" " * 37) + "request/response is in a single file"
      parser.on("--dump-dir DIRECTORY", str) do |v|
        options.dump_soap_to_directory = v
      end

      #
      # Profile - Configuration
      #
      parser.separator ""
      parser.separator "profile and credentials options: "
      parser.separator "  credentials options overwrite profile attributes"
      parser.separator ""

      str = "file where profiles are defined\n"
      str << (" " * 37) + "(default $HOME/.sem4r/sem4r.yaml)"
      parser.on("--config CONFIG", str) do |config|
        options.config_name = config
      end

      parser.on("-p", "--profile PROFILE", "select profile (default is sandbox)") do |profile|
        options.profile = profile
      end

      # email
      parser.on("--email EMAIL",
                "email of adwords account") do |email|
        options.email = email
      end

      # password
      parser.on("-a", "--ask-password",
                "ask password on terminal") do
        options.ask_password = true
      end

      parser.on("--password PASSWORD",
                "password of adwords account") do |password|
        options.password = password if password
      end

      # developer token
      parser.on("--token TOKEN",
                "developer token to access adwords api") do |token|
        options.developer_token = token
      end

      # client account
      parser.on("-c", "--client EMAIL",
                "email for client account") do |email|
        options.client_email = email
      end
      parser.separator ""
      parser
    end

    def read_password_from_terminal
      ask("Enter your password:  ") { |q| q.echo = "x" }
    end

#    def parse_and_run(all_args)
#
#      begin
#        command_args = opt_parser(@options).order(all_args)
#      rescue OptionParser::AmbiguousOption => e
#        puts e.message
#        return false
#      end
#      return true if @options.exit
#
#      if command_args.empty?
#        puts "missing command try sem -h for help"
#        return false
#      end
#
#      command      = command_args[0]
#      command_args = command_args[1..-1]
#
#      # find command
#      if CliCommand.commands[command].nil?
#        puts "unknow command #{command}"
#        return false
#      end
#
#      begin
#        cmd = CliCommand.commands[command].new(self)
#        return cmd.parse_and_run(command_args)
#      rescue Sem4rError
#        puts "I am so sorry! Something went wrong! (exception #{$!.to_s})"
#        return false
#      end
#    end

    #
    # initialize adwords according to command line options
    # return [Sem4r::Adwords]
    #
    def adwords
      return @adwords if @adwords

      #
      # select profile
      #
      options = {}
      if @options.config_name
        options[:config_file] = @options.config_name
      end
      @adwords = Sem4r::Adwords.new(@options.profile, options)
      if @options.verbose
        puts "using #{@adwords.profile} profile"
        puts "config file is #{@adwords.config_file}"
      end
      #
      # Extracts dump soap options
      #
      if @options.default_logging
        config_dir = File.join(ENV['HOME'], ".sem4r")
        unless File.exists?(config_dir)
          puts "Directory #{config_dir} not exists"
          FileUtils.mkdir(config_dir)
        end
        dir                             = File.join(config_dir, Time.new.strftime("%Y%m%d-soap-dump"))
        @options.dump_soap_to_directory = dir

        file                            = File.join(config_dir, Time.new.strftime("%Y%m%d-sem4r-log"))
        @options.logger                 = file
      end

      if @options.dump_soap_to_file
        filename = @options.dump_soap_to_file
        o        = {:file => filename}
        @adwords.dump_soap_options(o)
      end
      if @options.dump_soap_to_directory
        dir = @options.dump_soap_to_directory
        o   = {:directory => dir, :format => true}
        @adwords.dump_soap_options(o)
      end
      if @options.verbose and adwords.dump_soap?
        puts "Logging soap conversation to '#{adwords.dump_soap_where}'"
      end
      if !@adwords.dump_soap?
        puts "it is highly recommended to activate the dump soap log"
      end

      #
      # Extracts log options
      #
      # filename = File.join( tmp_dirname, File.basename(example_file).sub(/\.rb$/, ".log") )
      if @options.logger
        # filename = "sem.log"
        @adwords.logger = @options.logger
      end
      if @adwords.logger
        puts "Logger is active" if @options.verbose
      end
      @adwords
    end

    #
    # select account according to the command line arguments
    # return [Sem4r::Account]
    #
    def account
      return @account if @account

      adwords # initialize sem4r lib adwords
      if @options.ask_password or !@adwords.has_password?
        pwd               = read_password_from_terminal
        @adwords.password = pwd
        @adwords.save_passwords
      end

      #
      # select account for command
      #
      if @options.client_email
        account = @adwords.account.client_accounts.find { |c| c.client_email =~ /#{@options.client_email}/ }
        if account.nil?
          puts "client account not found"
        else
          puts "using client #{account.client_email}"
        end
      else
        account = @adwords.account
      end
      @account = account
    end


  end

end # module Sem4rCli
