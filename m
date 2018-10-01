Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f195.google.com ([209.85.166.195]:35002 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729497AbeJAVUm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:42 -0400
Received: by mail-it1-f195.google.com with SMTP id p64-v6so4681425itp.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:33 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 15/15] knfsd: Improve lookup performance in the duplicate reply cache using an rbtree
Date: Mon,  1 Oct 2018 10:41:57 -0400
Message-Id: <20181001144157.3515-16-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-15-trond.myklebust@hammerspace.com>
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
 <20181001144157.3515-15-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use an rbtree to ensure the lookup/insert of an entry in a DRC bucket is
O(log(N)).

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/cache.h    |  1 +
 fs/nfsd/nfscache.c | 37 ++++++++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index cbcdc15753b7..ef1c8aa89ca4 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -29,6 +29,7 @@ struct svc_cacherep {
 		struct sockaddr_in6	k_addr;
 	} c_key;
 
+	struct rb_node		c_node;
 	struct list_head	c_lru;
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 230cc83921ad..e2fe0e9ce0df 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -30,6 +30,7 @@
 #define TARGET_BUCKET_SIZE	64
 
 struct nfsd_drc_bucket {
+	struct rb_root rb_head;
 	struct list_head lru_head;
 	spinlock_t cache_lock;
 };
@@ -129,6 +130,7 @@ nfsd_reply_cache_alloc(struct svc_rqst *rqstp, __wsum csum)
 	if (rp) {
 		rp->c_state = RC_UNUSED;
 		rp->c_type = RC_NOCACHE;
+		RB_CLEAR_NODE(&rp->c_node);
 		INIT_LIST_HEAD(&rp->c_lru);
 
 		memset(&rp->c_key, 0, sizeof(rp->c_key));
@@ -145,13 +147,14 @@ nfsd_reply_cache_alloc(struct svc_rqst *rqstp, __wsum csum)
 }
 
 static void
-nfsd_reply_cache_free_locked(struct svc_cacherep *rp)
+nfsd_reply_cache_free_locked(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
 	if (rp->c_type == RC_REPLBUFF && rp->c_replvec.iov_base) {
 		drc_mem_usage -= rp->c_replvec.iov_len;
 		kfree(rp->c_replvec.iov_base);
 	}
 	if (rp->c_state != RC_UNUSED) {
+		rb_erase(&rp->c_node, &b->rb_head);
 		list_del(&rp->c_lru);
 		atomic_dec(&num_drc_entries);
 		drc_mem_usage -= sizeof(*rp);
@@ -163,7 +166,7 @@ static void
 nfsd_reply_cache_free(struct nfsd_drc_bucket *b, struct svc_cacherep *rp)
 {
 	spin_lock(&b->cache_lock);
-	nfsd_reply_cache_free_locked(rp);
+	nfsd_reply_cache_free_locked(b, rp);
 	spin_unlock(&b->cache_lock);
 }
 
@@ -219,7 +222,7 @@ void nfsd_reply_cache_shutdown(void)
 		struct list_head *head = &drc_hashtbl[i].lru_head;
 		while (!list_empty(head)) {
 			rp = list_first_entry(head, struct svc_cacherep, c_lru);
-			nfsd_reply_cache_free_locked(rp);
+			nfsd_reply_cache_free_locked(&drc_hashtbl[i], rp);
 		}
 	}
 
@@ -258,7 +261,7 @@ prune_bucket(struct nfsd_drc_bucket *b)
 		if (atomic_read(&num_drc_entries) <= max_drc_entries &&
 		    time_before(jiffies, rp->c_timestamp + RC_EXPIRE))
 			break;
-		nfsd_reply_cache_free_locked(rp);
+		nfsd_reply_cache_free_locked(b, rp);
 		freed++;
 	}
 	return freed;
@@ -349,17 +352,29 @@ static struct svc_cacherep *
 nfsd_cache_insert(struct nfsd_drc_bucket *b, struct svc_cacherep *key)
 {
 	struct svc_cacherep	*rp, *ret = key;
-	struct list_head 	*rh = &b->lru_head;
+	struct rb_node		**p = &b->rb_head.rb_node,
+				*parent = NULL;
 	unsigned int		entries = 0;
+	int cmp;
 
-	list_for_each_entry(rp, rh, c_lru) {
+	while (*p != NULL) {
 		++entries;
-		if (nfsd_cache_key_cmp(key, rp) == 0) {
+		parent = *p;
+		rp = rb_entry(parent, struct svc_cacherep, c_node);
+
+		cmp = nfsd_cache_key_cmp(key, rp);
+		if (cmp < 0)
+			p = &parent->rb_left;
+		else if (cmp > 0)
+			p = &parent->rb_right;
+		else {
 			ret = rp;
-			break;
+			goto out;
 		}
 	}
-
+	rb_link_node(&key->c_node, parent, p);
+	rb_insert_color(&key->c_node, &b->rb_head);
+out:
 	/* tally hash chain length stats */
 	if (entries > longest_chain) {
 		longest_chain = entries;
@@ -414,7 +429,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	spin_lock(&b->cache_lock);
 	found = nfsd_cache_insert(b, rp);
 	if (found != rp) {
-		nfsd_reply_cache_free_locked(rp);
+		nfsd_reply_cache_free_locked(NULL, rp);
 		rp = found;
 		goto found_entry;
 	}
@@ -462,7 +477,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		break;
 	default:
 		printk(KERN_WARNING "nfsd: bad repcache type %d\n", rp->c_type);
-		nfsd_reply_cache_free_locked(rp);
+		nfsd_reply_cache_free_locked(b, rp);
 	}
 
 	goto out;
-- 
2.17.1
