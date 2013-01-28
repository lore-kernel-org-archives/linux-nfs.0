Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f169.google.com ([209.85.213.169]:39291 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3A1TtX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:49:23 -0500
Received: by mail-ye0-f169.google.com with SMTP id l13so471207yen.28
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:49:22 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 05/16] nfsd: add alloc and free functions for DRC entries
Date: Mon, 28 Jan 2013 14:41:11 -0500
Message-Id: <1359402082-29195-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4aad9e4..363bc61 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -47,10 +47,34 @@ static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
  */
 static DEFINE_SPINLOCK(cache_lock);
 
-int nfsd_reply_cache_init(void)
+static struct svc_cacherep *
+nfsd_reply_cache_alloc(void)
 {
 	struct svc_cacherep	*rp;
+
+	rp = kmem_cache_alloc(drc_slab, GFP_KERNEL);
+	if (rp) {
+		rp->c_state = RC_UNUSED;
+		rp->c_type = RC_NOCACHE;
+		INIT_LIST_HEAD(&rp->c_lru);
+		INIT_HLIST_NODE(&rp->c_hash);
+	}
+	return rp;
+}
+
+static void
+nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
+{
+	if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
+		kfree(rp->c_replvec.iov_base);
+	list_del(&rp->c_lru);
+	kmem_cache_free(drc_slab, rp);
+}
+
+int nfsd_reply_cache_init(void)
+{
 	int			i;
+	struct svc_cacherep	*rp;
 
 	drc_slab = kmem_cache_create("nfsd_drc", sizeof(struct svc_cacherep),
 					0, 0, NULL);
@@ -60,13 +84,10 @@ int nfsd_reply_cache_init(void)
 	INIT_LIST_HEAD(&lru_head);
 	i = CACHESIZE;
 	while (i) {
-		rp = kmem_cache_alloc(drc_slab, GFP_KERNEL);
+		rp = nfsd_reply_cache_alloc();
 		if (!rp)
 			goto out_nomem;
 		list_add(&rp->c_lru, &lru_head);
-		rp->c_state = RC_UNUSED;
-		rp->c_type = RC_NOCACHE;
-		INIT_HLIST_NODE(&rp->c_hash);
 		i--;
 	}
 
@@ -88,10 +109,7 @@ void nfsd_reply_cache_shutdown(void)
 
 	while (!list_empty(&lru_head)) {
 		rp = list_entry(lru_head.next, struct svc_cacherep, c_lru);
-		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
-			kfree(rp->c_replvec.iov_base);
-		list_del(&rp->c_lru);
-		kmem_cache_free(drc_slab, rp);
+		nfsd_reply_cache_free_locked(rp);
 	}
 
 	cache_disabled = 1;
-- 
1.7.11.7

