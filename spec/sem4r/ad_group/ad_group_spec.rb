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

require File.expand_path(File.dirname(__FILE__) + '/../../rspec_helper')


describe AdGroup do

  include Sem4rSpecHelper

  before do
    services = double("services")
    stub_service_ad_group(services)
    stub_service_ad_group_criterion(services)
    stub_service_ad_group_ad(services)
    stub_service_ad_param(services)
    @campaign = stub_campaign(services)
    @criterion = stub_criterion(services)
  end

  describe "adgroup management" do

    it "create should accept a block (instance_eval)" do
      adgroup = AdGroup.create(@campaign) do
        name "adgroup"
      end
      adgroup.name.should  == "adgroup"
      adgroup.id.should    == 10
    end

    it "create should accept a block (call)" do
      adgroup = AdGroup.create(@campaign) do |g|
        g.name "adgroup"
      end
      adgroup.name.should  == "adgroup"
      adgroup.id.should    == 10
    end

    it "create should accept a manual cpc bids" do
      adgroup = AdGroup.create(@campaign) do
        name "sem4r library"
        manual_cpc_bids do
          keyword_max_cpc 10000
        end
      end
      adgroup.bids.should be_instance_of(ManualCPCAdGroupBids)
    end

    it "create should accept a manual cpm bids" do
      adgroup = AdGroup.create(@campaign) do
        name "sem4r library"
        manual_cpm_bids do
          max_cpm 10000
        end
      end
      adgroup.bids.should be_instance_of(ManualCPMAdGroupBids)
    end

    it "should build xml (input for google)" do
      adgroup = AdGroup.create(@campaign) do
        name "sem4r library"
        manual_cpc_bids do
          keyword_max_cpc 20000000
          site_max_cpc 30000000
        end
      end
      expected_xml = read_model("//operand", "ad_group", "mutate_add-req.xml")
      adgroup.to_xml("operand").should xml_equivalent(expected_xml)
    end

    it "should parse xml (produced by google)" do
      el = read_model("//entries", "ad_group", "get-first-res.xml")
      adgroup = AdGroup.from_element(@campaign, el)
      adgroup.id.should == 3060217923
      adgroup.name.should == "test adgroup"
      adgroup.status.should == "ENABLED"
    end

    it "should parse xml (produced by google) with manual cpm bids" do
      el = read_model("//entries", "ad_group", "get-manual-cpm-bids-res.xml")
      adgroup = AdGroup.from_element(@campaign, el)
      adgroup.bids.should be_instance_of(ManualCPMAdGroupBids)
    end
    
  end

  describe "ad management" do

    it "should create a TextAd with a block" do
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        text_ad do
          url           "http://www.pluto.com"
          display_url   "www.Pluto.com"
          headline      "Vieni da noi"
          description1  "vieni da noi"
          description2  "arivieni da noi"
        end
      end

      adgroup.ads.length.should   == 1
      adgroup.ads.first.id.should == 10
    end

  end

  describe "criterion management" do

    it "should add a CriterionKeyword with method 'keyword' + block" do
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        keyword do
          text "pippo"
          match "BROAD"
        end
      end
      adgroup.should have(1).criterions
      criterion = adgroup.criterions.first.criterion
      criterion.text.should == "pippo"
      criterion.id.should == 10
    end

    it "should add a CriterionKeyword with method 'keyword' + parameters" do
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        keyword "pippo", "BROAD"
      end
      adgroup.should have(1).criterions
      criterion = adgroup.criterions.first.criterion
      criterion.id.should == 10
      criterion.text.should == "pippo"
    end
    
    it "should add a CriterionPlacement with method 'placement' + block" do
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        placement do
          url "pippo"
        end
      end
      adgroup.criterions.length.should   == 1
      criterion = adgroup.criterions.first.criterion
      criterion.id.should == 10
      criterion.url.should == "pippo"
    end

    it "should add a CriterionPlacement with method 'placement' + parameters" do
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        placement "url"
      end
      adgroup.criterions.length.should   == 1
      criterion = adgroup.criterions.first.criterion
      criterion.id.should == 10
      criterion.url.should == "url"
    end
  end

  describe "ad_param management" do

    it "should create a AdParam with method 'ad_param' + block" do
      criterion = @criterion # it is necessary to the following block
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        ad_param(criterion) do
          index 1
          text  "$99.99"
        end
      end

      adgroup.ad_params.length.should   == 1
      param = adgroup.ad_params.first
      param.index.should == 1
      param.text.should == "$99.99"
    end

    it "should create a AdParam with method 'ad_param' + param" do
      criterion = @criterion # it is necessary to pass to following block
      adgroup = AdGroup.new(@campaign) do
        name "adgroup"
        ad_param criterion, 1, "$99.99"
      end

      adgroup.ad_params.length.should   == 1
      param = adgroup.ad_params.first
      param.index.should == 1
      param.text.should == "$99.99"
    end
  end

end
