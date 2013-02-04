Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f175.google.com ([209.85.160.175]:36898 "EHLO
	mail-gh0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819Ab3BDNST (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 08:18:19 -0500
Received: by mail-gh0-f175.google.com with SMTP id g18so1506305ghb.20
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 05:18:18 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/8] nfsd: dynamically allocate DRC entries
Date: Mon,  4 Feb 2013 08:18:02 -0500
Message-Id: <1359983887-28535-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existing code keeps a fixed-size cache of 1024 entries. This is much
too small for a busy server, and wastes memory on an idle one.  This
patch changes the code to dynamically allocate and free these cache
entries.

A cap on the number of entries is retained, but it's much larger than
the existing value and now scales with the amount of low memory in the
machine.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 125 ++++++++++++++++++++++++++++++++---------------------
 1 file changed, 75 insertions(+), 50 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index c0c5847..d213e6e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -10,17 +10,13 @@
 
 #include <linux/slab.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/highmem.h>
 
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
@@ -28,6 +24,7 @@ static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
+static unsigned int		max_drc_entries;
 
 /*
  * Calculate the hash index from an XID.
@@ -48,6 +45,34 @@ static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
  */
 static DEFINE_SPINLOCK(cache_lock);
 
+/*
+ * Put a cap on the size of the DRC based on the amount of available
+ * low memory in the machine.
+ *
+ *  64MB:    8192
+ * 128MB:   11585
+ * 256MB:   16384
+ * 512MB:   23170
+ *   1GB:   32768
+ *   2GB:   46340
+ *   4GB:   65536
+ *   8GB:   92681
+ *  16GB:  131072
+ *
+ * ...with a hard cap of 256k entries. In the worst case, each entry will be
+ * ~1k, so the above numbers should give a rough max of the amount of memory
+ * used in k.
+ */
+static unsigned int
+nfsd_cache_size_limit(void)
+{
+	unsigned int limit;
+	unsigned long low_pages = totalram_pages - totalhigh_pages;
+
+	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
+	return min_t(unsigned int, limit, 256*1024);
+}
+
 static struct svc_cacherep *
 nfsd_reply_cache_alloc(void)
 {
@@ -68,6 +93,7 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF)
 		kfree(rp->c_replvec.iov_base);
+	hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
 	kmem_cache_free(drc_slab, rp);
@@ -75,30 +101,18 @@ nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 
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
-	num_drc_entries = 0;
-	while (i) {
-		rp = nfsd_reply_cache_alloc();
-		if (!rp)
-			goto out_nomem;
-		++num_drc_entries;
-		list_add(&rp->c_lru, &lru_head);
-		i--;
-	}
-
-	cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+	cache_hash = kcalloc(HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
 	if (!cache_hash)
 		goto out_nomem;
 
+	INIT_LIST_HEAD(&lru_head);
+	max_drc_entries = nfsd_cache_size_limit();
+	num_drc_entries = 0;
 	cache_disabled = 0;
 	return 0;
 out_nomem:
@@ -191,7 +205,7 @@ nfsd_cache_search(struct svc_rqst *rqstp)
 int
 nfsd_cache_lookup(struct svc_rqst *rqstp)
 {
-	struct svc_cacherep	*rp;
+	struct svc_cacherep	*rp, *found;
 	__be32			xid = rqstp->rq_xid;
 	u32			proto =  rqstp->rq_prot,
 				vers = rqstp->rq_vers,
@@ -210,38 +224,48 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rtn = RC_DOIT;
 
 	rp = nfsd_cache_search(rqstp);
-	if (rp) {
-		nfsdstats.rchits++;
+	if (rp)
 		goto found_entry;
+
+	/* Try to use the first entry on the LRU */
+	if (!list_empty(&lru_head)) {
+		rp = list_first_entry(&lru_head, struct svc_cacherep, c_lru);
+		if (nfsd_cache_entry_expired(rp) ||
+		    num_drc_entries >= max_drc_entries)
+			goto setup_entry;
 	}
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
+	spin_unlock(&cache_lock);
+	rp = nfsd_reply_cache_alloc();
+	if (!rp) {
+		dprintk("nfsd: unable to allocate DRC entry!\n");
+		return RC_DOIT;
 	}
+	spin_lock(&cache_lock);
+	++num_drc_entries;
+
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
 
-	/* All entries on the LRU are in-progress. This should not happen */
-	if (&rp->c_lru == &lru_head) {
-		static int	complaints;
-
-		printk(KERN_WARNING "nfsd: all repcache entries locked!\n");
-		if (++complaints > 5) {
-			printk(KERN_WARNING "nfsd: disabling repcache.\n");
-			cache_disabled = 1;
-		}
-		goto out;
-	}
+	/*
+	 * We're keeping the one we just allocated. Are we now over the
+	 * limit? Prune one off the tip of the LRU in trade for the one we
+	 * just allocated if so.
+	 */
+	if (num_drc_entries >= max_drc_entries)
+		nfsd_reply_cache_free_locked(list_first_entry(&lru_head,
+						struct svc_cacherep, c_lru));
 
+setup_entry:
+	nfsdstats.rcmisses++;
 	rqstp->rq_cacherep = rp;
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
@@ -265,6 +289,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	return rtn;
 
 found_entry:
+	nfsdstats.rchits++;
 	/* We found a matching entry which is either in progress or done. */
 	age = jiffies - rp->c_timestamp;
 	lru_put_end(rp);
@@ -295,7 +320,7 @@ found_entry:
 		break;
 	default:
 		printk(KERN_WARNING "nfsd: bad repcache type %d\n", rp->c_type);
-		rp->c_state = RC_UNUSED;
+		nfsd_reply_cache_free_locked(rp);
 	}
 
 	goto out;
-- 
1.7.11.7

