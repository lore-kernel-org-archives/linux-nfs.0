From: Greg Banks <gnb@sgi.com>
Subject: [patch 11/14] sunrpc: Allocate cache_requests in a single allocation.
Date: Thu, 08 Jan 2009 19:25:21 +1100
Message-ID: <20090108082604.735830000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44998 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752359AbZAHI0L (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocate the cache_request object and it's buffer in a single
contiguous memory allocation instead of two separate ones.
Code trawling shows that none of the users of caches make upcalls
anywhere near even the small x86 PAGE_SIZE, so we can afford to lose
a few bytes.  One less allocation makes the code a little simpler.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |   28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -689,8 +689,8 @@ void cache_clean_deferred(void *owner)
 struct cache_request {
 	struct list_head	list;
 	struct cache_head	*item;
-	char			* buf;
 	int			len;
+	char			buf[0];
 };
 
 static ssize_t
@@ -741,7 +741,6 @@ cache_read(struct file *filp, char __use
 error:
 	/* need to release rq */
 	cache_put(rq->item, cd);
-	kfree(rq->buf);
 	kfree(rq);
 
 	return err;
@@ -893,7 +892,6 @@ static void cache_remove_queued(struct c
 	/* if found, destroy */
 	if (rq) {
 		cache_put(rq->item, cd);
-		kfree(rq->buf);
 		kfree(rq);
 	}
 }
@@ -983,15 +981,13 @@ static void warn_no_listener(struct cach
 
 /*
  * register an upcall request to user-space.
- * Each request is at most one page long.
+ * Each request is at most (slightly less than) one page long.
  */
 static int cache_make_upcall(struct cache_detail *cd, struct cache_head *h)
 {
-
-	char *buf;
 	struct cache_request *rq;
 	char *bp;
-	int len;
+	int len;	/* bytes remaining in the buffer */
 
 	if (cd->cache_request == NULL)
 		return -EINVAL;
@@ -1002,28 +998,20 @@ static int cache_make_upcall(struct cach
 		return -EINVAL;
 	}
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
-	if (!buf)
-		return -EAGAIN;
-
-	rq = kmalloc(sizeof (*rq), GFP_KERNEL);
-	if (!rq) {
-		kfree(buf);
+	rq = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!rq)
 		return -EAGAIN;
-	}
-
-	bp = buf; len = PAGE_SIZE;
 
+	bp = rq->buf;
+	len = PAGE_SIZE - sizeof(*rq);
 	cd->cache_request(cd, h, &bp, &len);
 
 	if (len < 0) {
-		kfree(buf);
 		kfree(rq);
 		return -EAGAIN;
 	}
 	rq->item = cache_get(h);
-	rq->buf = buf;
-	rq->len = PAGE_SIZE - len;
+	rq->len = PAGE_SIZE - sizeof(*rq) - len;
 	spin_lock(&cd->queue_lock);
 	list_add_tail(&rq->list, &cd->to_read);
 	spin_unlock(&cd->queue_lock);

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
