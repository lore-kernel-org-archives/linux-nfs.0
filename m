Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42404 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758066Ab0HLHFp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 03:05:45 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 12 Aug 2010 17:04:06 +1000
Subject: [PATCH 2/6] nfsd/idmap: drop special request deferal in favour of
	improved default.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100812070406.11459.89468.stgit@localhost.localdomain>
In-Reply-To: <20100812065722.11459.18978.stgit@localhost.localdomain>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The idmap code manages request deferal by waiting for a reply from
userspace rather than putting the NFS request on a queue to be retried
from the start.
Now that the common deferal code does this there is no need for the
special code in idmap.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4idmap.c |  105 +++++----------------------------------------------
 1 files changed, 11 insertions(+), 94 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index c78dbf4..f0695e8 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -482,109 +482,26 @@ nfsd_idmap_shutdown(void)
 	cache_unregister(&nametoid_cache);
 }
 
-/*
- * Deferred request handling
- */
-
-struct idmap_defer_req {
-       struct cache_req		req;
-       struct cache_deferred_req deferred_req;
-       wait_queue_head_t	waitq;
-       atomic_t			count;
-};
-
-static inline void
-put_mdr(struct idmap_defer_req *mdr)
-{
-	if (atomic_dec_and_test(&mdr->count))
-		kfree(mdr);
-}
-
-static inline void
-get_mdr(struct idmap_defer_req *mdr)
-{
-	atomic_inc(&mdr->count);
-}
-
-static void
-idmap_revisit(struct cache_deferred_req *dreq, int toomany)
-{
-	struct idmap_defer_req *mdr =
-		container_of(dreq, struct idmap_defer_req, deferred_req);
-
-	wake_up(&mdr->waitq);
-	put_mdr(mdr);
-}
-
-static struct cache_deferred_req *
-idmap_defer(struct cache_req *req)
-{
-	struct idmap_defer_req *mdr =
-		container_of(req, struct idmap_defer_req, req);
-
-	mdr->deferred_req.revisit = idmap_revisit;
-	get_mdr(mdr);
-	return (&mdr->deferred_req);
-}
-
-static inline int
-do_idmap_lookup(struct ent *(*lookup_fn)(struct ent *), struct ent *key,
-		struct cache_detail *detail, struct ent **item,
-		struct idmap_defer_req *mdr)
-{
-	*item = lookup_fn(key);
-	if (!*item)
-		return -ENOMEM;
-	return cache_check(detail, &(*item)->h, &mdr->req);
-}
-
-static inline int
-do_idmap_lookup_nowait(struct ent *(*lookup_fn)(struct ent *),
-			struct ent *key, struct cache_detail *detail,
-			struct ent **item)
-{
-	int ret = -ENOMEM;
-
-	*item = lookup_fn(key);
-	if (!*item)
-		goto out_err;
-	ret = -ETIMEDOUT;
-	if (!test_bit(CACHE_VALID, &(*item)->h.flags)
-			|| (*item)->h.expiry_time < get_seconds()
-			|| detail->flush_time > (*item)->h.last_refresh)
-		goto out_put;
-	ret = -ENOENT;
-	if (test_bit(CACHE_NEGATIVE, &(*item)->h.flags))
-		goto out_put;
-	return 0;
-out_put:
-	cache_put(&(*item)->h, detail);
-out_err:
-	*item = NULL;
-	return ret;
-}
-
 static int
 idmap_lookup(struct svc_rqst *rqstp,
 		struct ent *(*lookup_fn)(struct ent *), struct ent *key,
 		struct cache_detail *detail, struct ent **item)
 {
-	struct idmap_defer_req *mdr;
 	int ret;
 
-	mdr = kzalloc(sizeof(*mdr), GFP_KERNEL);
-	if (!mdr)
+	*item = lookup_fn(key);
+	if (!*item)
 		return -ENOMEM;
-	atomic_set(&mdr->count, 1);
-	init_waitqueue_head(&mdr->waitq);
-	mdr->req.defer = idmap_defer;
-	ret = do_idmap_lookup(lookup_fn, key, detail, item, mdr);
-	if (ret == -EAGAIN) {
-		wait_event_interruptible_timeout(mdr->waitq,
-			test_bit(CACHE_VALID, &(*item)->h.flags), 1 * HZ);
-		ret = do_idmap_lookup_nowait(lookup_fn, key, detail, item);
+ retry:
+	ret = cache_check(detail, &(*item)->h, &rqstp->rq_chandle);
+
+	if (ret == -ETIMEDOUT) {
+		struct ent *prev_item = *item;
+		*item = lookup_fn(key);
+		if (*item != prev_item)
+			goto retry;
+		cache_put(&(*item)->h, detail);
 	}
-	put_mdr(mdr);
 	return ret;
 }
 


