# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class YmtscrapyItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()

    id = scrapy.Field()
    kind = scrapy.Field()
    title = scrapy.Field()
    price = scrapy.Field()
    location = scrapy.Field()

    seller = scrapy.Field()
    seller_url = scrapy.Field()
    seller_phone = scrapy.Field()

    attr1_name = scrapy.Field()
    attr1_value = scrapy.Field()

    attr2_name = scrapy.Field()
    attr2_value = scrapy.Field()

    attr3_name = scrapy.Field()
    attr3_value = scrapy.Field()

    attr4_name = scrapy.Field()
    attr4_value = scrapy.Field()

    attr5_name = scrapy.Field()
    attr5_value = scrapy.Field()

    attr6_name = scrapy.Field()
    attr6_value = scrapy.Field()

    attr7_name = scrapy.Field()
    attr7_value = scrapy.Field()

    attr8_name = scrapy.Field()
    attr8_value = scrapy.Field()

    pass
