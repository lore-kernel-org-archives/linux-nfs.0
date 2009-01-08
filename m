From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Thu, 8 Jan 2009 14:57:49 -0500
Message-ID: <20090108195747.GB19312@fieldses.org>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48843 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757777AbZAHT5x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 14:57:53 -0500
In-Reply-To: <20090108082604.517918000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 08, 2009 at 07:25:20PM +1100, Greg Banks wrote:
> Instead of a single list which confusingly contains a mixture of
> cache_request and cache_reader structures in various states, use two
> separate lists.
> 
> Both new lists contain cache_request structures, the cache_reader
> structure is eliminated.  It's only purpose was to hold state which
> supports partial reads of upcalls from userspace.  However the
> implementation of partial reads is broken in the presence of the
> multi-threaded rpc.mountd, in two different ways.
> 
> Firstly, the kernel code assumes that each reader uses a separate
> struct file; because rpc.mountd fork()s *after* opening the cache
> file descriptor this is not true.  Thus the single struct file and
> the single rp->offset field are shared between multiple threads.
> Unfortunately rp->offset is not maintained in a safe manner.  This can
> lead to the BUG_ON() in cache_read() being tripped.

Hm, have you seen this happen?

All the current upcalls are small enough (and mountd's default read
buffer large enough) that messages should always be read in one gulp.

> 
> Secondly, even if the kernel code worked perfectly it's sharing
> a single offset between multiple reading rpc.mountd threads.

