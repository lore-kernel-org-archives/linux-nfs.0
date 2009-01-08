From: Greg Banks <gnb@sgi.com>
Subject: [patch 12/14] sunrpc: Centralise memory management of cache_requests.
Date: Thu, 08 Jan 2009 19:25:22 +1100
Message-ID: <20090108082604.956787000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:45006 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753466AbZAHI0P (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Centralise the allocation and freeing of cache_request objects instead
of doing it in multiple places.  Use a reference count (but not a
kref, that would require adding a backpointer to the cache_detail in
the cache_request).

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |   46 +++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -688,11 +688,39 @@ void cache_clean_deferred(void *owner)
 
 struct cache_request {
 	struct list_head	list;
+	atomic_t		count;
 	struct cache_head	*item;
 	int			len;
 	char			buf[0];
 };
 
+static void
+cache_request_put(struct cache_request *rq, struct cache_detail *cd)
+{
+	if (atomic_dec_and_test(&rq->count)) {
+		cache_put(rq->item, cd);
+		kfree(rq);
+	}
+}
+
+static struct cache_request *
+cache_request_get(struct cache_head *h)
+{
+	struct cache_request *rq;
+
+	rq = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!rq)
+		return NULL;
+
+	memset(rq, 0, sizeof(*rq));
+	INIT_LIST_HEAD(&rq->list);
+	atomic_set(&rq->count, 1);
+	rq->len = PAGE_SIZE - sizeof(*rq);
+	rq->item = cache_get(h);
+
+	return rq;
+}
+
 static ssize_t
 cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 {
@@ -740,8 +768,7 @@ cache_read(struct file *filp, char __use
 
 error:
 	/* need to release rq */
-	cache_put(rq->item, cd);
-	kfree(rq);
+	cache_request_put(rq, cd);
 
 	return err;
 }
@@ -890,10 +917,8 @@ static void cache_remove_queued(struct c
 	spin_unlock(&cd->queue_lock);
 
 	/* if found, destroy */
-	if (rq) {
-		cache_put(rq->item, cd);
-		kfree(rq);
-	}
+	if (rq)
+		cache_request_put(rq, cd);
 }
 
 /*
@@ -998,20 +1023,19 @@ static int cache_make_upcall(struct cach
 		return -EINVAL;
 	}
 
-	rq = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	rq = cache_request_get(h);
 	if (!rq)
 		return -EAGAIN;
 
 	bp = rq->buf;
-	len = PAGE_SIZE - sizeof(*rq);
+	len = rq->len;
 	cd->cache_request(cd, h, &bp, &len);
 
 	if (len < 0) {
-		kfree(rq);
+		cache_request_put(rq, cd);
 		return -EAGAIN;
 	}
-	rq->item = cache_get(h);
-	rq->len = PAGE_SIZE - sizeof(*rq) - len;
+	rq->len -= len;
 	spin_lock(&cd->queue_lock);
 	list_add_tail(&rq->list, &cd->to_read);
 	spin_unlock(&cd->queue_lock);

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
