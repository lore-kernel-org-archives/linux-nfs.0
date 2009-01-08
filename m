From: Greg Banks <gnb@sgi.com>
Subject: [patch 09/14] sunrpc: Remove the global lock queue_io_mutex.
Date: Thu, 08 Jan 2009 19:25:19 +1100
Message-ID: <20090108082604.299840000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:44996 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753389AbZAHI0L (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This lock was used for two different purposes in two places.  The use
in cache_read() is redundant because cd->queue_lock is also taken
and can be removed without harm.  The use in cache_write() protects a
global buffer which can be eliminated and replaced with a temporarily
allocated page; this also removes an unnecessary global bottleneck
when multiple rpc.mountd threads are writing down into the kernel.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 net/sunrpc/cache.c |   34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -674,8 +674,6 @@ void cache_clean_deferred(void *owner)
  *
  */
 
-static DEFINE_MUTEX(queue_io_mutex);
-
 struct cache_queue {
 	struct list_head	list;
 	int			reader;	/* if 0, then request */
@@ -703,8 +701,6 @@ cache_read(struct file *filp, char __use
 	if (count == 0)
 		return 0;
 
-	mutex_lock(&queue_io_mutex); /* protect against multiple concurrent
-			      * readers on this file */
  again:
 	spin_lock(&cd->queue_lock);
 	/* need to find next request */
@@ -716,7 +712,6 @@ cache_read(struct file *filp, char __use
 	}
 	if (rp->q.list.next == &cd->queue) {
 		spin_unlock(&cd->queue_lock);
-		mutex_unlock(&queue_io_mutex);
 		BUG_ON(rp->offset);
 		return 0;
 	}
@@ -763,37 +758,38 @@ cache_read(struct file *filp, char __use
 	}
 	if (err == -EAGAIN)
 		goto again;
-	mutex_unlock(&queue_io_mutex);
 	return err ? err :  count;
 }
 
-static char write_buf[8192]; /* protected by queue_io_mutex */
-
 static ssize_t
 cache_write(struct file *filp, const char __user *buf, size_t count,
 	    loff_t *ppos)
 {
 	int err;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
+	char *tmp;
+	int tmp_size = PAGE_SIZE;
 
 	if (count == 0)
 		return 0;
-	if (count >= sizeof(write_buf))
+	if (count >= tmp_size)
 		return -EINVAL;
 
-	mutex_lock(&queue_io_mutex);
+	tmp = kmalloc(tmp_size, GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
 
-	if (copy_from_user(write_buf, buf, count)) {
-		mutex_unlock(&queue_io_mutex);
-		return -EFAULT;
-	}
-	write_buf[count] = '\0';
+	err = -EFAULT;
+	if (copy_from_user(tmp, buf, count))
+		goto out;
+
+	tmp[count] = '\0';
+	err = -EINVAL;
 	if (cd->cache_parse)
-		err = cd->cache_parse(cd, write_buf, count);
-	else
-		err = -EINVAL;
+		err = cd->cache_parse(cd, tmp, count);
 
-	mutex_unlock(&queue_io_mutex);
+out:
+	kfree(tmp);
 	return err ? err : count;
 }
 

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
