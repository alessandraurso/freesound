#!/usr/bin/env python
# -*- coding: utf-8 -*-

from local_settings import *
import codecs
from db_utils import get_user_ids
import re
from text_utils import prepare_for_insert, smart_character_decoding
from HTMLParser import HTMLParseError


OUT_FNAME = 'profiles.sql'
VALID_USER_IDS = get_user_ids()



def transform_row(insert_id, row): 
        
    user_id, home_page, signature, is_whitelisted, about, \
            wants_newsletter = row

    if user_id not in VALID_USER_IDS:
        return

    url_match = re.compile(
        r"^http:\/\/[\w_-]+\.[\.\w_-]+\/?[@\.\w/_\?=~;:%#&\+-]*$", 
        re.IGNORECASE
    )

    if home_page:
        home_page = smart_character_decoding(home_page)
    if signature:
        signature = smart_character_decoding(signature)
    if about:
        about = smart_character_decoding(about)
                
    if home_page:
        home_page = home_page.lower()
        split = home_page.split()
        if len(split) > 1:
            home_page = split[0]
        
        if not url_match.match(home_page):
            home_page = None

    if signature:
        signature = prepare_for_insert(signature)
    
    if about:
        try:
            about = prepare_for_insert(about)
        except HTMLParseError:
            about = ""
    
    geotag = None
    num_sounds = 0
    num_posts = 0
    has_avatar = 0

    fields = [ insert_id, user_id, home_page, signature, is_whitelisted,
        about, wants_newsletter, geotag, num_sounds, num_posts, 
        unicode(has_avatar) ]

    return map(unicode, fields)



def migrate_profiles(curs):

    out = codecs.open(OUT_FNAME, 'wt', 'utf-8')

    sql_head = """
--
-- Profiles
--
COPY accounts_profile (id, user_id, home_page, signature, is_whitelisted, 
    about, wants_newsletter, geotag_id, num_sounds, num_posts, has_avatar) 
    FROM stdin null as 'None';
    """
    out.write(sql_head)


    query = """SELECT
            user_id,
            user_website as home_page,
            user_sig as signature,
            (user_whitelist.userID is not null) as is_whitelisted,
            users.text as about,
            (email_ignore.userID is null) as wants_newsletter
        FROM phpbb_users
        LEFT JOIN user_whitelist on user_whitelist.userID=phpbb_users.user_id
        LEFT JOIN users on users.userID=phpbb_users.user_id
        LEFT JOIN email_ignore on email_ignore.userID=phpbb_users.user_id"""

    curs.execute(query)

    insert_id = 0
    while True:
        row = curs.fetchone()
        if not row:
            break
        new_row = transform_row(insert_id, row)
        if new_row:
            out.write( u"\t".join(new_row) + u"\n")
        insert_id += 1

    sql_tail = """\.

SELECT SETVAL('accounts_profile_id_seq',
    (SELECT MAX(id)+1 FROM accounts_profile));
VACUUM ANALYZE accounts_profile;
"""
    out.write(sql_tail)



def main():
    conn = MySQLdb.connect(**MYSQL_CONNECT)
    curs = conn.cursor(DEFAULT_CURSORCLASS)
    migrate_profiles(curs)

if __name__ == '__main__':
    main()