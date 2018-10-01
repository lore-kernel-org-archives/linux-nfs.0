Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:38772 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729528AbeJAVUl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:41 -0400
Received: by mail-it1-f194.google.com with SMTP id i76-v6so6171739ita.3
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:32 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 14/15] knfsd: Further simplify the cache lookup
Date: Mon,  1 Oct 2018 10:41:56 -0400
Message-Id: <20181001144157.3515-15-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-14-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
 <20181001144157.3515-7-trond.myklebust@hammerspace.com>
 <20181001144157.3515-8-trond.myklebust@hammerspace.com>
 <20181001144157.3515-9-trond.myklebust@hammerspace.com>
 <20181001144157.3515-10-trond.myklebust@hammerspace.com>
 <20181001144157.3515-11-trond.myklebust@hammerspace.com>
 <20181001144157.3515-12-trond.myklebust@hammerspace.com>
 <20181001144157.3515-13-trond.myklebust@hammerspace.com>
 <20181001144157.3515-14-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Order the structure so that the key can be compared using memcmp().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/cache.h    | 18 ++++++++++--------
 fs/nfsd/nfscache.c | 45 ++++++++++++++++-----------------------------
 2 files changed, 26 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index bd77d5f6fe53..cbcdc15753b7 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -19,18 +19,20 @@
  * is much larger than a sockaddr_in6.
  */
 struct svc_cacherep {
-	struct list_head	c_lru;
+	struct {
+		__be32			k_xid;
+		__wsum			k_csum;
+		u32			k_proc;
+		u32			k_prot;
+		u32			k_vers;
+		unsigned int		k_len;
+		struct sockaddr_in6	k_addr;
+	} c_key;
 
+	struct list_head	c_lru;
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
-	__be32			c_xid;
-	__wsum			c_csum;
-	u32			c_proc;
-	u32			c_prot;
-	u32			c_vers;
-	unsigned int		c_len;
-	struct sockaddr_in6	c_addr;
 	unsigned long		c_timestamp;
 	union {
 		struct kvec	u_vec;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 527ce4c65765..230cc83921ad 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -131,15 +131,15 @@ nfsd_reply_cache_alloc(struct svc_rqst *rqstp, __wsum csum)
 		rp->c_type = RC_NOCACHE;
 		INIT_LIST_HEAD(&rp->c_lru);
 
-		rp->c_xid = rqstp->rq_xid;
-		rp->c_proc = rqstp->rq_proc;
-		memset(&rp->c_addr, 0, sizeof(rp->c_addr));
-		rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
-		rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
-		rp->c_prot = rqstp->rq_prot;
-		rp->c_vers = rqstp->rq_vers;
-		rp->c_len = rqstp->rq_arg.len;
-		rp->c_csum = csum;
+		memset(&rp->c_key, 0, sizeof(rp->c_key));
+		rp->c_key.k_xid = rqstp->rq_xid;
+		rp->c_key.k_proc = rqstp->rq_proc;
+		rpc_copy_addr((struct sockaddr *)&rp->c_key.k_addr, svc_addr(rqstp));
+		rpc_set_port((struct sockaddr *)&rp->c_key.k_addr, rpc_get_port(svc_addr(rqstp)));
+		rp->c_key.k_prot = rqstp->rq_prot;
+		rp->c_key.k_vers = rqstp->rq_vers;
+		rp->c_key.k_len = rqstp->rq_arg.len;
+		rp->c_key.k_csum = csum;
 	}
 	return rp;
 }
@@ -330,27 +330,14 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
 	return csum;
 }
 
-static bool
-nfsd_cache_match(const struct svc_cacherep *key, const struct svc_cacherep *rp)
+static int
+nfsd_cache_key_cmp(const struct svc_cacherep *key, const struct svc_cacherep *rp)
 {
-	/* Check RPC XID first */
-	if (key->c_xid != rp->c_xid)
-		return false;
-	/* compare checksum of NFS data */
-	if (key->c_csum != rp->c_csum) {
+	if (key->c_key.k_xid == rp->c_key.k_xid &&
+	    key->c_key.k_csum != rp->c_key.k_csum)
 		++payload_misses;
-		return false;
-	}
-
-	/* Other discriminators */
-	if (key->c_proc != rp->c_proc ||
-	    key->c_prot != rp->c_prot ||
-	    key->c_vers != rp->c_vers ||
-	    key->c_len != rp->c_len ||
-	    memcmp(&key->c_addr, &rp->c_addr, sizeof(key->c_addr)) != 0)
-		return false;
 
-	return true;
+	return memcmp(&key->c_key, &rp->c_key, sizeof(key->c_key));
 }
 
 /*
@@ -367,7 +354,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct svc_cacherep *key)
 
 	list_for_each_entry(rp, rh, c_lru) {
 		++entries;
-		if (nfsd_cache_match(key, rp)) {
+		if (nfsd_cache_key_cmp(key, rp) == 0) {
 			ret = rp;
 			break;
 		}
@@ -510,7 +497,7 @@ nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, __be32 *statp)
 	if (!rp)
 		return;
 
-	hash = nfsd_cache_hash(rp->c_xid);
+	hash = nfsd_cache_hash(rp->c_key.k_xid);
 	b = &drc_hashtbl[hash];
 
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
-- 
2.17.1
