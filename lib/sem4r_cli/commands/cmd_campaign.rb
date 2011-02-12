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

  CommandCampaign = define_command_sem4r("campaigns", "list campaigns") do |account|
    puts "Collecting campaign from account(s) - please wait"

    # if the accounts have client_accounts it is a master
    client_accounts = account.client_accounts
    if client_accounts.empty?
      client_accounts = [account]
    end

    items        = []
    need_newline = false

    client_accounts.each do |client_account|
      if need_newline
        puts
        need_newline = false
      end

      puts "look in account '#{client_account.credentials.client_email}'"
      client_account.campaigns.each do |campaign|

        o        = OpenStruct.new
        o.client = client_account.credentials.client_email
        o.id     = campaign.id
        o.name   = campaign.name
        o.status = campaign.status
        items << o

        print "."
        need_newline = true
      end
    end

    if need_newline
      puts
      need_newline = false
    end
    report(items, :client, :id, :name, :status)
    account.adwords.p_counters
    true
  end

end
