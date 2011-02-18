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

  class Profile

    attr_reader :profile

    class << self

      #
      # @private
      # Search configuration file in standard locations
      # @return [OpenStruct] with
      #       :config_dir
      #       :config_file
      #       :password_file
      #
      def search_config
        config_filename   = "sem4r.yml"
        password_filename = "sem4r_passwords.yml"

        #
        # try current directory
        #
        # return File.expand_path(config_filename) if File.exists?( config_filename)

        #
        # try ~/.sem4r/sem4r.yml
        #
        # require 'etc'
        # homedir = Etc.getpwuid.dir
        homedir           = ENV['HOME']
        config_filepath   = File.join(homedir, ".sem4r", config_filename)
        if File.exists?(config_filepath)
          return OpenStruct.new(
              :config_dir    => File.join(homedir, ".sem4r"),
              :config_file   => config_filepath,
              :password_file => File.join(homedir, ".sem4r", password_filename))
        end

        #
        # try <home_sem4r>/config/sem4r
        #
        config_filepath = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", config_filename))
        if File.exists?(config_filepath)
          return OpenStruct.new(
              :config_dir    => nil,
              :config_file   => config_filepath,
              :password_file => nil)
        end

        config_filepath = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "sem4r.example.yml"))
        if File.exists?(config_filepath)
          return OpenStruct.new(
              :config_dir    => nil,
              :config_file   => config_filepath,
              :password_file => nil)
        end

        OpenStruct.new(
            :config_dir    => nil,
            :config_file   => nil,
            :password_file => nil)
      end

      #
      # Return list of profile contained into config file
      #
      def profiles(profile_file = nil)
        unless profile_file
          config = search_config
          unless config
            raise Sem4rError, "config file 'sem4r' not found"
          end
          profile_file = config.config_file
        end
        # puts "Loaded profiles from #{profile_file}"
        yaml     = YAML::load(File.open(profile_file))
        profiles = yaml['google_adwords']
        profiles
      end
    end

  end

end # module Sem4r