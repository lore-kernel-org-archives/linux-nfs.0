From: Greg Banks <gnb@sgi.com>
Subject: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Thu, 08 Jan 2009 19:25:20 +1100
Message-ID: <20090108082604.517918000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44992 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752851AbZAHI0K (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of a single list which confusingly contains a mixture of
cache_request and cache_reader structures in various states, use two
separate lists.

Both new lists contain cache_request structures, the cache_reader
structure is eliminated.  It's only purpose was to hold state which
supports partial reads of upcalls from userspace.  However the
implementation of partial reads is broken in the presence of the
multi-threaded rpc.mountd, in two different ways.

Firstly, the kernel code assumes that each reader uses a separate
struct file; because rpc.mountd fork()s *after* opening the cache
file descriptor this is not true.  Thus the single struct file and
the single rp->offset field are shared between multiple threads.
Unfortunately rp->offset is not maintained in a safe manner.  This can
lead to the BUG_ON() in cache_read() being tripped.

Secondly, even if the kernel code worked perfectly it's sharing
a single offset between multiple reading rpc.mountd threads.  If a
thread does a partial read, there's no way to match up the remaining
bytes in the upcall to the thread that read the initial part.  So a
partial read will result in any second reading thread that comes
along being given a spurious part of an upcall.  Both threads will
then fail to parse their respective mangled upcalls.  At the very
least this will result in clients seeing NFS calls which triggered
an upcall being randomly dropped under load.

The "right" way to fix this would be to implement a primitive such as
recvmsg() that an rpc.mountd thread could use to atomically retrieve an
entire upcall message.  However in this case we know that the size of
the messages is limited by existing code to PAGE_SIZE and by usage to
even less.  We also know that gssd and recent rpc.mountd do 2048 byte
read()s, so partial reads should be unnecessary.  These circumstances
should allow removing support for partial reads.

Having made that decision, we can remove struct cache_reader and
greatly simplify all the code that deals with the upcall queue and
with cache file descriptors.

Further, the old code kept in it's single list cache_requests objects
in two different states: waiting to be sent up to an rpc.mountd thread
in response to a read(), and waiting for a reply (or pre-emptive reply)
from an rpc.mountd thread which arrives in a write().  The difference
was tracked by some very gnarly code which relied on the relative
position of cache_reader and cache_request objects in the single list.
This is very hard code to understand and debug.  The new code uses
two separate lists and much simpler logic.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/cache.h |    3 
 net/sunrpc/cache.c           |  246 ++++++++++++--------------------
 2 files changed, 97 insertions(+), 152 deletions(-)

Index: bfields/include/linux/sunrpc/cache.h
===================================================================
--- bfields.orig/include/linux/sunrpc/cache.h
+++ bfields/include/linux/sunrpc/cache.h
@@ -97,7 +97,8 @@ struct cache_detail {
 
 	/* fields for communication over channel */
 	spinlock_t		queue_lock;
-	struct list_head	queue;
+	struct list_head	to_read;
+	struct list_head	to_write;
 	wait_queue_head_t	queue_wait;
 
 	struct proc_dir_entry	*proc_ent;
Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -361,7 +361,8 @@ int cache_register(struct cache_detail *
 	rwlock_init(&cd->hash_lock);
 	spin_lock_init(&cd->queue_lock);
 	init_waitqueue_head(&cd->queue_wait);
-	INIT_LIST_HEAD(&cd->queue);
+	INIT_LIST_HEAD(&cd->to_read);
+	INIT_LIST_HEAD(&cd->to_write);
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
 	cd->entries = 0;
@@ -659,106 +660,91 @@ void cache_clean_deferred(void *owner)
 }
 
 /*
- * communicate with user-space
+ * Caches communicate with user-space.
  *
  * We have a magic /proc file - /proc/sunrpc/<cachename>/channel.
- * On read, you get a full request, or block.
- * On write, an update request is processed.
+ *
+ * On read, you get a full request.  If the length passed
+ * to read() is too short, you get nothing and the message is dropped,
+ * which is bad.  So you should use a sufficently large length,
+ * for example PAGE_SIZE.  If there are no requests queued,
+ * read() returns 0.
+ *
+ * On write, an update is processed.  This may, as a side effect,
+ * cause a previously queued request to be de-queued and removed.
+ * Userspace can also pre-emptively write updates which the kernel
+ * has not yet requested.
+ *
  * Poll works if anything to read, and always allows write.
  *
- * Implemented by linked list of requests.  Each open file has
- * a ->private that also exists in this list.  New requests are added
- * to the end and may wakeup and preceding readers.
- * New readers are added to the head.  If, on read, an item is found with
- * CACHE_UPCALLING clear, we free it from the list.
+ * The channel is implemented by two linked lists of cache_request
+ * objects.  cd->to_read is requests which have been generated in
+ * the kernel and are waiting for a userspace process to read them.
+ * cd->to_write is requests which have been read by userspace and
+ * are awaiting a reply to be written.
  *
+ * Both lists are protected by cd->queue_lock.
  */
 
-struct cache_queue {
-	struct list_head	list;
-	int			reader;	/* if 0, then request */
-};
 struct cache_request {
-	struct cache_queue	q;
+	struct list_head	list;
 	struct cache_head	*item;
 	char			* buf;
 	int			len;
-	int			readers;
-};
-struct cache_reader {
-	struct cache_queue	q;
-	int			offset;	/* if non-0, we have a refcnt on next request */
 };
 
 static ssize_t
 cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 {
-	struct cache_reader *rp = filp->private_data;
-	struct cache_request *rq;
+	struct cache_request *rq = NULL;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 	int err;
 
 	if (count == 0)
 		return 0;
 
- again:
+	/* de-queue the next request which is waiting to be read */
 	spin_lock(&cd->queue_lock);
-	/* need to find next request */
-	while (rp->q.list.next != &cd->queue &&
-	       list_entry(rp->q.list.next, struct cache_queue, list)
-	       ->reader) {
-		struct list_head *next = rp->q.list.next;
-		list_move(&rp->q.list, next);
-	}
-	if (rp->q.list.next == &cd->queue) {
-		spin_unlock(&cd->queue_lock);
-		BUG_ON(rp->offset);
-		return 0;
+	if (!list_empty(&cd->to_read)) {
+		rq = container_of(cd->to_read.next, struct cache_request, list);
+		list_del_init(&rq->list);
 	}
-	rq = container_of(rp->q.list.next, struct cache_request, q.list);
-	BUG_ON(rq->q.reader);
-	if (rp->offset == 0)
-		rq->readers++;
 	spin_unlock(&cd->queue_lock);
 
-	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
-		err = -EAGAIN;
-		spin_lock(&cd->queue_lock);
-		list_move(&rp->q.list, &rq->q.list);
-		spin_unlock(&cd->queue_lock);
-	} else {
-		if (rp->offset + count > rq->len)
-			count = rq->len - rp->offset;
-		err = -EFAULT;
-		if (copy_to_user(buf, rq->buf + rp->offset, count))
-			goto out;
-		rp->offset += count;
-		if (rp->offset >= rq->len) {
-			rp->offset = 0;
-			spin_lock(&cd->queue_lock);
-			list_move(&rp->q.list, &rq->q.list);
-			spin_unlock(&cd->queue_lock);
-		}
-		err = 0;
-	}
- out:
-	if (rp->offset == 0) {
-		/* need to release rq */
-		spin_lock(&cd->queue_lock);
-		rq->readers--;
-		if (rq->readers == 0 &&
-		    !test_bit(CACHE_PENDING, &rq->item->flags)) {
-			list_del(&rq->q.list);
-			spin_unlock(&cd->queue_lock);
-			cache_put(rq->item, cd);
-			kfree(rq->buf);
-			kfree(rq);
-		} else
-			spin_unlock(&cd->queue_lock);
-	}
-	if (err == -EAGAIN)
-		goto again;
-	return err ? err :  count;
+	if (rq == NULL)
+		return 0; /* no queued requests */
+
+	err = -EAGAIN;	/* gnb:TODO...this used to cause a loop, wtf */
+	if (!test_bit(CACHE_PENDING, &rq->item->flags))
+		goto error;
+
+	/* gnb:TODO whine to dmesg; stat */
+	err = -EFAULT;
+	if (count < rq->len)
+		goto error; /* We make no pretence at handling short reads */
+	count = rq->len;
+
+	err = -EFAULT;
+	if (copy_to_user(buf, rq->buf, count))
+		goto error;
+
+	/*
+	 * Done reading, append to the list of requests
+	 * which are waiting for a write from userspace.
+	 */
+	spin_lock(&cd->queue_lock);
+	list_add_tail(&rq->list, &cd->to_write);
+	spin_unlock(&cd->queue_lock);
+
+	return count;
+
+error:
+	/* need to release rq */
+	cache_put(rq->item, cd);
+	kfree(rq->buf);
+	kfree(rq);
+
+	return err;
 }
 
 static ssize_t
@@ -796,28 +782,21 @@ out:
 static unsigned int
 cache_poll(struct file *filp, poll_table *wait)
 {
-	unsigned int mask;
-	struct cache_reader *rp = filp->private_data;
-	struct cache_queue *cq;
+	unsigned int mask = 0;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 
 	poll_wait(filp, &cd->queue_wait, wait);
 
-	/* alway allow write */
-	mask = POLL_OUT | POLLWRNORM;
+	if (filp->f_mode & FMODE_WRITE)
+		mask = POLL_OUT | POLLWRNORM;
 
-	if (!rp)
-		return mask;
-
-	spin_lock(&cd->queue_lock);
-
-	for (cq= &rp->q; &cq->list != &cd->queue;
-	     cq = list_entry(cq->list.next, struct cache_queue, list))
-		if (!cq->reader) {
+	if (filp->f_mode & FMODE_READ) {
+		spin_lock(&cd->queue_lock);
+		if (!list_empty(&cd->to_read))
 			mask |= POLLIN | POLLRDNORM;
-			break;
-		}
-	spin_unlock(&cd->queue_lock);
+		spin_unlock(&cd->queue_lock);
+	}
+
 	return mask;
 }
 
@@ -826,26 +805,23 @@ cache_ioctl(struct inode *ino, struct fi
 	    unsigned int cmd, unsigned long arg)
 {
 	int len = 0;
-	struct cache_reader *rp = filp->private_data;
-	struct cache_queue *cq;
+	struct cache_request *rq;
 	struct cache_detail *cd = PDE(ino)->data;
 
-	if (cmd != FIONREAD || !rp)
+	if (cmd != FIONREAD)
+		return -EINVAL;
+	if (!(filp->f_mode & FMODE_READ))
 		return -EINVAL;
 
 	spin_lock(&cd->queue_lock);
 
-	/* only find the length remaining in current request,
-	 * or the length of the next request
+	/* only find the length of the next request
 	 */
-	for (cq= &rp->q; &cq->list != &cd->queue;
-	     cq = list_entry(cq->list.next, struct cache_queue, list))
-		if (!cq->reader) {
-			struct cache_request *rq =
-				container_of(cq, struct cache_request, q);
-			len = rq->len - rp->offset;
-			break;
-		}
+	if (!list_empty(&cd->to_read)) {
+		rq = container_of(cd->to_read.next, struct cache_request, list);
+		len = rq->len;
+	}
+
 	spin_unlock(&cd->queue_lock);
 
 	return put_user(len, (int __user *)arg);
@@ -854,51 +830,20 @@ cache_ioctl(struct inode *ino, struct fi
 static int
 cache_open(struct inode *inode, struct file *filp)
 {
-	struct cache_reader *rp = NULL;
-
 	nonseekable_open(inode, filp);
 	if (filp->f_mode & FMODE_READ) {
 		struct cache_detail *cd = PDE(inode)->data;
-
-		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp)
-			return -ENOMEM;
-		rp->offset = 0;
-		rp->q.reader = 1;
 		atomic_inc(&cd->readers);
-		spin_lock(&cd->queue_lock);
-		list_add(&rp->q.list, &cd->queue);
-		spin_unlock(&cd->queue_lock);
 	}
-	filp->private_data = rp;
 	return 0;
 }
 
 static int
 cache_release(struct inode *inode, struct file *filp)
 {
-	struct cache_reader *rp = filp->private_data;
 	struct cache_detail *cd = PDE(inode)->data;
 
-	if (rp) {
-		spin_lock(&cd->queue_lock);
-		if (rp->offset) {
-			struct cache_queue *cq;
-			for (cq= &rp->q; &cq->list != &cd->queue;
-			     cq = list_entry(cq->list.next, struct cache_queue, list))
-				if (!cq->reader) {
-					container_of(cq, struct cache_request, q)
-						->readers--;
-					break;
-				}
-			rp->offset = 0;
-		}
-		list_del(&rp->q.list);
-		spin_unlock(&cd->queue_lock);
-
-		filp->private_data = NULL;
-		kfree(rp);
-
+	if (filp->f_mode & FMODE_READ) {
 		cd->last_close = get_seconds();
 		atomic_dec(&cd->readers);
 	}
@@ -918,26 +863,39 @@ static const struct file_operations cach
 	.release	= cache_release,
 };
 
+static struct cache_request *
+cache_queue_find_locked(struct list_head *listp, struct cache_head *h)
+{
+	struct cache_request *rq;
+
+	list_for_each_entry(rq, listp, list) {
+		if (rq->item == h)
+			return rq;
+	}
+	return NULL;
+}
 
 static void cache_remove_queued(struct cache_detail *cd, struct cache_head *h)
 {
-	struct cache_queue *cq;
+	struct cache_request *rq;
+
+	/* find and de-queue */
 	spin_lock(&cd->queue_lock);
-	list_for_each_entry(cq, &cd->queue, list)
-		if (!cq->reader) {
-			struct cache_request *rq = container_of(cq, struct cache_request, q);
-			if (rq->item != h)
-				continue;
-			if (rq->readers != 0)
-				continue;
-			list_del(&rq->q.list);
-			spin_unlock(&cd->queue_lock);
-			cache_put(rq->item, cd);
-			kfree(rq->buf);
-			kfree(rq);
-			return;
-		}
+
+	rq = cache_queue_find_locked(&cd->to_read, h);
+	if (!rq)
+		rq = cache_queue_find_locked(&cd->to_write, h);
+	if (rq)
+		list_del(&rq->list);
+
 	spin_unlock(&cd->queue_lock);
+
+	/* if found, destroy */
+	if (rq) {
+		cache_put(rq->item, cd);
+		kfree(rq->buf);
+		kfree(rq);
+	}
 }
 
 /*
@@ -1063,13 +1021,11 @@ static int cache_make_upcall(struct cach
 		kfree(rq);
 		return -EAGAIN;
 	}
-	rq->q.reader = 0;
 	rq->item = cache_get(h);
 	rq->buf = buf;
 	rq->len = PAGE_SIZE - len;
-	rq->readers = 0;
 	spin_lock(&cd->queue_lock);
-	list_add_tail(&rq->q.list, &cd->queue);
+	list_add_tail(&rq->list, &cd->to_read);
 	spin_unlock(&cd->queue_lock);
 	wake_up(&cd->queue_wait);
 	return 0;

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
