Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32945 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbGKMvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 08:51:25 -0400
Message-ID: <55A11141.3050806@gmail.com>
Date: Sat, 11 Jul 2015 20:51:13 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 08/10 v7] sunrpc: New helper cache_delete_entry for deleting
 cache_head directly
References: <55A11010.6050005@gmail.com>
In-Reply-To: <55A11010.6050005@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A new helper cache_delete_entry() for delete cache_head from
cache_detail directly.

It will be used by pin_kill, so make sure the cache_detail is valid
before deleting is needed.

Because pin_kill is not many times, so the influence of performance
is accepted.

v7, same as v6.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/cache.h |  1 +
 net/sunrpc/cache.c           | 30 ++++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index ecc0ff6..5a4b921 100644
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
index ad2155c..8a27483 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -458,6 +458,36 @@ static int cache_clean(void)
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
+	list_del_init(&h->cache_list);
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

