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

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe AdGroupCriterion do

  include Sem4rSpecHelper

  before do
    services = stub("services")
    mock_service_ad_group_criterion(services)
    @ad_group = adgroup_mock(services)
    @criterion = stub("criterion")
    @bids = stub("bids")
  end

  describe BiddableAdGroupCriterion do

    it "should be build with accessor (not a block)" do
      biddable_criterion = BiddableAdGroupCriterion.new(@ad_group)
      biddable_criterion.criterion @criterion
      biddable_criterion.bids @bids
      biddable_criterion.criterion.should  eql @criterion
      biddable_criterion.bids.should eql @bids
    end

    it "shoud produce xml (input for google)" do
      keyword = CriterionKeyword.new(@ad_group) do
        text       "sem4r adwords api"
        match      "BROAD"
      end
      bids = ManualCPCAdGroupCriterionBids.new
      bids.max_cpc 10000000

      biddable_criterion = BiddableAdGroupCriterion.new(@ad_group)
      biddable_criterion.criterion keyword
      biddable_criterion.bids bids

      xml_expected = read_model("//operand", "services", "ad_group_criterion_service", "mutate_add_criterion_keyword-req.xml")
      biddable_criterion.to_xml("operand").should  xml_equivalent(xml_expected)
    end

    it "should parse xml (produced by google)" do
      el = read_model("//entries", "services", "ad_group_criterion_service", "get-res.xml")
      biddable_criterion = BiddableAdGroupCriterion.from_element(@ad_group, el)
      biddable_criterion.bids.should be_instance_of(ManualCPCAdGroupCriterionBids)
      biddable_criterion.criterion.should be_instance_of(CriterionKeyword)
    end

  end

  describe NegativeAdGroupCriterion do

    it "should accept a block (not a block)" do
      biddable_criterion = NegativeAdGroupCriterion.new(@adgroup)
      biddable_criterion.criterion @criterion
      biddable_criterion.criterion.should  eql @criterion
    end

    it "should parse xml (produced by google)" do
      pending "Test"
      el = read_model("//criterion", "services", "ad_group_criterion_service", "mutate_add_criterion_placement-res.xml")
      placement = CriterionPlacement.from_element(@adgroup, el)
      placement.id.should == 11536085
      placement.url.should == "github.com"
    end

  end

end
