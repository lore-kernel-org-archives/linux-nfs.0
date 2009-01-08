From: Greg Banks <gnb@sgi.com>
Subject: [patch 08/14] sunrpc: Make the global queue_wait per-cache-detail.
Date: Thu, 08 Jan 2009 19:25:18 +1100
Message-ID: <20090108082604.086042000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:54352 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753381AbZAHI0L (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The file descriptor on which we wait is per-cache_detail, so it
makes some sense to put the polling infrastructure there too.
Plus, with multiple wait queues it's easier to pick apart the data
structures in coredumps to figure out which process is polling on
which caches.  This makes a big difference when debugging problems
with the multi-threaded rpc.mountd.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/cache.h |    2 ++
 net/sunrpc/cache.c           |    7 +++----
 2 files changed, 5 insertions(+), 4 deletions(-)

Index: bfields/include/linux/sunrpc/cache.h
===================================================================
--- bfields.orig/include/linux/sunrpc/cache.h
+++ bfields/include/linux/sunrpc/cache.h
@@ -98,6 +98,8 @@ struct cache_detail {
 	/* fields for communication over channel */
 	spinlock_t		queue_lock;
 	struct list_head	queue;
+	wait_queue_head_t	queue_wait;
+
 	struct proc_dir_entry	*proc_ent;
 	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent;
 
Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -360,6 +360,7 @@ int cache_register(struct cache_detail *
 		return ret;
 	rwlock_init(&cd->hash_lock);
 	spin_lock_init(&cd->queue_lock);
+	init_waitqueue_head(&cd->queue_wait);
 	INIT_LIST_HEAD(&cd->queue);
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
@@ -796,8 +797,6 @@ cache_write(struct file *filp, const cha
 	return err ? err : count;
 }
 
-static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
-
 static unsigned int
 cache_poll(struct file *filp, poll_table *wait)
 {
@@ -806,7 +805,7 @@ cache_poll(struct file *filp, poll_table
 	struct cache_queue *cq;
 	struct cache_detail *cd = PDE(filp->f_path.dentry->d_inode)->data;
 
-	poll_wait(filp, &queue_wait, wait);
+	poll_wait(filp, &cd->queue_wait, wait);
 
 	/* alway allow write */
 	mask = POLL_OUT | POLLWRNORM;
@@ -1076,7 +1075,7 @@ static int cache_make_upcall(struct cach
 	spin_lock(&cd->queue_lock);
 	list_add_tail(&rq->q.list, &cd->queue);
 	spin_unlock(&cd->queue_lock);
-	wake_up(&queue_wait);
+	wake_up(&cd->queue_wait);
 	return 0;
 }
 

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
