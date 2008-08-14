From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] knfsd: allocate readahead cache in individual chunks
Date: Wed, 13 Aug 2008 22:03:27 -0400
Message-ID: <1218679407-11364-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbYHNCD2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 22:03:28 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m7E23RZG022143
	for <linux-nfs@vger.kernel.org>; Wed, 13 Aug 2008 22:03:27 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m7E23RPX001971
	for <linux-nfs@vger.kernel.org>; Wed, 13 Aug 2008 22:03:27 -0400
Received: from dantu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m7E23RWg028693
	for <linux-nfs@vger.kernel.org>; Wed, 13 Aug 2008 22:03:27 -0400
Received: from dantu.usersys.redhat.com ([127.0.0.1])
	by dantu.redhat.com (8.13.8/8.13.8) with ESMTP id m7E23Rbg011385
	for <linux-nfs@vger.kernel.org>; Wed, 13 Aug 2008 22:03:27 -0400
Received: (from jlayton@localhost)
	by dantu.usersys.redhat.com (8.13.8/8.13.8/Submit) id m7E23RUA011384
	for linux-nfs@vger.kernel.org; Wed, 13 Aug 2008 22:03:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I had a report from someone building a large NFS server that they were
unable to start more than 585 nfsd threads. It was reported against an
older kernel using the slab allocator, and I tracked it down to the
large allocation in nfsd_racache_init failing.

It appears that the slub allocator handles large allocations better,
but large contiguous allocations can often be problematic. There
doesn't seem to be any reason that the racache has to be allocated as a
single large chunk. This patch breaks this up so that the racache is
built up from separate allocations.

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |   49 ++++++++++++++++++++++++++++++++-----------------
 1 files changed, 32 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1319e80..8bdf46f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -83,11 +83,11 @@ struct raparm_hbucket {
 	spinlock_t		pb_lock;
 } ____cacheline_aligned_in_smp;
 
-static struct raparms *		raparml;
 #define RAPARM_HASH_BITS	4
 #define RAPARM_HASH_SIZE	(1<<RAPARM_HASH_BITS)
 #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
 static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
+static unsigned int		raparm_hash_buckets;
 
 /* 
  * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
@@ -1966,11 +1966,20 @@ nfsd_permission(struct svc_rqst *rqstp, struct svc_export *exp,
 void
 nfsd_racache_shutdown(void)
 {
-	if (!raparml)
-		return;
+	struct raparms *raparm, *last_raparm;
+	unsigned int i;
+
 	dprintk("nfsd: freeing readahead buffers.\n");
-	kfree(raparml);
-	raparml = NULL;
+
+	for (i = 0; i < raparm_hash_buckets; i++) {
+		raparm = raparm_hash[i].pb_head;
+		while(raparm) {
+			last_raparm = raparm;
+			raparm = raparm->p_next;
+			kfree(last_raparm);
+		}
+		raparm_hash[i].pb_head = NULL;
+	}
 }
 /*
  * Initialize readahead param cache
@@ -1981,35 +1990,41 @@ nfsd_racache_init(int cache_size)
 	int	i;
 	int	j = 0;
 	int	nperbucket;
+	struct raparms *raparm, *last_raparm = NULL;
 
 
-	if (raparml)
+	if (raparm_hash[0].pb_head)
 		return 0;
 	if (cache_size < 2*RAPARM_HASH_SIZE)
 		cache_size = 2*RAPARM_HASH_SIZE;
-	raparml = kcalloc(cache_size, sizeof(struct raparms), GFP_KERNEL);
-
-	if (!raparml) {
-		printk(KERN_WARNING
-			"nfsd: Could not allocate memory read-ahead cache.\n");
-		return -ENOMEM;
-	}
 
 	dprintk("nfsd: allocating %d readahead buffers.\n", cache_size);
 	for (i = 0 ; i < RAPARM_HASH_SIZE ; i++) {
 		raparm_hash[i].pb_head = NULL;
 		spin_lock_init(&raparm_hash[i].pb_lock);
 	}
+
 	nperbucket = DIV_ROUND_UP(cache_size, RAPARM_HASH_SIZE);
-	for (i = 0; i < cache_size - 1; i++) {
+	for (i = 0; i < cache_size; i++) {
+		raparm = kzalloc(sizeof(*raparm), GFP_KERNEL);
+		if (!raparm)
+			goto out_nomem;
+
 		if (i % nperbucket == 0)
-			raparm_hash[j++].pb_head = raparml + i;
-		if (i % nperbucket < nperbucket-1)
-			raparml[i].p_next = raparml + i + 1;
+			raparm_hash[j++].pb_head = raparm;
+		else
+			last_raparm->p_next = raparm;
+		last_raparm = raparm;
 	}
 
 	nfsdstats.ra_size = cache_size;
+	raparm_hash_buckets = j;
 	return 0;
+
+out_nomem:
+	dprintk("nfsd: kmalloc failed, freeing readahead buffers\n");
+	nfsd_racache_shutdown();
+	return -ENOMEM;
 }
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-- 
1.5.5.1

