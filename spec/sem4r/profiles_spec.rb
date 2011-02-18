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

require File.expand_path(File.dirname(__FILE__) + '/../rspec_helper')

describe Profile do

  before(:each) do
    @test_config_filename   = File.expand_path(File.dirname(__FILE__) + "/../fixtures/sem4r.example.yml")
    @test_password_filename = File.expand_path(File.dirname(__FILE__) + "/../fixtures/password.example.yml")

    @environment          = "sandbox"
    @email                = "sem4ruby@sem4r.com"
    @password             = "password"
    @developer_token      = "developer_token"

    @options              = {
        :environment     => @environment,
        :email           => @email,
        :password        => @password,
        :developer_token => @developer_token,
    }
  end

  it "should list profiles" do
    values = Profile.profiles(@test_config_filename)
    values.should have(5).profiles
  end

end

