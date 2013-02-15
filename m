Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f173.google.com ([209.85.213.173]:49319 "EHLO
	mail-ye0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab3BORXU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 12:23:20 -0500
Received: by mail-ye0-f173.google.com with SMTP id l5so595370yen.18
        for <linux-nfs@vger.kernel.org>; Fri, 15 Feb 2013 09:23:17 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] nfsd: track memory utilization in the DRC
Date: Fri, 15 Feb 2013 12:23:09 -0500
Message-Id: <1360948990-2265-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1360948990-2265-1-git-send-email-jlayton@redhat.com>
References: <1360948990-2265-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index c00c5bc..ad1d069 100644
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

