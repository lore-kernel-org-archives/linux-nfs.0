Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f45.google.com ([209.85.213.45]:46962 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3A1Tt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:49:27 -0500
Received: by mail-yh0-f45.google.com with SMTP id 24so475301yhr.32
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:49:26 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 10/16] nfsd: dynamically allocate DRC entries
Date: Mon, 28 Jan 2013 14:41:16 -0500
Message-Id: <1359402082-29195-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existing code keeps a fixed-size cache of 1024 entries. This is
much too small for a busy server, and wastes memory on an idle one.

This patch changes the code to dynamically allocate and free these
cache entries. For now, the cache growth is potentially boundless.
We'll add some mechanisms to help control that in later patches.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 83 +++++++++++++++++++++++-------------------------------
 1 file changed, 35 insertions(+), 48 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 9d80dfa..ad96f1d 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -14,13 +14,8 @@
 #include "nfsd.h"
 #include "cache.h"
 
-/* Size of reply cache. Common values are:
- * 4.3BSD:	128
- * 4.4BSD:	256
- * Solaris2:	1024
- * DEC Unix:	512-4096
- */
-#define CACHESIZE		1024
+#define NFSDDBG_FACILITY	NFSDDBG_REPCACHE
+
 #define HASHSIZE		64
 
 static struct hlist_head *	cache_hash;
@@ -67,34 +62,23 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF)
 		kfree(rp->c_replvec.iov_base);
+	hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	kmem_cache_free(drc_slab, rp);
 }
 
 int nfsd_reply_cache_init(void)
 {
-	int			i;
-	struct svc_cacherep	*rp;
-
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
 	if (!drc_slab)
 		goto out_nomem;
 
-	INIT_LIST_HEAD(&lru_head);
-	i = CACHESIZE;
-	while (i) {
-		rp = nfsd_reply_cache_alloc();
-		if (!rp)
-			goto out_nomem;
-		list_add(&rp->c_lru, &lru_head);
-		i--;
-	}
-
-	cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+	cache_hash = kcalloc(HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
 	if (!cache_hash)
 		goto out_nomem;
 
+	INIT_LIST_HEAD(&lru_head);
 	cache_disabled = 0;
 	return 0;
 out_nomem:
@@ -187,7 +171,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep	*rp, *found;
 	__be32			xid = rqstp->rq_xid;
 	u32			proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
@@ -206,38 +190,40 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rtn = RC_DOIT;
 
 	rp = nfsd_cache_search(rqstp);
-	if (rp) {
-		nfsdstats.rchits++;
+	if (rp)
 		goto found_entry;
-	}
-	nfsdstats.rcmisses++;
 
-	/* This loop shouldn't take more than a few iterations normally */
-	{
-	int	safe = 0;
-	list_for_each_entry(rp, &lru_head, c_lru) {
-		if (rp->c_state != RC_INPROG)
-			break;
-		if (safe++ > CACHESIZE) {
-			printk("nfsd: loop in repcache LRU list\n");
-			cache_disabled = 1;
-			goto out;
-		}
-	}
+	/*
+	 * Try to use the first entry on the LRU, if it's still good then we
+	 * know that the later ones will also be.
+	 */
+	if (!list_empty(&lru_head)) {
+		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
+		if (nfsd_cache_entry_expired(rp))
+			goto setup_entry;
 	}
 
-	/* All entries on the LRU are in-progress. This should not happen */
-	if (&rp->c_lru == &lru_head) {
-		static int	complaints;
+	spin_unlock(&cache_lock);
+	rp = nfsd_reply_cache_alloc();
+	if (!rp) {
+		dprintk("nfsd: unable to allocate DRC entry!\n");
+		return RC_DOIT;
+	}
+	spin_lock(&cache_lock);
 
-		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");
-		if (++complaints > 5) {
-			printk(KERN_WARNING "nfsd: disabling repcache.\n");
-			cache_disabled = 1;
-		}
-		goto out;
+	/*
+	 * Must search again just in case someone inserted one
+	 * after we dropped the lock above.
+	 */
+	found = nfsd_cache_search(rqstp);
+	if (found) {
+		nfsd_reply_cache_free_locked(rp);
+		rp = found;
+		goto found_entry;
 	}
 
+setup_entry:
+	nfsdstats.rcmisses++;
 	rqstp->rq_cacherep = rp;
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
@@ -261,6 +247,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	return rtn;
 
 found_entry:
+	nfsdstats.rchits++;
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
 	lru_put_end(rp);
@@ -291,7 +278,7 @@ found_entry:
 		break;
 	default:
 		printk(KERN_WARNING "nfsd: bad repcache type %d\n", rp->c_type);
-		rp->c_state = RC_UNUSED;
+		nfsd_reply_cache_free_locked(rp);
 	}
 
 	goto out;
-- 
1.7.11.7

