From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] NFS: introduce writeback wait queue
Date: Sun, 4 Oct 2009 11:01:53 +0800
Message-ID: <20091004030153.GA20327@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: "jens.axboe@oracle.com" <jens.axboe@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757007AbZJDDCm@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic writeback routines are departing from congestion_wait()
in preference of get_request_wait(), aka. to wait on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages will grow out of control.

The SYNC writes can use the full queue space (2*nfs_congestion_kb), while
the ASYNC writes can only use half queue space. This way SYNC writes won't
be blocked by the ASYNC ones at all.

We'll be waiting inside the NFS_INO_FLUSHING lock, hence also be
blocking possible dirtiers.  This should not be a bit problem.
And we should be able to obsolete the NFS_INO_FLUSHING with more
general writeback improvements in long term.

CC: Jens Axboe <jens.axboe@oracle.com> 
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   73 +++++++++++++++++++++++++++++-------
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 62 insertions(+), 14 deletions(-)

--- linux.orig/fs/nfs/write.c	2009-10-04 08:47:16.000000000 +0800
+++ linux/fs/nfs/write.c	2009-10-04 10:55:32.000000000 +0800
@@ -189,24 +189,58 @@ static int wb_priority(struct writeback_
 
 int nfs_congestion_kb;
 
+/*
+ * SYNC requests will be blocked on NFS_SYNC_*_THRESH
+ * ASYNC requests will be blocked on NFS_CONGESTION_*_THRESH
+ */
+#define NFS_SYNC_WAIT_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-11))
+#define NFS_SYNC_WAKEUP_THRESH	\
+	(NFS_SYNC_WAIT_THRESH - (NFS_SYNC_WAIT_THRESH >> 2))
+
 #define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
 #define NFS_CONGESTION_OFF_THRESH	\
 	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
 
-static int nfs_set_page_writeback(struct page *page)
+static void nfs_writeback_wait(struct page *page, struct writeback_control *wbc)
 {
-	int ret = test_set_page_writeback(page);
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int is_sync = wbc->sync_mode == WB_SYNC_NONE;
+	DEFINE_WAIT(wait);
 
-	if (!ret) {
-		struct inode *inode = page->mapping->host;
-		struct nfs_server *nfss = NFS_SERVER(inode);
+	if (atomic_long_inc_return(&nfss->writeback) < NFS_CONGESTION_ON_THRESH)
+		return;
 
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+	set_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	if (is_sync && atomic_long_read(&nfss->writeback) <
+	    NFS_SYNC_WAIT_THRESH)
+		return;
+
+	for (;;) {
+		prepare_to_wait_exclusive(&nfss->writeback_wait[is_sync], &wait,
+					  TASK_UNINTERRUPTIBLE);
+
+		io_schedule();
+
+		finish_wait(&nfss->writeback_wait[is_sync], &wait);
+
+		if (atomic_long_read(&nfss->writeback) <
+		    NFS_CONGESTION_OFF_THRESH)
+			break;
+		if (is_sync && atomic_long_read(&nfss->writeback) <
+		    NFS_SYNC_WAKEUP_THRESH)
+			break;
 	}
+}
+
+static int nfs_set_page_writeback(struct page *page, struct writeback_control *wbc)
+{
+	int ret = test_set_page_writeback(page);
+
+	if (!ret)
+		nfs_writeback_wait(page, wbc);
+
 	return ret;
 }
 
@@ -216,8 +250,18 @@ static void nfs_end_page_writeback(struc
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	if (atomic_long_dec_return(&nfss->writeback) < NFS_SYNC_WAKEUP_THRESH) {
+		if (waitqueue_active(&nfss->writeback_wait[1]))
+			wake_up(&nfss->writeback_wait[1]);
+		if (atomic_long_read(&nfss->writeback) <
+		    NFS_CONGESTION_OFF_THRESH) {
+			clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+			if (waitqueue_active(&nfss->writeback_wait[0]))
+				wake_up(&nfss->writeback_wait[0]);
+		}
+	}
+
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page)
@@ -254,6 +298,7 @@ static struct nfs_page *nfs_find_and_loc
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
+				struct writeback_control *wbc,
 				struct page *page)
 {
 	struct nfs_page *req;
@@ -266,7 +311,7 @@ static int nfs_page_async_flush(struct n
 	if (IS_ERR(req))
 		goto out;
 
-	ret = nfs_set_page_writeback(page);
+	ret = nfs_set_page_writeback(page, wbc);
 	BUG_ON(ret != 0);
 	BUG_ON(test_bit(PG_CLEAN, &req->wb_flags));
 
@@ -286,7 +331,7 @@ static int nfs_do_writepage(struct page 
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
 	nfs_pageio_cond_complete(pgio, page->index);
-	return nfs_page_async_flush(pgio, page);
+	return nfs_page_async_flush(pgio, wbc, page);
 }
 
 /*
--- linux.orig/include/linux/nfs_fs_sb.h	2009-10-04 09:31:25.000000000 +0800
+++ linux/include/linux/nfs_fs_sb.h	2009-10-04 09:58:11.000000000 +0800
@@ -108,6 +108,7 @@ struct nfs_server {
 	struct nfs_iostats *	io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux.orig/fs/nfs/client.c	2009-10-04 09:59:46.000000000 +0800
+++ linux/fs/nfs/client.c	2009-10-04 10:00:55.000000000 +0800
@@ -991,6 +991,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->master_link);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
