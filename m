Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33487 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbdBHByw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 20:54:52 -0500
Received: by mail-io0-f193.google.com with SMTP id 101so14607691iom.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 17:54:47 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/2 v3] SUNRPC: Drop all entries from cache_detail when
 cache_purge()
Message-ID: <99f0c881-f7bc-e548-8694-c68f11afde68@gmail.com>
Date: Wed, 8 Feb 2017 09:54:33 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

User always free the cache_detail after sunrpc_destroy_cache_detail(),
so, it must cleanup up entries that left in the cache_detail,
otherwise, NULL reference may be caused when using the left entries.

Also, NeriBrown suggests "write a stand-alone cache_purge()."

v3, move the cache_fresh_unlocked() out of write lock,
v2, a stand-alone cache_purge(), not only for sunrpc_destroy_cache_detail

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 41 ++++++++++++++++++++++++++---------------
 1 file changed, 26 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8147e8d..f0a7390 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -362,11 +362,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
 	write_lock(&cd->hash_lock);
-	if (cd->entries) {
-		write_unlock(&cd->hash_lock);
-		spin_unlock(&cache_list_lock);
-		goto out;
-	}
 	if (current_detail == cd)
 		current_detail = NULL;
 	list_del_init(&cd->others);
@@ -376,9 +371,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 		/* module must be being unloaded so its safe to kill the worker */
 		cancel_delayed_work_sync(&cache_cleaner);
 	}
-	return;
-out:
-	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
 }
 EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
 
@@ -497,13 +489,32 @@ EXPORT_SYMBOL_GPL(cache_flush);
 
 void cache_purge(struct cache_detail *detail)
 {
-	time_t now = seconds_since_boot();
-	if (detail->flush_time >= now)
-		now = detail->flush_time + 1;
-	/* 'now' is the maximum value any 'last_refresh' can have */
-	detail->flush_time = now;
-	detail->nextcheck = seconds_since_boot();
-	cache_flush();
+	struct cache_head *ch = NULL;
+	struct hlist_head *head = NULL;
+	struct hlist_node *tmp = NULL;
+	int i = 0;
+
+	write_lock(&detail->hash_lock);
+	if (!detail->entries) {
+		write_unlock(&detail->hash_lock);
+		return;
+	}
+
+	dprintk("RPC: %d entries in %s cache\n", detail->entries, detail->name);
+	for (i = 0; i < detail->hash_size; i++) {
+		head = &detail->hash_table[i];
+		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
+			hlist_del_init(&ch->cache_list);
+			detail->entries--;
+
+			set_bit(CACHE_CLEANED, &ch->flags);
+			write_unlock(&detail->hash_lock);
+			cache_fresh_unlocked(ch, detail);
+			cache_put(ch, detail);
+			write_lock(&detail->hash_lock);
+		}
+	}
+	write_unlock(&detail->hash_lock);
 }
 EXPORT_SYMBOL_GPL(cache_purge);
 
-- 
2.9.3

