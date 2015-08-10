# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class DbmoviePipeline(object):
    def process_item(self, item, spider):
        return item


import json
import codecs
class JsonWriterPipeline(object):
    def __init__(self):
        self.file = codecs.open('items.json','w', encoding='utf-8')

    def process_item(self, item, spider):
        line = json.dumps(dict(item)) + "\n"
        self.file.write(line.decode('unicode_escape'))
        return item

import re
from scrapy import log
from twisted.enterprise import adbapi
from scrapy.exceptions import DropItem
import time
import MySQLdb
from scrapy.exceptions import DropItem


class MySQLStorePipeline(object):
    """A pipeline to store the item in a MySQL database.

    This implementation uses Twisted's asynchronous database API.
    """

    def __init__(self, dbpool):
        self.dbpool = dbpool

    @classmethod
    def from_settings(cls, settings):
        dbargs = dict(
            host=settings['MYSQL_HOST'],
            db=settings['MYSQL_DBNAME'],
            user=settings['MYSQL_USER'],
            passwd=settings['MYSQL_PASSWD'],
            charset='utf8',
            use_unicode=True,
        )
        dbpool = adbapi.ConnectionPool('MySQLdb', **dbargs)
        return cls(dbpool)

    def process_item(self, item, spider):
        # run db query in the thread pool
        d = self.dbpool.runInteraction(self._do_upsert, item, spider)
        d.addErrback(self._handle_error, item, spider)
        # at the end return the item in case of success or failure
        d.addBoth(lambda _: item)
        # return the deferred instead the item. This makes the engine to
        # process next item (according to CONCURRENT_ITEMS setting) after this
        # operation (deferred) has finished.
        return d

    def _do_upsert(self, conn, item, spider):
        """Perform an insert or update."""
        #guid = self._get_guid(item)
        #now = datetime.utcnow().replace(microsecond=0).isoformat(' ')

        conn.execute("select * from topmv where rank = %s", (item['movie_rank']))
        ret = conn.fetchone()

        if ret:
            spider.log("Item exists in db: %s" % (item['movie_rank']))
        else:
            conn.execute("""
                INSERT INTO topmv (rank, mv_t1, mv_t2, mv_t3, mv_staff, mv_pts, mv_url, img_url)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (item['movie_rank'], item['movie_title1'], item['movie_title2'], item['movie_title3'], item['movie_staffs'],
                  item['movie_points'], item['movie_url'], item['image_url']))
            spider.log("Item stored in db: %s" % (item['movie_rank']))

    def _handle_error(self, failure, item, spider):
        """Handle occurred on db interaction."""
        # do nothing, just log
        log.err(failure)

