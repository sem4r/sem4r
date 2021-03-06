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

require File.expand_path(File.dirname(__FILE__) + '/../../rspec_helper')

describe AdGroupCriterionBids do
  include Sem4rSpecHelper

  it "should parse xml (produced by google)" do
    el = read_model("//bids", "ad_group_criterion", "get-res.xml")
    bids = AdGroupCriterionBids.from_element(el)
    bids.should be_instance_of ManualCPCAdGroupCriterionBids
  end

  describe ManualCPCAdGroupCriterionBids do

    it "should accept accessor" do
      bids = ManualCPCAdGroupCriterionBids.new
      bids.max_cpc 10000000
      bids.max_cpc.should == 10000000
    end

    it "should build xml (input for google)" do
      pending "move on api201101"
      bids = ManualCPCAdGroupCriterionBids.new
      bids.max_cpc 10000000
      expected_xml = read_model("//bids", "ad_group_criterion", "mutate_add_criterion_keyword-req.xml")
      bids.to_xml.should  xml_equivalent( expected_xml )
    end

    it "should parse xml (produced by google)" do
      el = read_model("//bids", "ad_group_criterion", "get-res.xml")
      bids = ManualCPCAdGroupCriterionBids.from_element(el)
      bids.bid_source.should == "ADGROUP"
      bids.max_cpc.should == 10000000
    end

  end

end
