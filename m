Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([143.182.124.21]:46027 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636Ab1KSMxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Nov 2011 07:53:03 -0500
Date: Sat, 19 Nov 2011 20:52:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Feng Tang <feng.tang@intel.com>
Subject: [PATCH] nfs: writeback pages wait queue
Message-ID: <20111119125253.GA5483@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The generic writeback routines are departing from congestion_wait()
in preference of get_request_wait(), aka. waiting on the block queues.

Introduce the missing writeback wait queue for NFS, otherwise its
writeback pages will grow greedily, exhausting all PG_dirty pages.

Tests show that it can effectively reduce stalls in the disk-network
pipeline, improve performance and reduce delays.

The test cases are basically

	for run in 1 2 3
	for nr_dd in 1 10 100
	for dirty_thresh in 10M 100M 1000M 2G
		start $nr_dd dd's writing to a 1-disk mem=12G NFS server

During all tests, nfs_congestion_kb is set to 1/8 dirty_thresh.

    3.2.0-rc1    3.2.0-rc1-ioless-full+
  (w/o patch)                (w/ patch)
  -----------  ------------------------
        20.66      +136.7%        48.90  thresh=1000M/nfs-100dd-1
        20.82      +147.5%        51.52  thresh=1000M/nfs-100dd-2
        20.57      +129.8%        47.26  thresh=1000M/nfs-100dd-3
        35.96       +96.5%        70.67  thresh=1000M/nfs-10dd-1
        37.47       +89.1%        70.85  thresh=1000M/nfs-10dd-2
        34.55      +106.1%        71.21  thresh=1000M/nfs-10dd-3
        58.24       +28.2%        74.63  thresh=1000M/nfs-1dd-1
        59.83       +18.6%        70.93  thresh=1000M/nfs-1dd-2
        58.30       +31.4%        76.61  thresh=1000M/nfs-1dd-3
        23.69       -10.0%        21.33  thresh=100M/nfs-100dd-1
        23.59        -1.7%        23.19  thresh=100M/nfs-100dd-2
        23.94        -1.0%        23.70  thresh=100M/nfs-100dd-3
        27.06        -0.0%        27.06  thresh=100M/nfs-10dd-1
        25.43        +4.8%        26.66  thresh=100M/nfs-10dd-2
        27.21        -0.8%        26.99  thresh=100M/nfs-10dd-3
        53.82        +4.4%        56.17  thresh=100M/nfs-1dd-1
        55.80        +4.2%        58.12  thresh=100M/nfs-1dd-2
        55.75        +2.9%        57.37  thresh=100M/nfs-1dd-3
        15.47        +1.3%        15.68  thresh=10M/nfs-10dd-1
        16.09        -3.5%        15.53  thresh=10M/nfs-10dd-2
        15.09        -0.9%        14.96  thresh=10M/nfs-10dd-3
        26.65       +13.0%        30.10  thresh=10M/nfs-1dd-1
        25.09        +7.7%        27.02  thresh=10M/nfs-1dd-2
        27.16        +3.3%        28.06  thresh=10M/nfs-1dd-3
        27.51       +78.6%        49.11  thresh=2G/nfs-100dd-1
        22.46      +131.6%        52.01  thresh=2G/nfs-100dd-2
        12.95      +289.8%        50.50  thresh=2G/nfs-100dd-3
        42.28       +81.0%        76.52  thresh=2G/nfs-10dd-1
        40.33       +78.8%        72.10  thresh=2G/nfs-10dd-2
        42.52       +67.6%        71.27  thresh=2G/nfs-10dd-3
        62.27       +34.6%        83.84  thresh=2G/nfs-1dd-1
        60.10       +35.6%        81.48  thresh=2G/nfs-1dd-2
        66.29       +17.5%        77.88  thresh=2G/nfs-1dd-3
      1164.97       +41.6%      1649.19  TOTAL write_bw

The local queue time for WRITE RPCs could be reduced by several orders!

    3.2.0-rc1    3.2.0-rc1-ioless-full+
  -----------  ------------------------
     90226.82       -99.9%        92.07  thresh=1000M/nfs-100dd-1
     88904.27       -99.9%        80.21  thresh=1000M/nfs-100dd-2
     97436.73       -99.9%        87.32  thresh=1000M/nfs-100dd-3
     62167.19       -99.3%       444.25  thresh=1000M/nfs-10dd-1
     64150.34       -99.2%       539.38  thresh=1000M/nfs-10dd-2
     78675.54       -99.3%       540.27  thresh=1000M/nfs-10dd-3
      5372.84       +57.8%      8477.45  thresh=1000M/nfs-1dd-1
     10245.66       -51.2%      4995.71  thresh=1000M/nfs-1dd-2
      4744.06      +109.1%      9919.55  thresh=1000M/nfs-1dd-3
      1727.29        -9.6%      1562.16  thresh=100M/nfs-100dd-1
      2183.49        +4.4%      2280.21  thresh=100M/nfs-100dd-2
      2201.49        +3.7%      2281.92  thresh=100M/nfs-100dd-3
      6213.73       +19.9%      7448.13  thresh=100M/nfs-10dd-1
      8127.01        +3.2%      8387.06  thresh=100M/nfs-10dd-2
      7255.35        +4.4%      7571.11  thresh=100M/nfs-10dd-3
      1144.67       +20.4%      1378.01  thresh=100M/nfs-1dd-1
      1010.02       +19.0%      1202.22  thresh=100M/nfs-1dd-2
       906.33       +15.8%      1049.76  thresh=100M/nfs-1dd-3
       642.82       +17.3%       753.80  thresh=10M/nfs-10dd-1
       766.82       -21.7%       600.18  thresh=10M/nfs-10dd-2
       575.95       +16.5%       670.85  thresh=10M/nfs-10dd-3
        21.91       +71.0%        37.47  thresh=10M/nfs-1dd-1
        16.70      +105.3%        34.29  thresh=10M/nfs-1dd-2
        19.05       -71.3%         5.47  thresh=10M/nfs-1dd-3
    123877.11       -99.0%      1187.27  thresh=2G/nfs-100dd-1
    122353.65       -98.8%      1505.84  thresh=2G/nfs-100dd-2
    101140.82       -98.4%      1641.03  thresh=2G/nfs-100dd-3
     78248.51       -98.9%       892.00  thresh=2G/nfs-10dd-1
     84589.42       -98.6%      1212.17  thresh=2G/nfs-10dd-2
     89684.95       -99.4%       495.28  thresh=2G/nfs-10dd-3
     10405.39        -6.9%      9684.57  thresh=2G/nfs-1dd-1
     16151.86       -48.5%      8316.69  thresh=2G/nfs-1dd-2
     16119.17       -49.0%      8214.84  thresh=2G/nfs-1dd-3
   1177306.98       -92.1%     93588.50  TOTAL nfs_write_queue_time

The average COMMIT size is not impacted too much.

    3.2.0-rc1    3.2.0-rc1-ioless-full+
  -----------  ------------------------
         5.56       +44.9%         8.06  thresh=1000M/nfs-100dd-1
         4.14      +109.1%         8.67  thresh=1000M/nfs-100dd-2
         5.46       +16.3%         6.35  thresh=1000M/nfs-100dd-3
        52.04        -8.4%        47.70  thresh=1000M/nfs-10dd-1
        52.33       -13.8%        45.09  thresh=1000M/nfs-10dd-2
        51.72        -9.2%        46.98  thresh=1000M/nfs-10dd-3
       484.63        -8.6%       443.16  thresh=1000M/nfs-1dd-1
       492.42        -8.2%       452.26  thresh=1000M/nfs-1dd-2
       493.13       -11.4%       437.15  thresh=1000M/nfs-1dd-3
        32.52       -72.9%         8.80  thresh=100M/nfs-100dd-1
        36.15       +26.1%        45.58  thresh=100M/nfs-100dd-2
        38.33        +0.4%        38.49  thresh=100M/nfs-100dd-3
         5.67        +0.5%         5.69  thresh=100M/nfs-10dd-1
         5.74        -1.1%         5.68  thresh=100M/nfs-10dd-2
         5.69        +0.9%         5.74  thresh=100M/nfs-10dd-3
        44.91        -1.0%        44.45  thresh=100M/nfs-1dd-1
        44.22        -0.6%        43.96  thresh=100M/nfs-1dd-2
        44.18        +0.2%        44.28  thresh=100M/nfs-1dd-3
         1.42        +1.1%         1.43  thresh=10M/nfs-10dd-1
         1.48        +0.3%         1.48  thresh=10M/nfs-10dd-2
         1.43        -1.0%         1.42  thresh=10M/nfs-10dd-3
         5.51        -6.8%         5.14  thresh=10M/nfs-1dd-1
         5.91        -8.1%         5.43  thresh=10M/nfs-1dd-2
         5.44        +3.0%         5.61  thresh=10M/nfs-1dd-3
         8.80        +6.6%         9.38  thresh=2G/nfs-100dd-1
         8.51       +65.2%        14.06  thresh=2G/nfs-100dd-2
        15.28       -13.2%        13.27  thresh=2G/nfs-100dd-3
       105.12       -24.9%        78.99  thresh=2G/nfs-10dd-1
       101.90        -9.1%        92.60  thresh=2G/nfs-10dd-2
       106.24       -29.7%        74.65  thresh=2G/nfs-10dd-3
       909.85        +0.4%       913.68  thresh=2G/nfs-1dd-1
      1030.45       -18.3%       841.68  thresh=2G/nfs-1dd-2
      1016.56       -11.6%       898.36  thresh=2G/nfs-1dd-3
      5222.74       -10.1%      4695.25  TOTAL nfs_commit_size

And here is the list of overall numbers.

    3.2.0-rc1    3.2.0-rc1-ioless-full+
  -----------  ------------------------
      1164.97       +41.6%      1649.19  TOTAL write_bw
     54799.00       +25.0%     68500.00  TOTAL nfs_nr_commits
   3543263.00        -3.3%   3425418.00  TOTAL nfs_nr_writes
      5222.74       -10.1%      4695.25  TOTAL nfs_commit_size
         7.62       +89.2%        14.42  TOTAL nfs_write_size
   1177306.98       -92.1%     93588.50  TOTAL nfs_write_queue_time
      5977.02       -16.0%      5019.34  TOTAL nfs_write_rtt_time
   1183360.15       -91.7%     98645.74  TOTAL nfs_write_execute_time
     51186.59       -62.5%     19170.98  TOTAL nfs_commit_queue_time
     81801.14        +3.6%     84735.19  TOTAL nfs_commit_rtt_time
    133015.32       -21.9%    103926.05  TOTAL nfs_commit_execute_time

Feng: do more coarse grained throttle on each ->writepages rather than
on each page, for better performance and avoid throttled-before-send-rpc
deadlock

Signed-off-by: Feng Tang <feng.tang@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c           |    2 
 fs/nfs/write.c            |   84 +++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |    1 
 3 files changed, 77 insertions(+), 10 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-10-20 23:45:59.000000000 +0800
@@ -190,11 +190,64 @@ static int wb_priority(struct writeback_
  * NFS congestion control
  */
 
+#define NFS_WAIT_PAGES	(1024L >> (PAGE_SHIFT - 10))
 int nfs_congestion_kb;
 
-#define NFS_CONGESTION_ON_THRESH 	(nfs_congestion_kb >> (PAGE_SHIFT-10))
-#define NFS_CONGESTION_OFF_THRESH	\
-	(NFS_CONGESTION_ON_THRESH - (NFS_CONGESTION_ON_THRESH >> 2))
+/*
+ * SYNC requests will block on (2*limit) and wakeup on (2*limit-NFS_WAIT_PAGES)
+ * ASYNC requests will block on (limit) and wakeup on (limit - NFS_WAIT_PAGES)
+ * In this way SYNC writes will never be blocked by ASYNC ones.
+ */
+
+static void nfs_set_congested(long nr, struct backing_dev_info *bdi)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr > limit && !test_bit(BDI_async_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_ASYNC);
+	else if (nr > 2 * limit && !test_bit(BDI_sync_congested, &bdi->state))
+		set_bdi_congested(bdi, BLK_RW_SYNC);
+}
+
+static void nfs_wait_congested(int is_sync,
+			       struct backing_dev_info *bdi,
+			       wait_queue_head_t *wqh)
+{
+	int waitbit = is_sync ? BDI_sync_congested : BDI_async_congested;
+	DEFINE_WAIT(wait);
+
+	if (!test_bit(waitbit, &bdi->state))
+		return;
+
+	for (;;) {
+		prepare_to_wait(&wqh[is_sync], &wait, TASK_UNINTERRUPTIBLE);
+		if (!test_bit(waitbit, &bdi->state))
+			break;
+
+		io_schedule();
+	}
+	finish_wait(&wqh[is_sync], &wait);
+}
+
+static void nfs_wakeup_congested(long nr,
+				 struct backing_dev_info *bdi,
+				 wait_queue_head_t *wqh)
+{
+	long limit = nfs_congestion_kb >> (PAGE_SHIFT - 10);
+
+	if (nr < 2 * limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_sync_congested, &bdi->state))
+			clear_bdi_congested(bdi, BLK_RW_SYNC);
+		if (waitqueue_active(&wqh[BLK_RW_SYNC]))
+			wake_up(&wqh[BLK_RW_SYNC]);
+	}
+	if (nr < limit - min(limit / 8, NFS_WAIT_PAGES)) {
+		if (test_bit(BDI_async_congested, &bdi->state))
+			clear_bdi_congested(bdi, BLK_RW_ASYNC);
+		if (waitqueue_active(&wqh[BLK_RW_ASYNC]))
+			wake_up(&wqh[BLK_RW_ASYNC]);
+	}
+}
 
 static int nfs_set_page_writeback(struct page *page)
 {
@@ -205,11 +258,8 @@ static int nfs_set_page_writeback(struct
 		struct nfs_server *nfss = NFS_SERVER(inode);
 
 		page_cache_get(page);
-		if (atomic_long_inc_return(&nfss->writeback) >
-				NFS_CONGESTION_ON_THRESH) {
-			set_bdi_congested(&nfss->backing_dev_info,
-						BLK_RW_ASYNC);
-		}
+		nfs_set_congested(atomic_long_inc_return(&nfss->writeback),
+				  &nfss->backing_dev_info);
 	}
 	return ret;
 }
