From: Greg Banks <gnb@sgi.com>
Subject: [patch 07/14] sunrpc: Make the global queue_lock per-cache-detail.
Date: Thu, 08 Jan 2009 19:25:17 +1100
Message-ID: <20090108082603.870223000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:54356 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753435AbZAHI0P (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The data structures it's protecting are all contained by the
cache_detail, so having a global lock is unnecessary and potentially
a performance limitation.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/cache.h |    2 +
 net/sunrpc/cache.c           |   48 ++++++++++++++++----------------
 2 files changed, 26 insertions(+), 24 deletions(-)

Index: bfields/include/linux/sunrpc/cache.h
===================================================================
--- bfields.orig/include/linux/sunrpc/cache.h
+++ bfields/include/linux/sunrpc/cache.h
@@ -16,6 +16,7 @@
 #include <linux/slab.h>
 #include <asm/atomic.h>
 #include <linux/proc_fs.h>
+#include <linux/spinlock.h>
 
 /*
  * Each cache requires:
@@ -95,6 +96,7 @@ struct cache_detail {
 	int			entries;
 
 	/* fields for communication over channel */
+	spinlock_t		queue_lock;
 	struct list_head	queue;
 	struct proc_dir_entry	*proc_ent;
 	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -359,6 +359,7 @@ int cache_register(struct cache_detail *
 	if (ret)
 		return ret;
 	rwlock_init(&cd->hash_lock);
+	spin_lock_init(&cd->queue_lock);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
@@ -672,7 +673,6 @@ void cache_clean_deferred(void *owner)
  *
  */
 
-static DEFINE_SPINLOCK(queue_lock);
 static DEFINE_MUTEX(queue_io_mutex);
 
 struct cache_queue {
@@ -705,7 +705,7 @@ cache_read(struct file *filp, char __use
 	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
 			      * readers on this file */
  again:
-	spin_lock(&queue_lock);
+	spin_lock(&cd->queue_lock);
 	/* need to find next request */
 	while (rp->q.list.next != &cd->queue &&
 	       list_entry(rp->q.list.next, struct cache_queue, list)
@@ -714,7 +714,7 @@ cache_read(struct file *filp, char __use
 		list_move(&rp->q.list, next);
 	}
 	if (rp->q.list.next == &cd->queue) {
-		spin_unlock(&queue_lock);
+		spin_unlock(&cd->queue_lock);
 		mutex_unlock(&queue_io_mutex);
 		BUG_ON(rp->offset);
 		return 0;
@@ -723,13 +723,13 @@ cache_read(struct file *filp, char __use
 	BUG_ON(rq->q.reader);
 	if (rp->offset == 0)
 		rq->readers++;
-	spin_unlock(&queue_lock);
+	spin_unlock(&cd->queue_lock);
 
 	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
 		err = -EAGAIN;
-		spin_lock(&queue_lock);
+		spin_lock(&cd->queue_lock);
 		list_move(&rp->q.list, &rq->q.list);
-		spin_unlock(&queue_lock);
+		spin_unlock(&cd->queue_lock);
 	} else {
 		if (rp->offset + count > rq->len)
 			count = rq->len - rp->offset;
@@ -739,26 +739,26 @@ cache_read(struct file *filp, char __use
 		rp->offset += count;
 		if (rp->offset >= rq->len) {
 			rp->offset = 0;
-			spin_lock(&queue_lock);
+			spin_lock(&cd->queue_lock);
 			list_move(&rp->q.list, &rq->q.list);
-			spin_unlock(&queue_lock);
+			spin_unlock(&cd->queue_lock);
 		}
 		err = 0;
 	}
  out:
 	if (rp->offset == 0) {
 		/* need to release rq */
-		spin_lock(&queue_lock);
+		spin_lock(&cd->queue_lock);
 		rq->readers--;
 		if (rq->readers == 0 &&
 		    !test_bit(CACHE_PENDING, &rq->item->flags)) {
 			list_del(&rq->q.list);
-			spin_unlock(&queue_lock);
+			spin_unlock(&cd->queue_lock);
 			cache_put(rq->item, cd);
 			kfree(rq->buf);
 			kfree(rq);
 		} else
-			spin_unlock(&queue_lock);
+			spin_unlock(&cd->queue_lock);
 	}
 	if (err == -EAGAIN)
 		goto again;
@@ -814,7 +814,7 @@ cache_poll(struct file *filp, poll_table
 	if (!rp)
 		return mask;
 
-	spin_lock(&queue_lock);
+	spin_lock(&cd->queue_lock);
 
 	for (cq= &rp->q; &cq->list != &cd->queue;
 	     cq = list_entry(cq->list.next, struct cache_queue, list))
@@ -822,7 +822,7 @@ cache_poll(struct file *filp, poll_table
 			mask |= POLLIN | POLLRDNORM;
 			break;
 		}
-	spin_unlock(&queue_lock);
+	spin_unlock(&cd->queue_lock);
 	return mask;
 }
 
@@ -838,7 +838,7 @@ cache_ioctl(struct inode *ino, struct fi
 	if (cmd != FIONREAD || !rp)
 		return -EINVAL;
 
-	spin_lock(&queue_lock);
+	spin_lock(&cd->queue_lock);
 
 	/* only find the length remaining in current request,
 	 * or the length of the next request
@@ -851,7 +851,7 @@ cache_ioctl(struct inode *ino, struct fi
 			len = rq->len - rp->offset;
 			break;
 		}
-	spin_unlock(&queue_lock);
+	spin_unlock(&cd->queue_lock);
 
 	return put_user(len, (int __user *)arg);
 }
@@ -871,9 +871,9 @@ cache_open(struct inode *inode, struct f
 		rp->offset = 0;
 		rp->q.reader = 1;
 		atomic_inc(&cd->readers);
-		spin_lock(&queue_lock);
+		spin_lock(&cd->queue_lock);
 		list_add(&rp->q.list, &cd->queue);
-		spin_unlock(&queue_lock);
+		spin_unlock(&cd->queue_lock);
 	}
 	filp->private_data = rp;
 	return 0;
@@ -886,7 +886,7 @@ cache_release(struct inode *inode, struc
 	struct cache_detail *cd = PDE(inode)->data;
 
 	if (rp) {
-		spin_lock(&queue_lock);
+		spin_lock(&cd->queue_lock);
 		if (rp->offset) {
 			struct cache_queue *cq;
 			for (cq= &rp->q; &cq->list != &cd->queue;
@@ -899,7 +899,7 @@ cache_release(struct inode *inode, struc
 			rp->offset = 0;
 		}
 		list_del(&rp->q.list);
-		spin_unlock(&queue_lock);
+		spin_unlock(&cd->queue_lock);
 
 		filp->private_data = NULL;
 		kfree(rp);
@@ -927,7 +927,7 @@ static const struct file_operations cach
 static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h)
 {
 	struct cache_queue *cq;
-	spin_lock(&queue_lock);
+	spin_lock(&cd->queue_lock);
 	list_for_each_entry(cq, &cd->queue, list)
 		if (!cq->reader) {
 			struct cache_request *rq = container_of(cq, struct cache_request, q);
@@ -936,13 +936,13 @@ static void cache_remove_queued(struct c
 			if (rq->readers != 0)
 				continue;
 			list_del(&rq->q.list);
-			spin_unlock(&queue_lock);
+			spin_unlock(&cd->queue_lock);
 			cache_put(rq->item, cd);
 			kfree(rq->buf);
 			kfree(rq);
 			return;
 		}
-	spin_unlock(&queue_lock);
+	spin_unlock(&cd->queue_lock);
 }
 
 /*
@@ -1073,9 +1073,9 @@ static int cache_make_upcall(struct cach
 	rq->buf = buf;
 	rq->len = PAGE_SIZE - len;
 	rq->readers = 0;
-	spin_lock(&queue_lock);
+	spin_lock(&cd->queue_lock);
 	list_add_tail(&rq->q.list, &cd->queue);
-	spin_unlock(&queue_lock);
+	spin_unlock(&cd->queue_lock);
 	wake_up(&queue_wait);
 	return 0;
 }

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
