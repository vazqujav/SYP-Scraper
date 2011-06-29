#!/usr/bin/env ruby

# = SYP Scraper
# 
# == Intro
# 
# This little app is made to scrape the Swiss Yellow Pages (SYP - http://yellow.local.ch).
# 
# Please us this app in your quest to save humanity, not in your evil plots to take over the world! 
# Feel free to fork and enhance this project.
# 
# NOTE: I WON'T PROVIDE ANY SUPPORT ON INSTALLING AND RUNNING THIS SCRIPT.
# 
# == Usage
# 
# Initialize object with industry sector (check the advanced search on SYP to find one that suits you)
# and the maximum number of available result-pages (check the pagination SYP search result)
# as parameters. If successful an array of hashes is returned, else it returns false.
# 
# == Author
# 
# javier@a-team.ch 
# 
# == Copyright
# 
# Copyright 2011, Javier Vazquez
# 
# == License
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'mechanize'
require 'iconv'

class SYPScraper

  attr_accessor :pages
  attr_accessor :agent
  attr_accessor :yp_data

  def initialize(sector, max_page)
    self.agent = Mechanize.new
    self.agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13"
    self.yp_data = []
    self.pages = []
    # go through all the pages from 0 to <max_page> 
    (0..max_page-1).each_with_index do |my_page,ind|
      url = "http://yellow.local.ch/de/q/?ext=1&name=&company=#{sector}&street=&city=&area=&phone=&start=#{ind.to_s}"
      self.yp_data << get_yp_content(self.agent.get(url))
    end
  end
  
  # return array of hashes if successful or false if not.
  def get_yp_data
    self.yp_data.flatten!
    if self.yp_data.empty? == false
      return self.yp_data
    else
      return false
    end
  end
  
  # normalize strings found at SYP
  def normalize_yp_string(my_string)
    # because div.you-b isn't unique, we get duplicate entries. get rid of them.
    # FIXME there should be a smarter way to do this...
    my_string.slice!(0..(my_string.length/2)-1)
    return my_string
  end
  
  # normalize url strings found at SYP
  def normalize_yp_url(my_string)
    # get rid of everything that doesn't look like an URL
    # FIXME there should be a smarter way to do this...
    my_string[/(^.*(.ch|.com))/]
    my_string = $1 ? "http://#{$1}" : nil
  end
  
  private

  # scrape the actual data from block element
  def get_yp_content(_page)
    cont = []
    _page.search(".//div[@class = 'yui-b']").css("div.yellowSearchResult").each do |my_div|
      name = my_div.css('a.fn').inner_text
      street = my_div.css('span.street-address').inner_text
      zip = my_div.css('span.postal-code').inner_text
      city = my_div.css('span.locality').inner_text
      phone = my_div.css('a.phonenr').inner_text
      url = my_div.css('a.ga').inner_text
      cont << { :name => self.normalize_yp_string(name), :street => self.normalize_yp_string(street), :zip => self.normalize_yp_string(zip), :city => self.normalize_yp_string(city), :url => self.normalize_yp_url(url), :phone => phone }
    end
    return cont
  end
  
end

my_data = SYPScraper.new("Astronomy", 1)
puts my_data.get_yp_data