Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f50.google.com ([209.85.212.50]:46627 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758711Ab3CDS4u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 13:56:50 -0500
Received: by mail-vb0-f50.google.com with SMTP id ft2so1004882vbb.9
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2013 10:56:49 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] nfsd: track memory utilization in the DRC
Date: Mon,  4 Mar 2013 13:56:37 -0500
Message-Id: <1362423400-24380-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
References: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 3fba32f..bcbbe6b 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -38,6 +38,9 @@ static unsigned int		max_drc_entries;
 /* cache misses due only to checksum comparison failures */
 static unsigned int		payload_misses;
 
+/* amount of memory (in bytes) currently consumed by the DRC */
+static unsigned int		drc_mem_usage;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -112,11 +115,14 @@ nfsd_reply_cache_alloc(void)
 static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
-	if (rp->c_type == RC_REPLBUFF)
+	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
+		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
+	}
 	hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
+	drc_mem_usage -= sizeof(*rp);
 	kmem_cache_free(drc_slab, rp);
 }
 
@@ -377,6 +383,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		return RC_DOIT;
 	}
 	spin_lock(&cache_lock);
+	drc_mem_usage += sizeof(*rp);
 	++num_drc_entries;
 
 	/*
@@ -417,6 +424,7 @@ setup_entry:
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
+		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
 	}
@@ -485,6 +493,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	struct svc_cacherep *rp = rqstp->rq_cacherep;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
+	size_t		bufsize = 0;
 
 	if (!rp)
 		return;
@@ -506,19 +515,21 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 		break;
 	case RC_REPLBUFF:
 		cachv = &rp->c_replvec;
-		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
+		bufsize = len << 2;
+		cachv->iov_base = kmalloc(bufsize, GFP_KERNEL);
 		if (!cachv->iov_base) {
 			nfsd_reply_cache_free(rp);
 			return;
 		}
-		cachv->iov_len = len << 2;
-		memcpy(cachv->iov_base, statp, len << 2);
+		cachv->iov_len = bufsize;
+		memcpy(cachv->iov_base, statp, bufsize);
 		break;
 	case RC_NOCACHE:
 		nfsd_reply_cache_free(rp);
 		return;
 	}
 	spin_lock(&cache_lock);
+	drc_mem_usage += bufsize;
 	lru_put_end(rp);
 	rp->c_secure = rqstp->rq_secure;
 	rp->c_type = cachetype;
-- 
1.7.11.7

