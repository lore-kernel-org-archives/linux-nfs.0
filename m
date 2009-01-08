From: Greg Banks <gnb@sgi.com>
Subject: [patch 03/14] sunrpc: Use consistent naming for variables of type struct cache_request*.
Date: Thu, 08 Jan 2009 19:25:13 +1100
Message-ID: <20090108082603.014745000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:50378 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752359AbZAHI0I (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:08 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This makes the cache code easier to read.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -846,9 +846,9 @@ cache_ioctl(struct inode *ino, struct fi
 	for (cq= &rp->q; &cq->list != &cd->queue;
 	     cq = list_entry(cq->list.next, struct cache_queue, list))
 		if (!cq->reader) {
-			struct cache_request *cr =
+			struct cache_request *rq =
 				container_of(cq, struct cache_request, q);
-			len = cr->len - rp->offset;
+			len = rq->len - rp->offset;
 			break;
 		}
 	spin_unlock(&queue_lock);
@@ -930,16 +930,16 @@ static void queue_loose(struct cache_det
 	spin_lock(&queue_lock);
 	list_for_each_entry(cq, &cd->queue, list)
 		if (!cq->reader) {
-			struct cache_request *cr = container_of(cq, struct cache_request, q);
-			if (cr->item != h)
+			struct cache_request *rq = container_of(cq, struct cache_request, q);
+			if (rq->item != h)
 				continue;
-			if (cr->readers != 0)
+			if (rq->readers != 0)
 				continue;
-			list_del(&cr->q.list);
+			list_del(&rq->q.list);
 			spin_unlock(&queue_lock);
-			cache_put(cr->item, cd);
-			kfree(cr->buf);
-			kfree(cr);
+			cache_put(rq->item, cd);
+			kfree(rq->buf);
+			kfree(rq);
 			return;
 		}
 	spin_unlock(&queue_lock);
@@ -1036,7 +1036,7 @@ static int cache_make_upcall(struct cach
 {
 
 	char *buf;
-	struct cache_request *crq;
+	struct cache_request *rq;
 	char *bp;
 	int len;
 
@@ -1053,8 +1053,8 @@ static int cache_make_upcall(struct cach
 	if (!buf)
 		return -EAGAIN;
 
-	crq = kmalloc(sizeof (*crq), GFP_KERNEL);
-	if (!crq) {
+	rq = kmalloc(sizeof (*rq), GFP_KERNEL);
+	if (!rq) {
 		kfree(buf);
 		return -EAGAIN;
 	}
@@ -1065,16 +1065,16 @@ static int cache_make_upcall(struct cach
 
 	if (len < 0) {
 		kfree(buf);
-		kfree(crq);
+		kfree(rq);
 		return -EAGAIN;
 	}
-	crq->q.reader = 0;
-	crq->item = cache_get(h);
-	crq->buf = buf;
-	crq->len = PAGE_SIZE - len;
-	crq->readers = 0;
+	rq->q.reader = 0;
+	rq->item = cache_get(h);
+	rq->buf = buf;
+	rq->len = PAGE_SIZE - len;
+	rq->readers = 0;
 	spin_lock(&queue_lock);
-	list_add_tail(&crq->q.list, &cd->queue);
+	list_add_tail(&rq->q.list, &cd->queue);
 	spin_unlock(&queue_lock);
 	wake_up(&queue_wait);
 	return 0;

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
