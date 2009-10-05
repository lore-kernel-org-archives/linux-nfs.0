From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH v2] NFS: introduce writeback wait queue
Date: Mon, 5 Oct 2009 15:10:26 +0800
Message-ID: <20091005071026.GA19262@localhost>
References: <20091004030153.GA20327@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mason <chris.mason@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: "jens.axboe@oracle.com" <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44093 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756918AbZJEHLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2009 03:11:19 -0400
In-Reply-To: <20091004030153.GA20327@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

This version makes two standalone functions for easier reuse.

Before patch, nr_writeback is near 1G on my 2GB laptop:

     nr_writeback         nr_dirty      nr_unstable
           203994                2           154469
           203994                2           154469

After patch, nr_writeback is limited to nfs_congestion_kb=42MB.

     nr_writeback         nr_dirty      nr_unstable
            11180            34195            11754
             9865            36821             8234
            10137            36695             9338

One minor problem I noticed is, NFS writeback is not very smooth.
This per 0.1s sampled trace shows that it can sometimes stuck for
up to 0.5s:

     nr_writeback         nr_dirty      nr_unstable
            11055            37408             9599
            10311            37315            10529
            10869            35920            11459
            10869            35920            11459
            10869            35920            11459
            10869            35920            11459
            10869            35920            11459
            10838            35891            10042
            10466            35891            10414
            10900            34744            11437
            10249            34744            12088
            10249            34744            12088
            10249            34744            12088
            10249            34744            12088
            10249            34744            12088
            10249            34744            12088
            10133            34743            10663
            10505            34743            11035
            10970            34991            11345
            10691            34991            11593
            10691            34991            11593
            10691            34991            11593
            10691            34991            11593
            10691            34991            11593

Trond, I guess nr_writeback/nr_unstable are decreased in async RPC
"complete" events. It is understandable that nr_dirty can sometimes
stuck on local waits, but the "local determined" nr_dirty and "remote
determined" nr_writeback/nr_unstable tend to stuck at the same time?
Did I miss something (that could be obvious to you)?

Thanks,
Fengguang
---
Subject: NFS: introduce writeback wait queue

The generic writeback routines are departing from congestion_wait()
in preferance of get_request_wait(), aka. waiting on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages will grow out of control.

CC: Jens Axboe <jens.axboe@oracle.com> 
CC: Chris Mason <chris.mason@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   86 ++++++++++++++++++++++++++++--------
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 72 insertions(+), 17 deletions(-)

--- linux.orig/fs/nfs/write.c	2009-10-05 13:27:20.000000000 +0800
+++ linux/fs/nfs/write.c	2009-10-05 14:48:39.000000000 +0800
@@ -189,24 +189,72 @@ static int wb_priority(struct writeback_
 
 int nfs_congestion_kb;
 
-#define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
-#define NFS_CONGESTION_OFF_THRESH	\
-	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
+/*
+ * SYNC requests will be blocked on (2*limit) and wakeup on (2*limit - limit/8)
+ * ASYNC requests will be blocked on (limit) and wakeup on (limit - limit/8)
+ * In this way SYNC writes will never be blocked by ASYNC ones.
+ */
 
-static int nfs_set_page_writeback(struct page *page)
+static void nfs_writeback_wait(atomic_long_t *nr, long limit, int is_sync,
+			       struct backing_dev_info *bdi,
+			       wait_queue_head_t *wqh)
 {
-	int ret = test_set_page_writeback(page);
+	DEFINE_WAIT(wait);
+	int hard_limit = limit * 2;
 
-	if (!ret) {
-		struct inode *inode = page->mapping->host;
-		struct nfs_server *nfss = NFS_SERVER(inode);
+	if (atomic_long_read(nr) <= limit)
+		return;
+
+	set_bdi_congested(bdi, BLK_RW_ASYNC);
 
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
+	if (is_sync && atomic_long_read(nr) <= hard_limit)
+		return;
+
+	for (;;) {
+		prepare_to_wait(&wqh[is_sync], &wait, TASK_UNINTERRUPTIBLE);
+
+		io_schedule();
+
+		if (atomic_long_read(nr) <= limit - limit/8)
+			break;
+		if (is_sync && atomic_long_read(nr) <= hard_limit - limit/8)
+			break;
+	}
+	finish_wait(&wqh[is_sync], &wait);
+}
+
+static void nfs_writeback_wakeup(long nr, long limit,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	int hard_limit = limit * 2;
+
+	if (nr < hard_limit - limit/8) {
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+		if (nr < limit - limit/8) {
+			clear_bdi_congested(bdi, BLK_RW_ASYNC);
+			if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
+				wake_up(&wqh[BLK_RW_ASYNC]);
 		}
 	}
+}
+
+static int nfs_set_page_writeback(struct page *page,
+				  struct writeback_control *wbc)
+{
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int ret = test_set_page_writeback(page);
+
+	if (!ret) {
+		atomic_long_inc(&nfss->writeback);
+		nfs_writeback_wait(&nfss->writeback,
+				   nfs_congestion_kb >> (PAGE_SHIFT-10),
+				   wbc->sync_mode == WB_SYNC_ALL,
+				   &nfss->backing_dev_info,
+				   nfss->writeback_wait);
+	}
 	return ret;
 }
 
@@ -216,8 +264,11 @@ static void nfs_end_page_writeback(struc
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	end_page_writeback(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_writeback_wakeup(atomic_long_dec_return(&nfss->writeback),
+			     nfs_congestion_kb >> (PAGE_SHIFT-10),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page)
@@ -254,7 +305,8 @@ static struct nfs_page *nfs_find_and_loc
  * May return an error if the user signalled nfs_wait_on_request().
  */
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
-				struct page *page)
+				struct page *page,
+				struct writeback_control *wbc)
 {
 	struct nfs_page *req;
 	int ret = 0;
@@ -266,7 +318,7 @@ static int nfs_page_async_flush(struct n
 	if (IS_ERR(req))
 		goto out;
 
-	ret = nfs_set_page_writeback(page);
+	ret = nfs_set_page_writeback(page, wbc);
 	BUG_ON(ret != 0);
 	BUG_ON(test_bit(PG_CLEAN, &req->wb_flags));
 
@@ -286,7 +338,7 @@ static int nfs_do_writepage(struct page 
 	nfs_add_stats(inode, NFSIOS_WRITEPAGES, 1);
 
 	nfs_pageio_cond_complete(pgio, page->index);
-	return nfs_page_async_flush(pgio, page);
+	return nfs_page_async_flush(pgio, page, wbc);
 }
 
 /*
--- linux.orig/include/linux/nfs_fs_sb.h	2009-10-05 13:27:20.000000000 +0800
+++ linux/include/linux/nfs_fs_sb.h	2009-10-05 13:28:31.000000000 +0800
@@ -108,6 +108,7 @@ struct nfs_server {
 	struct nfs_iostats *	io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux.orig/fs/nfs/client.c	2009-10-05 13:27:20.000000000 +0800
+++ linux/fs/nfs/client.c	2009-10-05 13:28:31.000000000 +0800
@@ -991,6 +991,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->master_link);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