I made what I suspect is a similar patch a while ago and never got
around to submitting it.  (Arrgh!  Bad me!)  Appended below if it's of
any use to you to compare.  (Happy to apply either your patch or mine
depending which looks better; I haven't tried to compare carefully.)

--b.

commit f948255274fdc8b5932ad4e88d5610c6ea3de9f7
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Dec 5 14:52:51 2007 -0500

    sunrpc: simplify dispatching of upcalls to file descriptors
    
    If you want to handle a lot of upcall requests, especially requests that
    may take a while (e.g. because they require talking to ldap or kerberos
    servers, or spinning up a newly accessed disk), then you need to process
    upcalls in parallel.
    
    When there are multiple requests available for processing, we'd prefer
    not to hand the same request to multiple readers, as that either wastes
    resources (or requires upcall-processing to detect such cases itself).
    
    The current code keeps a single list containing all open file
    descriptors and requests.  Each file descriptor is advanced through the
    list until it finds a request.  Multiple requests may find the same
    request at once, and requests are left on the list until they are
    responded to.  Under this scheme the likelihood of two readers getting
    the same request is high.
    
    You can mitigate the problem by reading from a single file descriptor
    that's shared between processes (as mountd currently does), but that
    requires the read to always provide a buffer large enough to get the
    whole request in one atomic read.  That's less practical for gss
    init_sec_context calls, which could vary in size from a few hundred
    bytes to 100k or so.
    
    So, instead move processes that are being read out off the common list
    of requests into the file descriptor's private area, and move them to
    the end of the list after they're read.
    
    That makes it a little less likely they'll be re-read by another process
    immediately.
    
    This also simplifies the code.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 636c8e0..5512fbb 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -670,39 +670,31 @@ void cache_clean_deferred(void *owner)
  * On write, an update request is processed.
  * Poll works if anything to read, and always allows write.
  *
- * Implemented by linked list of requests.  Each open file has
- * a ->private that also exists in this list.  New requests are added
- * to the end and may wakeup and preceding readers.
- * New readers are added to the head.  If, on read, an item is found with
- * CACHE_UPCALLING clear, we free it from the list.
- *
+ * Keep a list of requests associated with each cache descriptor.
+ * On read from an open file descriptor, pick the request at the
+ * head of the list and move it to the file descriptor's private area.
+ * After it is read, return it to the tail of the list.  Keep requests
+ * on the list until we notice that they have been responded to (at
+ * which point CACHE_PENDING is cleared).
  */
 
 static DEFINE_SPINLOCK(queue_lock);
 static DEFINE_MUTEX(queue_io_mutex);
 
-struct cache_queue {
-	struct list_head	list;
-	int			reader;	/* if 0, then request */
-};
 struct cache_request {
-	struct cache_queue	q;
+	struct list_head	list;
 	struct cache_head	*item;
 	char			* buf;
+	int			offset;
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
+	struct cache_request *rq = filp->private_data;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+	struct list_head *queue = &cd->queue;
 	int err;
 
 	if (count == 0)
@@ -711,60 +703,45 @@ cache_read(struct file *filp, char __user *buf, size_t count, loff_t *ppos)
 	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
 			      * readers on this file */
  again:
-	spin_lock(&queue_lock);
-	/* need to find next request */
-	while (rp->q.list.next != &cd->queue &&
-	       list_entry(rp->q.list.next, struct cache_queue, list)
-	       ->reader) {
-		struct list_head *next = rp->q.list.next;
-		list_move(&rp->q.list, next);
+	if (rq == NULL) {
+		if (!list_empty(queue)) {
+			spin_lock(&queue_lock);
+			rq = list_first_entry(queue, struct cache_request,
+						list);
+			list_del_init(&rq->list);
+			filp->private_data = rq;
+			spin_unlock(&queue_lock);
+		}
 	}
-	if (rp->q.list.next == &cd->queue) {
-		spin_unlock(&queue_lock);
+	if (rq == NULL) {
 		mutex_unlock(&queue_io_mutex);
-		BUG_ON(rp->offset);
-		return 0;
+		return -EAGAIN;
 	}
-	rq = container_of(rp->q.list.next, struct cache_request, q.list);
-	BUG_ON(rq->q.reader);
-	if (rp->offset == 0)
-		rq->readers++;
-	spin_unlock(&queue_lock);
 
-	if (rp->offset == 0 && !test_bit(CACHE_PENDING, &rq->item->flags)) {
+	if (!test_bit(CACHE_PENDING, &rq->item->flags))
 		err = -EAGAIN;
-		spin_lock(&queue_lock);
-		list_move(&rp->q.list, &rq->q.list);
-		spin_unlock(&queue_lock);
-	} else {
-		if (rp->offset + count > rq->len)
-			count = rq->len - rp->offset;
+	else {
+		if (rq->offset + count > rq->len)
+			count = rq->len - rq->offset;
 		err = -EFAULT;
-		if (copy_to_user(buf, rq->buf + rp->offset, count))
+		if (copy_to_user(buf, rq->buf + rq->offset, count))
 			goto out;
-		rp->offset += count;
-		if (rp->offset >= rq->len) {
-			rp->offset = 0;
-			spin_lock(&queue_lock);
-			list_move(&rp->q.list, &rq->q.list);
-			spin_unlock(&queue_lock);
-		}
+		rq->offset += count;
+		if (rq->offset >= rq->len)
+			rq->offset = 0;
 		err = 0;
 	}
  out:
-	if (rp->offset == 0) {
-		/* need to release rq */
+	if (rq->offset == 0) {
+		filp->private_data = NULL;
 		spin_lock(&queue_lock);
-		rq->readers--;
-		if (rq->readers == 0 &&
-		    !test_bit(CACHE_PENDING, &rq->item->flags)) {
-			list_del(&rq->q.list);
-			spin_unlock(&queue_lock);
+		if (!test_bit(CACHE_PENDING, &rq->item->flags)) {
 			cache_put(rq->item, cd);
 			kfree(rq->buf);
 			kfree(rq);
 		} else
-			spin_unlock(&queue_lock);
+			list_add_tail(&rq->list, queue);
+		spin_unlock(&queue_lock);
 	}
 	if (err == -EAGAIN)
 		goto again;
@@ -808,26 +785,19 @@ static unsigned int
 cache_poll(struct file *filp, poll_table *wait)
 {
 	unsigned int mask;
-	struct cache_reader *rp = filp->private_data;
-	struct cache_queue *cq;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+	struct list_head *queue = &cd->queue;
 
 	poll_wait(filp, &queue_wait, wait);
 
 	/* alway allow write */
 	mask = POLL_OUT | POLLWRNORM;
 
-	if (!rp)
-		return mask;
-
 	spin_lock(&queue_lock);
 
-	for (cq= &rp->q; &cq->list != &cd->queue;
-	     cq = list_entry(cq->list.next, struct cache_queue, list))
-		if (!cq->reader) {
-			mask |= POLLIN | POLLRDNORM;
-			break;
-		}
+	if (filp->private_data || !list_empty(queue))
+		mask |= POLLIN | POLLRDNORM;
+
 	spin_unlock(&queue_lock);
 	return mask;
 }
@@ -837,11 +807,11 @@ cache_ioctl(struct inode *ino, struct file *filp,
 	    unsigned int cmd, unsigned long arg)
 {
 	int len = 0;
-	struct cache_reader *rp = filp->private_data;
-	struct cache_queue *cq;
+	struct cache_request *rq = filp->private_data;
 	struct cache_detail *cd = PDE(ino)->data;
+	struct list_head *queue = &cd->queue;
 
-	if (cmd != FIONREAD || !rp)
+	if (cmd != FIONREAD)
 		return -EINVAL;
 
 	spin_lock(&queue_lock);
@@ -849,14 +819,11 @@ cache_ioctl(struct inode *ino, struct file *filp,
 	/* only find the length remaining in current request,
 	 * or the length of the next request
 	 */
-	for (cq= &rp->q; &cq->list != &cd->queue;
-	     cq = list_entry(cq->list.next, struct cache_queue, list))
-		if (!cq->reader) {
-			struct cache_request *cr =
-				container_of(cq, struct cache_request, q);
-			len = cr->len - rp->offset;
-			break;
-		}
+	if (!rq)
+		rq = list_first_entry(queue, struct cache_request, list);
+	if (rq)
+		len = rq->len - rq->offset;
+
 	spin_unlock(&queue_lock);
 
 	return put_user(len, (int __user *)arg);
@@ -865,51 +832,33 @@ cache_ioctl(struct inode *ino, struct file *filp,
 static int
 cache_open(struct inode *inode, struct file *filp)
 {
-	struct cache_reader *rp = NULL;
-
 	nonseekable_open(inode, filp);
 	if (filp->f_mode & FMODE_READ) {
 		struct cache_detail *cd = PDE(inode)->data;
 
-		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
-		if (!rp)
-			return -ENOMEM;
-		rp->offset = 0;
-		rp->q.reader = 1;
 		atomic_inc(&cd->readers);
-		spin_lock(&queue_lock);
-		list_add(&rp->q.list, &cd->queue);
-		spin_unlock(&queue_lock);
 	}
-	filp->private_data = rp;
+	filp->private_data = NULL;
 	return 0;
 }
 
 static int
 cache_release(struct inode *inode, struct file *filp)
 {
-	struct cache_reader *rp = filp->private_data;
+	struct cache_request *rq = filp->private_data;
 	struct cache_detail *cd = PDE(inode)->data;
+	struct list_head *queue = &cd->queue;
+
+	filp->private_data = NULL;
 
-	if (rp) {
+	if (rq) {
+		rq->offset = 0;
 		spin_lock(&queue_lock);
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
+		list_add_tail(&rq->list, queue);
 		spin_unlock(&queue_lock);
 
-		filp->private_data = NULL;
-		kfree(rp);
-
+	}
+	if (filp->f_mode & FMODE_READ) {
 		cd->last_close = get_seconds();
 		atomic_dec(&cd->readers);
 	}
@@ -932,20 +881,15 @@ static const struct file_operations cache_file_operations = {
 
 static void queue_loose(struct cache_detail *detail, struct cache_head *ch)
 {
-	struct cache_queue *cq;
+	struct cache_request *rq;
 	spin_lock(&queue_lock);
-	list_for_each_entry(cq, &detail->queue, list)
-		if (!cq->reader) {
-			struct cache_request *cr = container_of(cq, struct cache_request, q);
-			if (cr->item != ch)
-				continue;
-			if (cr->readers != 0)
-				continue;
-			list_del(&cr->q.list);
+	list_for_each_entry(rq, &detail->queue, list)
+		if (rq->item  == ch) {
+			list_del(&rq->list);
 			spin_unlock(&queue_lock);
-			cache_put(cr->item, detail);
-			kfree(cr->buf);
-			kfree(cr);
+			cache_put(rq->item, detail);
+			kfree(rq->buf);
+			kfree(rq);
 			return;
 		}
 	spin_unlock(&queue_lock);
@@ -1074,13 +1018,12 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h)
 		kfree(crq);
 		return -EAGAIN;
 	}
-	crq->q.reader = 0;
 	crq->item = cache_get(h);
 	crq->buf = buf;
 	crq->len = PAGE_SIZE - len;
-	crq->readers = 0;
+	crq->offset = 0;
 	spin_lock(&queue_lock);
-	list_add_tail(&crq->q.list, &detail->queue);
+	list_add_tail(&crq->list, &detail->queue);
 	spin_unlock(&queue_lock);
 	wake_up(&queue_wait);
 	return 0;
