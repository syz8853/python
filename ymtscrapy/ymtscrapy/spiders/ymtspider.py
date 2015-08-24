# -*- coding: utf-8 -*-

import scrapy
import re
from scrapy.selector import Selector
from ymtscrapy.items import YmtscrapyItem

class Spider1(scrapy.Spider):
    name = "apple"
    download_delay = 1
    allowed_domains = ["ymt.com"]
    start_urls = [
        "http://www.ymt.com/gongying_8199"
    ]



    def parse(self, response):
        sel = Selector(response)
        li_url = sel.xpath('//ul[@class = "table-box-con"]/li/a[@class = "wrap"]/@href').extract()
        for url in li_url:
            yield scrapy.Request(url, callback=self.parse_detail)

        page_button = sel.xpath('//div[@class = "pub_page"]/a/text()').extract()
        num_button = len(page_button)

        button1 = page_button[(num_button - 2)]
        button2 = page_button[(num_button - 3)]



        button1 = button1.encode('utf-8')
        button2 = button2.encode('utf-8')
        url_next = "none"

        if(button1 == ("下一页")):
            url_next = sel.xpath('//div[@class = "pub_page"]/a/@href').extract()[num_button -2]

        if(button2 == ("下一页")):
            url_next = sel.xpath('//div[@class = "pub_page"]/a/@href').extract()[num_button -3]

        if(url_next != "none"):
            yield scrapy.Request(url_next, callback=self.parse)





    def parse_detail(self, response):

        sel = Selector(response)
        item = YmtscrapyItem()

        p_text = sel.xpath('//div[@class = "t-time"]/text()').extract()[0]
        p_text = p_text.encode('utf-8')
        m = re.search("^.*价格：(.*)",p_text)
        p = m.group(1)

        details = sel.xpath('//div[@class = "detail-tabbox-con"]/div[@class = "box-1"]/ul/li/text()').extract()

        id_text = details[0].encode('utf-8')
        m = re.match("^供应编号：(\d*)",id_text)
        id = m.group(1)

        kind_text = details[1].encode('utf-8')
        m = re.match("^商品：(.*)", kind_text)
        kind = m.group(1)

        title_text = sel.xpath('//div[@class = "info-con"]/h2/text()').extract()[0].encode('utf-8').strip()
        title = title_text

        loc_text = sel.xpath('//div[@class = "tit-view"]/span[@class = "text"]/text()').extract()[0]
        location = loc_text.encode('utf-8').strip()


        seller_text = sel.xpath('//div[@class = "head-name"]/span[@class = "name"]/a/text()').extract()[0]
        seller = seller_text.encode('utf-8')

        slr_text = sel.xpath('//div[@class = "head-name"]/span[@class = "name"]/a/@href').extract()[0]
        seller_url = slr_text.encode('utf-8')

        #phone_text = sel.xpath('//div[@class = "relate-info"]/div[@class = "row"]'
        #                       '/span[@class = "amount"]/text()').extract()[1]
        #phone_text = phone_text.encode('utf-8').strip()
        #m = re.match("\d*.{4}\d*",phone_text)
        phone = "400-898-3008"


        attr_names = []
        attr_values = []
        for i in range(1, 8 + 1):
            str_i = "%d" % (i)
            attr_names.append("attr" + str_i +"_name")
            attr_values.append("attr" + str_i +"_value")

        i = 0
        if(len(details) == 8):
            for det in details:
                det_text = det.encode('utf-8')
                s = re.match("(.*)(：)(.*)", det_text)
                name_attr = s.group(1)
                value_attr = s.group(3)

                item[attr_names[i]] = name_attr
                item[attr_values[i]] = value_attr
                i = i + 1

        i = 0
        if(len(details) < 8):
            for det in details:
                det_text = det.encode('utf-8')
                s = re.match("(.*)(：)(.*)", det_text)
                name_attr = s.group(1)
                value_attr = s.group(3)

                item[attr_names[i]] = name_attr
                item[attr_values[i]] = value_attr
                i = i + 1

            for i_left in range(i, 7+1):
                item[attr_names[i_left]] = 'none'
                item[attr_values[i_left]] = 'none'


        item['price'] = p
        item['id'] = id
        item['kind'] = kind
        item['title'] = title
        item['location'] = location
        item['seller'] = seller
        item['seller_url'] = seller_url
        item['seller_phone'] = phone
        yield  item





