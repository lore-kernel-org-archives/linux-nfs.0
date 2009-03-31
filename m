From: Greg Banks <gnb@sgi.com>
Subject: [patch 13/29] knfsd: reply cache cleanups
Date: Wed, 01 Apr 2009 07:28:13 +1100
Message-ID: <20090331202942.512383000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22582 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762267AbZCaVCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:44 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make REQHASH() an inline function.  Rename hash_list to cache_hash.
Fix an obsolete comment.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 fs/nfsd/nfscache.c         |   29 +++++++++++++++++++----------
 include/linux/nfsd/cache.h |    3 +--
 2 files changed, 20 insertions(+), 12 deletions(-)

Index: bfields/fs/nfsd/nfscache.c
===================================================================
--- bfields.orig/fs/nfsd/nfscache.c
+++ bfields/fs/nfsd/nfscache.c
@@ -29,15 +29,24 @@
  */
 #define CACHESIZE		1024
 #define HASHSIZE		64
-#define REQHASH(xid)		(((((__force __u32)xid) >> 24) ^ ((__force __u32)xid)) & (HASHSIZE-1))
 
-static struct hlist_head *	hash_list;
+static struct hlist_head *	cache_hash;
 static struct list_head 	lru_head;
 static int			cache_disabled = 1;
 
+/*
+ * Calculate the hash index from an XID.
+ */
+static inline u32 request_hash(u32 xid)
+{
+	u32 h = xid;
+	h ^= (xid >> 24);
+	return h & (HASHSIZE-1);
+}
+
 static int	nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *vec);
 
-/* 
+/*
  * locking for the reply cache:
  * A cache entry is "single use" if c_state == RC_INPROG
  * Otherwise, it when accessing _prev or _next, the lock must be held.
@@ -62,8 +71,8 @@ int nfsd_reply_cache_init(void)
 		i--;
 	}
 
-	hash_list = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
-	if (!hash_list)
+	cache_hash = kcalloc (HASHSIZE, sizeof(struct hlist_head), GFP_KERNEL);
+	if (!cache_hash)
 		goto out_nomem;
 
 	cache_disabled = 0;
@@ -88,8 +97,8 @@ void nfsd_reply_cache_shutdown(void)
 
 	cache_disabled = 1;
 
-	kfree (hash_list);
-	hash_list = NULL;
+	kfree (cache_hash);
+	cache_hash = NULL;
 }
 
 /*
@@ -108,7 +117,7 @@ static void
 hash_refile(struct svc_cacherep *rp)
 {
 	hlist_del_init(&rp->c_hash);
-	hlist_add_head(&rp->c_hash, hash_list + REQHASH(rp->c_xid));
+	hlist_add_head(&rp->c_hash, cache_hash + request_hash(rp->c_xid));
 }
 
 /*
@@ -138,7 +147,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	spin_lock(&cache_lock);
 	rtn = RC_DOIT;
 
-	rh = &hash_list[REQHASH(xid)];
+	rh = &cache_hash[request_hash(xid)];
 	hlist_for_each_entry(rp, hn, rh, c_hash) {
 		if (rp->c_state != RC_UNUSED &&
 		    xid == rp->c_xid && proc == rp->c_proc &&
@@ -264,7 +273,7 @@ nfsd_cache_update(struct svc_rqst *rqstp
 
 	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
 	len >>= 2;
-	
+
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
 		rp->c_state = RC_UNUSED;
Index: bfields/include/linux/nfsd/cache.h
===================================================================
--- bfields.orig/include/linux/nfsd/cache.h
+++ bfields/include/linux/nfsd/cache.h
@@ -14,8 +14,7 @@
 #include <linux/uio.h>
 
 /*
- * Representation of a reply cache entry. The first two members *must*
- * be hash_next and hash_prev.
+ * Representation of a reply cache entry.
  */
 struct svc_cacherep {
 	struct hlist_node	c_hash;

--
Greg
