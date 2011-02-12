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
# 
# -------------------------------------------------------------------------

module Sem4rCli

  #
  # idea
  #
  class CommandIdeas < OptParseCommand::CliCommand

    def self.command
      "ideas"
    end

    def self.description
      "list ideas"
    end

    def initialize(common_args)
      @common_args = common_args
    end

    def parse_and_run(argv)
      options = OpenStruct.new
      rest    = opt_parser(options).parse(argv)
      return false if options.exit

      if rest.length < 1
        puts "keyword missing; see help"
        return false
      end

      keyword = rest[1]
      account = @common_args.account
      unless account
        puts "select an account!"
        return false
      end
      _run(account, keyword)
    end

    private

    def opt_parser(options)
      opt_parser       = OptionParser.new
      opt_parser.banner= "#{self.class.description}"
      opt_parser.separator "Usage: sem [options] idea <keyword>"

      opt_parser.separator ""
      opt_parser.separator "common options: "
      opt_parser.separator ""
      opt_parser.on("-h", "--help", "show this message") do
        puts opt_parser
        options.exit = true
      end
    end

    def _run(account, keyword)
      ideas = account.targeting_idea do
        idea_type "KEYWORD"
        request_type "IDEAS"

        related_to_keyword_search_parameter do
          text keyword
          match_type 'EXACT'
        end
      end

      items = []
      ideas.each do |i|
        i.each do |a|
          next if a.class != TKeywordAttribute
          o       = OpenStruct.new
          o.text  = a.text
          o.match = a.match_type
          items << o
        end
      end

      Sem4rCli::report(items, :text, :match)
      account.adwords.p_counters
      true
    end

  end

end # module Sem4rCli
