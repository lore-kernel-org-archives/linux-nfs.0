Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f47.google.com ([209.85.219.47]:38271 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078Ab3CSNLz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 09:11:55 -0400
Received: by mail-oa0-f47.google.com with SMTP id o17so421793oag.34
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 06:11:55 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] nfsd: track memory utilization by the DRC
Date: Tue, 19 Mar 2013 09:11:43 -0400
Message-Id: <1363698706-22036-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
References: <1363698706-22036-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfscache.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 48f5ef9..1f45b33 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -38,6 +38,9 @@ static unsigned int		num_drc_entries;
 /* cache misses due only to checksum comparison failures */
 static unsigned int		payload_misses;
 
+/* amount of memory (in bytes) currently consumed by the DRC */
+static unsigned int		drc_mem_usage;
+
 /*
  * Calculate the hash index from an XID.
  */
@@ -112,12 +115,15 @@ nfsd_reply_cache_alloc(void)
 static void
 nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
 {
-	if (rp->c_type == RC_REPLBUFF)
+	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
+		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
+	}
 	if (!hlist_unhashed(&rp->c_hash))
 		hlist_del(&rp->c_hash);
 	list_del(&rp->c_lru);
 	--num_drc_entries;
+	drc_mem_usage -= sizeof(*rp);
 	kmem_cache_free(drc_slab, rp);
 }
 
@@ -372,8 +378,10 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	spin_unlock(&cache_lock);
 	rp = nfsd_reply_cache_alloc();
 	spin_lock(&cache_lock);
-	if (likely(rp))
+	if (likely(rp)) {
 		++num_drc_entries;
+		drc_mem_usage += sizeof(*rp);
+	}
 
 search_cache:
 	found = nfsd_cache_search(rqstp, csum);
@@ -415,6 +423,7 @@ search_cache:
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
+		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
 		rp->c_replvec.iov_base = NULL;
 	}
@@ -483,6 +492,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	struct svc_cacherep *rp = rqstp->rq_cacherep;
 	struct kvec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
+	size_t		bufsize = 0;
 
 	if (!rp)
 		return;
@@ -504,19 +514,21 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
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

