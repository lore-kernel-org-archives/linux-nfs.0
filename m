Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35774 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbG0DKy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:10:54 -0400
Message-ID: <55B5A135.9050800@gmail.com>
Date: Mon, 27 Jul 2015 11:10:45 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 8/9 v8] sunrpc: New helper cache_delete_entry for deleting
 cache_head directly
References: <55B5A012.1030006@gmail.com>
In-Reply-To: <55B5A012.1030006@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new helper cache_delete_entry() for delete cache_head from
cache_detail directly.

It will be used by pin_kill, so make sure the cache_detail is valid
before deleting is needed.

Because pin_kill is not many times, so the influence of performance
is accepted.

v8, same as v6.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h |  1 +
 net/sunrpc/cache.c           | 30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

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
index 4a2340a..b722aea 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -454,6 +454,36 @@ static int cache_clean(void)
 	return rv;
 }
 
+void cache_delete_entry(struct cache_detail *detail, struct cache_head *h)
+{
+	struct cache_detail *tmp;
+
+	if (!detail || !h)
+		return;
+
+	spin_lock(&cache_list_lock);
+	list_for_each_entry(tmp, &cache_list, others) {
+		if (tmp == detail)
+			goto found;
+	}
+	spin_unlock(&cache_list_lock);
+	printk(KERN_WARNING "%s: Deleted cache detail %p\n", __func__, detail);
+	return ;
+
+found:
+	write_lock(&detail->hash_lock);
+
+	hlist_del_init(&h->cache_list);
+	detail->entries--;
+	set_bit(CACHE_CLEANED, &h->flags);
+
+	write_unlock(&detail->hash_lock);
+	spin_unlock(&cache_list_lock);
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

