Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f42.google.com ([209.85.213.42]:56744 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1Tlo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:41:44 -0500
Received: by mail-yh0-f42.google.com with SMTP id w49so470035yhw.29
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:41:43 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 04/16] nfsd: create a dedicated slabcache for DRC entries
Date: Mon, 28 Jan 2013 14:41:10 -0500
Message-Id: <1359402082-29195-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we use kmalloc() which wastes a little bit of memory on each
allocation since it's a power of 2 allocator. Since we're allocating a
1024 of these now, and may need even more later, let's create a new
slabcache for them.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 972c14a..4aad9e4 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -26,6 +26,7 @@
 static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static int			cache_disabled = 1;
+static struct kmem_cache	*drc_slab;
 
 /*
  * Calculate the hash index from an XID.
@@ -51,10 +52,15 @@ int nfsd_reply_cache_init(void)
 	struct svc_cacherep	*rp;
 	int			i;
 
+	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
+					0, 0, NULL);
+	if (!drc_slab)
+		goto out_nomem;
+
 	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
 	while (i) {
-		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
+		rp = kmem_cache_alloc(drc_slab, GFP_KERNEL);
 		if (!rp)
 			goto out_nomem;
 		list_add(&rp->c_lru, &lru_head);
@@ -85,13 +91,18 @@ void nfsd_reply_cache_shutdown(void)
 		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
 			kfree(rp->c_replvec.iov_base);
 		list_del(&rp->c_lru);
-		kfree(rp);
+		kmem_cache_free(drc_slab, rp);
 	}
 
 	cache_disabled = 1;
 
 	kfree (cache_hash);
 	cache_hash = NULL;
+
+	if (drc_slab) {
+		kmem_cache_destroy(drc_slab);
+		drc_slab = NULL;
+	}
 }
 
 /*
-- 
1.7.11.7

