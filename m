Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34090 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdBENl7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 08:41:59 -0500
Received: by mail-it0-f65.google.com with SMTP id o185so5949958itb.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 05:41:58 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] SUNRPC: Drop all entries left in cache_detail when destroy
Message-ID: <81c44c62-fa78-de51-faee-994f5592ff7b@gmail.com>
Date: Sun, 5 Feb 2017 21:40:57 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

User always free the cache_detail after sunrpc_destroy_cache_detail(),
so, it must cleanup up entries that left in the cache_detail,
otherwise, NULL reference may be caused when using the left entries.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8147e8d..a2c6fec 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -359,14 +359,28 @@ EXPORT_SYMBOL_GPL(sunrpc_init_cache_detail);
 
 void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 {
+	struct cache_head *ch = NULL;
+	struct hlist_head *head = NULL;
+	struct hlist_node *tmp = NULL;
+	int i = 0;
+
 	cache_purge(cd);
 	spin_lock(&cache_list_lock);
 	write_lock(&cd->hash_lock);
+
 	if (cd->entries) {
-		write_unlock(&cd->hash_lock);
-		spin_unlock(&cache_list_lock);
-		goto out;
+		printk(KERN_ERR "RPC: %d entries left in %s cache\n", cd->name);
+		for (i = 0; i < cd->hash_size; i++) {
+			head = &cd->hash_table[i];
+			hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
+				hlist_del_init(&ch->cache_list);
+				set_bit(CACHE_CLEANED, &ch->flags);
+				cache_fresh_unlocked(ch, cd);
+				cache_put(ch, cd);
+			}
+		}
 	}
+
 	if (current_detail == cd)
 		current_detail = NULL;
 	list_del_init(&cd->others);
@@ -376,9 +390,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
 		/* module must be being unloaded so its safe to kill the worker */
 		cancel_delayed_work_sync(&cache_cleaner);
 	}
-	return;
-out:
-	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
 }
 EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
 
-- 
2.9.3

