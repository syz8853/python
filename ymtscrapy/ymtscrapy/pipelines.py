# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html


class YmtscrapyPipeline(object):
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

from datetime import datetime
from scrapy import log
from twisted.enterprise import adbapi


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
        guid = item['id']
        now = datetime.utcnow().replace(microsecond=0).isoformat(' ')

        conn.execute("""SELECT EXISTS(
            SELECT 1 FROM apple WHERE id = %s
        )""", (guid, ))
        ret = conn.fetchone()[0]
        if ret:
            conn.execute("""
                UPDATE apple
                SET kind=%s, title=%s, price=%s, location=%s, seller=%s, seller_url=%s, seller_phone = %s,
                    attr1_name = %s, attr1_value = %s, attr2_name = %s, attr2_value = %s,attr3_name = %s, attr3_value = %s,
                    attr4_name = %s, attr4_value = %s, attr5_name = %s, attr5_value = %s,attr6_name = %s, attr6_value = %s,
                    attr7_name = %s, attr7_value = %s,attr8_name = %s, attr8_value = %s, updated=%s
                WHERE id=%s
            """, (item['kind'], item['title'], item['price'], item['location'], item['seller'], item['seller_url'], item['seller_phone'],
                  item['attr1_name'],item['attr1_value'], item['attr2_name'],item['attr2_value'], item['attr3_name'],item['attr3_value'],
                  item['attr4_name'],item['attr4_value'], item['attr5_name'],item['attr5_value'], item['attr6_name'],item['attr6_value'],
                  item['attr7_name'],item['attr7_value'], item['attr8_name'],item['attr8_value'], now, guid))
            spider.log("Item updated in db: %s %r" % (guid, item))
        else:
            conn.execute("""
                INSERT INTO apple (id, kind, title, price, location, seller, seller_url, seller_phone,
                                 attr1_name, attr1_value, attr2_name, attr2_value, attr3_name, attr3_value,
                                 attr4_name, attr4_value, attr5_name, attr5_value, attr6_name, attr6_value,
                                 attr7_name, attr7_value, attr8_name, attr8_value, updated)
                VALUES (%s, %s, %s, %s, %s,  %s,%s,%s,%s,%s,  %s,%s,%s,%s,%s,  %s,%s,%s,%s,%s,  %s,%s,%s,%s,%s)
            """, (guid, item['kind'], item['title'], item['price'], item['location'], item['seller'], item['seller_url'], item['seller_phone'],
                  item['attr1_name'],item['attr1_value'], item['attr2_name'],item['attr2_value'], item['attr3_name'],item['attr3_value'],
                  item['attr4_name'],item['attr4_value'], item['attr5_name'],item['attr5_value'], item['attr6_name'],item['attr6_value'],
                  item['attr7_name'],item['attr7_value'], item['attr8_name'],item['attr8_value'], now))
            spider.log("Item stored in db: %s %r" % (guid, item))

    def _handle_error(self, failure, item, spider):
        """Handle occurred on db interaction."""
        # do nothing, just log
        log.err(failure)

    '''
    def _get_guid(self, item):
        """Generates an unique identifier for a given item."""
        # hash based solely in the url field
        return md5(item['url']).hexdigest()
    '''