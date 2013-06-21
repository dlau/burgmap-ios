#!/usr/bin/python

import sys
import sqlite3
import pymongo

if len(sys.argv) != 3:
    print 'syntax: generate_searchindex.py <mongo host> <sqlite file>'
    sys.exit(0)

MongoHostName = sys.argv[1]
SQLiteDBName = sys.argv[2]

MongoClient = pymongo.MongoClient(MongoHostName)
MongoDatabase = MongoClient.map
RegionCollection = MongoDatabase.regions

SQLiteClient = sqlite3.connect(SQLiteDBName)
SQLiteCursor = SQLiteClient.cursor()
SQLiteCursor.execute('DROP TABLE IF EXISTS regions')
SQLiteCursor.execute('''CREATE TABLE regions 
    (pg_id real, name text, name_unac text, parent_name_unac text, display_name text, display_name_unac text, lat float, lng real)''')
SQLiteClient.commit()

for Region in RegionCollection.find():
    #print Region
    Id = 0
    Lat = 0.0
    Lng = 0.0
    if u'pg_id' in Region:
        Id = Region[u'pg_id']
    if u'lat' in Region:
        Lat = Region[u'lat']
    if u'lng' in Region:
        Lng = Region[u'lng']
    Name = Region[u'name']
    Name_Unaccented = Region[u'name_unac']
    ParentName_Unaccented = ''
    Display_Name = Region[u'name']
    Display_Name_Unaccented = Region[u'name_unac'];
    if u'path_by_name' in Region and Region[u'path_by_name'] != None:
        Parents = Region[u'path_by_name'].split(u',')
        Parents = filter(None, Parents)
        Display_Name = Parents[-1] + ' - ' + Display_Name
        ParentName_Unaccented = filter(None, Region[u'path_by_name_unac'].split(u','))[-1]
        Display_Name_Unaccented = ParentName_Unaccented + ' ' + Display_Name_Unaccented;
    SQLiteCursor.execute("INSERT INTO regions VALUES(?,?,?,?,?,?,?,?)" , \
        (Id, Name, Name_Unaccented, ParentName_Unaccented, Display_Name, Display_Name_Unaccented, Lat, Lng))

SQLiteClient.commit()
SQLiteClient.close()