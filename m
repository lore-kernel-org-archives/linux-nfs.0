Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:49893 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756782Ab3BUS2q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:28:46 -0500
Received: by mail-qc0-f182.google.com with SMTP id k19so3740681qcs.13
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2013 10:28:46 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] nfsd: track memory utilization in the DRC
Date: Thu, 21 Feb 2013 13:28:35 -0500
Message-Id: <1361471318-17971-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
References: <1361471318-17971-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 8986568..efed50e 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -25,6 +25,7 @@ static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 static unsigned int		num_drc_entries;
 static unsigned int		max_drc_entries;
+static unsigned int		drc_mem_usage;
 static unsigned int		csum_misses;
 
 /*
@@ -101,11 +102,14 @@ nfsd_reply_cache_alloc(void)
 static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
-	if (rp->c_type == RC_REPLBUFF)
+	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
+		drc_mem_usage -= ksize(rp->c_replvec.iov_base);
 		kfree(rp->c_replvec.iov_base);
+	}
 	hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
+	drc_mem_usage -= ksize(rp);
 	kmem_cache_free(drc_slab, rp);
 }
 
@@ -367,6 +371,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		return RC_DOIT;
 	}
 	spin_lock(&cache_lock);
+	drc_mem_usage += ksize(rp);
 	++num_drc_entries;
 
 	/*
@@ -407,6 +412,7 @@ setup_entry:
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
+		drc_mem_usage -= ksize(rp->c_replvec.iov_base);
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
 	}
@@ -475,6 +481,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	struct svc_cacherep *rp = rqstp->rq_cacherep;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
+	size_t		replbufsize = 0;
 
 	if (!rp)
 		return;
@@ -501,6 +508,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 			nfsd_reply_cache_free(rp);
 			return;
 		}
+		replbufsize = ksize(cachv->iov_base);
 		cachv->iov_len = len << 2;
 		memcpy(cachv->iov_base, statp, len << 2);
 		break;
@@ -509,6 +517,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 		return;
 	}
 	spin_lock(&cache_lock);
+	drc_mem_usage += replbufsize;
 	lru_put_end(rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
-- 
1.7.11.7

