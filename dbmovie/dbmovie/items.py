# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class DbmovieItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    movie_title1 = scrapy.Field()
    movie_title2 = scrapy.Field()
    movie_title3 = scrapy.Field()
    movie_staffs = scrapy.Field()
    movie_points = scrapy.Field()
    movie_url = scrapy.Field()
    image_url = scrapy.Field()
    movie_rank = scrapy.Field()

    pass
