Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33453 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab2LQPCm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2012 10:02:42 -0500
From: Sasha Levin <sasha.levin@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 08/15] SUNRPC/cache: use new hashtable implementation
Date: Mon, 17 Dec 2012 10:01:28 -0500
Message-Id: <1355756497-15834-8-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com>
References: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Switch cache to use the new hashtable implementation. This reduces the amount
of generic unrelated code in the cache implementation.

This patch depends on d9b482c ("hashtable: introduce a small and naive
hashtable") which was merged in v3.6.

Tested-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 net/sunrpc/cache.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..d4539b6 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,6 +28,7 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
+#include <linux/hashtable.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -524,19 +525,18 @@ EXPORT_SYMBOL_GPL(cache_purge);
  * it to be revisited when cache info is available
  */
 
-#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
-#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
+#define	DFR_HASH_BITS	9
 
 #define	DFR_MAX	300	/* ??? */
 
 static DEFINE_SPINLOCK(cache_defer_lock);
 static LIST_HEAD(cache_defer_list);
-static struct hlist_head cache_defer_hash[DFR_HASHSIZE];
+static DEFINE_HASHTABLE(cache_defer_hash, DFR_HASH_BITS);
 static int cache_defer_cnt;
 
 static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 {
-	hlist_del_init(&dreq->hash);
+	hash_del(&dreq->hash);
 	if (!list_empty(&dreq->recent)) {
 		list_del_init(&dreq->recent);
 		cache_defer_cnt--;
@@ -545,10 +545,7 @@ static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 
 static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_head *item)
 {
-	int hash = DFR_HASH(item);
-
-	INIT_LIST_HEAD(&dreq->recent);
-	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
+	hash_add(cache_defer_hash, &dreq->hash, (unsigned long)item);
 }
 
 static void setup_deferral(struct cache_deferred_req *dreq,
@@ -600,7 +597,7 @@ static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 		 * to clean up
 		 */
 		spin_lock(&cache_defer_lock);
-		if (!hlist_unhashed(&sleeper.handle.hash)) {
+		if (hash_hashed(&sleeper.handle.hash)) {
 			__unhash_deferred_req(&sleeper.handle);
 			spin_unlock(&cache_defer_lock);
 		} else {
@@ -671,12 +668,11 @@ static void cache_revisit_request(struct cache_head *item)
 	struct cache_deferred_req *dreq;
 	struct list_head pending;
 	struct hlist_node *lp, *tmp;
-	int hash = DFR_HASH(item);
 
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
 
-	hlist_for_each_entry_safe(dreq, lp, tmp, &cache_defer_hash[hash], hash)
+	hash_for_each_possible_safe(cache_defer_hash, dreq, lp, tmp, hash, (unsigned long)item)
 		if (dreq->item == item) {
 			__unhash_deferred_req(dreq);
 			list_add(&dreq->recent, &pending);
-- 
1.8.0

