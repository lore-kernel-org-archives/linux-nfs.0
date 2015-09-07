Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33854 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbIGOFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Sep 2015 10:05:46 -0400
Subject: [PATCH 5/6 v10] sunrpc: New helper cache_delete_entry for deleting
 cache_head directly
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
References: <55ED9899.9010401@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55ED99AF.4030409@gmail.com>
Date: Mon, 7 Sep 2015 22:05:35 +0800
MIME-Version: 1.0
In-Reply-To: <55ED9899.9010401@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new helper cache_delete_entry() for delete cache_head from
cache_detail directly.

It will be used by pin_kill, so make sure the cache_detail is valid
before deleting is needed.

Because pin_kill is not many times, so the influence of performance
is accepted.

v9, delete duplicate checking of cache_detail
v10, same as v9

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h |  1 +
 net/sunrpc/cache.c           | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 03d3b4c..2824db5 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -210,6 +210,7 @@ extern int cache_check(struct cache_detail *detail,
 		       struct cache_head *h, struct cache_req *rqstp);
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
+extern void cache_delete_entry(struct cache_detail *cd, struct cache_head *h);
 #define NEVER (0x7FFFFFFF)
 extern void __init cache_initialize(void);
 extern int cache_register_net(struct cache_detail *cd, struct net *net);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 4a2340a..430b5fa 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -454,6 +454,26 @@ static int cache_clean(void)
 	return rv;
 }
 
+void cache_delete_entry(struct cache_detail *detail, struct cache_head *h)
+{
+	if (!detail || !h)
+		return;
+
+	write_lock(&detail->hash_lock);
+	if (hlist_unhashed(&h->cache_list)) {
+		write_unlock(&detail->hash_lock);
+		return ;
+	}
+
+	hlist_del_init(&h->cache_list);
+	detail->entries--;
+	set_bit(CACHE_CLEANED, &h->flags);
+	write_unlock(&detail->hash_lock);
+
+	cache_put(h, detail);
+}
+EXPORT_SYMBOL_GPL(cache_delete_entry);
+
 /*
  * We want to regularly clean the cache, so we need to schedule some work ...
  */
-- 
2.4.3