@@ -221,8 +271,10 @@ static void nfs_end_page_writeback(struc
 
 	end_page_writeback(page);
 	page_cache_release(page);
-	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
-		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
+
+	nfs_wakeup_congested(atomic_long_dec_return(&nfss->writeback),
+			     &nfss->backing_dev_info,
+			     nfss->writeback_wait);
 }
 
 static struct nfs_page *nfs_find_and_lock_request(struct page *page, bool nonblock)
@@ -323,10 +375,17 @@ static int nfs_writepage_locked(struct p
 
 int nfs_writepage(struct page *page, struct writeback_control *wbc)
 {
+	struct inode *inode = page->mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int ret;
 
 	ret = nfs_writepage_locked(page, wbc);
 	unlock_page(page);
+
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	return ret;
 }
 
@@ -342,6 +401,7 @@ static int nfs_writepages_callback(struc
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	unsigned long *bitlock = &NFS_I(inode)->flags;
 	struct nfs_pageio_descriptor pgio;
 	int err;
@@ -358,6 +418,10 @@ int nfs_writepages(struct address_space 
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
+	nfs_wait_congested(wbc->sync_mode == WB_SYNC_ALL,
+			   &nfss->backing_dev_info,
+			   nfss->writeback_wait);
+
 	clear_bit_unlock(NFS_INO_FLUSHING, bitlock);
 	smp_mb__after_clear_bit();
 	wake_up_bit(bitlock, NFS_INO_FLUSHING);
--- linux-next.orig/include/linux/nfs_fs_sb.h	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/include/linux/nfs_fs_sb.h	2011-10-20 23:45:12.000000000 +0800
@@ -102,6 +102,7 @@ struct nfs_server {
 	struct nfs_iostats __percpu *io_stats;	/* I/O statistics */
 	struct backing_dev_info	backing_dev_info;
 	atomic_long_t		writeback;	/* number of writeback pages */
+	wait_queue_head_t	writeback_wait[2];
 	int			flags;		/* various flags */
 	unsigned int		caps;		/* server capabilities */
 	unsigned int		rsize;		/* read size */
--- linux-next.orig/fs/nfs/client.c	2011-10-20 23:08:17.000000000 +0800
+++ linux-next/fs/nfs/client.c	2011-10-20 23:45:12.000000000 +0800
@@ -1066,6 +1066,8 @@ static struct nfs_server *nfs_alloc_serv
 	INIT_LIST_HEAD(&server->layouts);
 
 	atomic_set(&server->active, 0);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_SYNC]);
+	init_waitqueue_head(&server->writeback_wait[BLK_RW_ASYNC]);
 
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
