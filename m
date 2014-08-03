Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34973 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbaHCRGH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:06:07 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so7674653qge.38
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:06:07 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] nfsd: Clean up drc cache in preparation for global spinlock elimination
Date: Sun,  3 Aug 2014 13:05:59 -0400
Message-Id: <1407085564-3227-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
References: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfscache.c | 38 +++++++++++++++++++++++++-------------
 1 file changed, 25 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 6040da8830ff..c9e25bc7ea56 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -27,7 +27,11 @@
  */
 #define TARGET_BUCKET_SIZE	64
 
-static struct hlist_head *	cache_hash;
+struct nfsd_drc_bucket {
+	struct hlist_head cache_hash;
+};
+
+static struct nfsd_drc_bucket	*drc_hashtbl;
 static struct list_head 	lru_head;
 static struct kmem_cache	*drc_slab;
 
@@ -116,6 +120,12 @@ nfsd_hashsize(unsigned int limit)
 	return roundup_pow_of_two(limit / TARGET_BUCKET_SIZE);
 }
 
+static u32
+nfsd_cache_hash(__be32 xid)
+{
+	return hash_32(be32_to_cpu(xid), maskbits);
+}
+
 static struct svc_cacherep *
 nfsd_reply_cache_alloc(void)
 {
@@ -170,8 +180,8 @@ int nfsd_reply_cache_init(void)
 	if (!drc_slab)
 		goto out_nomem;
 
-	cache_hash = kcalloc(hashsize, sizeof(struct hlist_head), GFP_KERNEL);
-	if (!cache_hash)
+	drc_hashtbl = kcalloc(hashsize, sizeof(*drc_hashtbl), GFP_KERNEL);
+	if (!drc_hashtbl)
 		goto out_nomem;
 
 	return 0;
@@ -193,8 +203,8 @@ void nfsd_reply_cache_shutdown(void)
 		nfsd_reply_cache_free_locked(rp);
 	}
 
-	kfree (cache_hash);
-	cache_hash = NULL;
+	kfree (drc_hashtbl);
+	drc_hashtbl = NULL;
 
 	if (drc_slab) {
 		kmem_cache_destroy(drc_slab);
@@ -218,10 +228,10 @@ lru_put_end(struct svc_cacherep *rp)
  * Move a cache entry from one hash list to another
  */
 static void
-hash_refile(struct svc_cacherep *rp)
+hash_refile(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
-	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, cache_hash + hash_32(rp->c_xid, maskbits));
+	hlist_del(&rp->c_hash);
+	hlist_add_head(&rp->c_hash, &b->cache_hash);
 }
 
 /*
@@ -350,13 +360,13 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
  * NULL on failure.
  */
 static struct svc_cacherep *
-nfsd_cache_search(struct svc_rqst *rqstp, __wsum csum)
+nfsd_cache_search(struct nfsd_drc_bucket *b, struct svc_rqst *rqstp,
+		__wsum csum)
 {
 	struct svc_cacherep	*rp, *ret = NULL;
-	struct hlist_head 	*rh;
+	struct hlist_head 	*rh = &b->cache_hash;
 	unsigned int		entries = 0;
 
-	rh = &cache_hash[hash_32(rqstp->rq_xid, maskbits)];
 	hlist_for_each_entry(rp, rh, c_hash) {
 		++entries;
 		if (nfsd_cache_match(rqstp, csum, rp)) {
@@ -394,6 +404,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 				vers = rqstp->rq_vers,
 				proc = rqstp->rq_proc;
 	__wsum			csum;
+	u32 hash = nfsd_cache_hash(xid);
+	struct nfsd_drc_bucket *b = &drc_hashtbl[hash];
 	unsigned long		age;
 	int type = rqstp->rq_cachetype;
 	int rtn = RC_DOIT;
@@ -420,7 +432,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	/* go ahead and prune the cache */
 	prune_cache_entries();
 
-	found = nfsd_cache_search(rqstp, csum);
+	found = nfsd_cache_search(b, rqstp, csum);
 	if (found) {
 		if (likely(rp))
 			nfsd_reply_cache_free_locked(rp);
@@ -445,7 +457,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp->c_len = rqstp->rq_arg.len;
 	rp->c_csum = csum;
 
-	hash_refile(rp);
+	hash_refile(b, rp);
 	lru_put_end(rp);
 
 	/* release any buffer */
-- 
1.9.3

