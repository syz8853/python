# -*- coding: utf-8 -*-

import scrapy
import re
from scrapy.selector import Selector
from dbmovie.items import DbmovieItem


class dbTopSpider(scrapy.Spider):
    name = "top1"
    download_delay = 1
    allowed_domains = ["douban.com"]
    start_urls = [
        "http://movie.douban.com/top250?start=0&filter=&type="
    ]







    def parse(self, response):
        sel = Selector(response)
        items = sel.xpath('//li/div[@class = "item"]')
        #its_content = items.xpath('.//div[@class = "info"]/div[@class = "hd"]/a')
        #title_mv = its_content.xpath('.//span[@class = "title"]/text()').extract()
        #items = sel.xpath('//li/div[@class = "item"]/div[@class = "info"]/div[@class = "hd"]/a')
        #items.xpath('//div[@class = "info"]/div[@class = "bd"]/div/span/em')[0]
        #izy=items.xpath('//div[@class = "info"]/div[@class = "bd"]/p/text()')[0].extract()




        itemss = []
        for its in items:
            i = its.xpath('.//div[@class = "info"]/div[@class = "hd"]/a')
            url = i.xpath('@href').extract()


            titles = i.xpath('.//span[@class = "title"]/text()').extract()
            if len(titles) == 2:
                t1 = titles[0]
                t2 = titles[1]
            else:
                t1 = titles[0]
                t2 = "None"

            t1 = t1.encode('utf-8')


            t2 = t2.encode('utf-8')
            t2 = t2.strip('\xc2\xa0\/')


            t3 = i.xpath('.//span[@class = "other"]/text()').extract()[0]
            t3 = t3.encode('utf-8')
            t3 = t3.strip('\xc2\xa0\/')


            img_url = its.xpath('.//div[@class = "pic"]/a/img/@src').extract()[0]


            pts = its.xpath('.//div[@class = "info"]/div[@class = "bd"]/div/span/em/text()').extract()[0]


            staffs = its.xpath('.//div[@class = "info"]/div[@class = "bd"]/p/text()').extract()[0]
            staffs = staffs.encode('utf-8')
            staffs = staffs.lstrip('\n')
            staffs = staffs.lstrip()


            rank = its.xpath('.//div[@class = "pic"]/em/text()').extract()[0]


            itemp = DbmovieItem()
            itemp['movie_title1'] = t1
            itemp['movie_title2'] = t2
            itemp['movie_title3'] = t3
            itemp['movie_staffs'] = staffs
            itemp['movie_points'] = pts
            itemp['movie_url'] = url[0]
            itemp['image_url'] = img_url
            itemp['movie_rank'] = rank

            itemss.append(itemp)
            yield (itemp)





        #yield itemss


        url_dbmv = "http://movie.douban.com/top250"
        next_page = sel.xpath('//span[@class = "next"]/a/@href').extract()
        if next_page:
            next_url = url_dbmv + next_page[0]
            yield scrapy.Request(next_url, callback=self.parse)


        """
        urls = sel.xpath('//li[@class="next_article"]/a/@href').extract()
        for url in urls:
            print url
            url = "http://blog.csdn.net" + url
            print url
            yield Request(url, callback=self.parse)
        """