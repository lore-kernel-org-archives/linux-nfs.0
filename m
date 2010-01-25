From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/12] NFS: Replace __nfs_write_mapping with sync_inode()
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.63968.stgit@localhost.localdomain>
References: <20100125221544.16750.70574.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259Ab0AYWjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:12 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we have correct COMMIT semantics in writeback_single_inode...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c         |   39 ++++++---------------------------------
 include/linux/nfs_fs.h |    1 -
 2 files changed, 6 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53df027..747b40e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1443,7 +1443,6 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	pgoff_t idx_start, idx_end;
 	unsigned int npages = 0;
 	LIST_HEAD(head);
-	int nocommit = how & FLUSH_NOCOMMIT;
 	long pages, ret;
 
 	/* FIXME */
@@ -1460,14 +1459,11 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 				npages = 0;
 		}
 	}
-	how &= ~FLUSH_NOCOMMIT;
 	spin_lock(&inode->i_lock);
 	do {
 		ret = nfs_wait_on_requests_locked(inode, idx_start, npages);
 		if (ret != 0)
 			continue;
-		if (nocommit)
-			break;
 		pages = nfs_scan_commit(inode, &head, idx_start, npages);
 		if (pages == 0)
 			break;
@@ -1481,47 +1477,24 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	return ret;
 }
 
-static int __nfs_write_mapping(struct address_space *mapping, struct writeback_control *wbc, int how)
-{
-	int ret;
-
-	ret = nfs_writepages(mapping, wbc);
-	if (ret < 0)
-		goto out;
-	ret = nfs_sync_mapping_wait(mapping, wbc, how);
-	if (ret < 0)
-		goto out;
-	return 0;
-out:
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
-	return ret;
-}
-
-/* Two pass sync: first using WB_SYNC_NONE, then WB_SYNC_ALL */
-static int nfs_write_mapping(struct address_space *mapping, int how)
+/*
+ * flush the inode to disk.
+ */
+int nfs_wb_all(struct inode *inode)
 {
 	struct writeback_control wbc = {
-		.bdi = mapping->backing_dev_info,
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
 		.range_start = 0,
 		.range_end = LLONG_MAX,
 	};
 
-	return __nfs_write_mapping(mapping, &wbc, how);
-}
-
-/*
- * flush the inode to disk.
- */
-int nfs_wb_all(struct inode *inode)
-{
-	return nfs_write_mapping(inode->i_mapping, 0);
+	return sync_inode(inode, &wbc);
 }
 
 int nfs_wb_nocommit(struct inode *inode)
 {
-	return nfs_write_mapping(inode->i_mapping, FLUSH_NOCOMMIT);
+	return filemap_write_and_wait(inode->i_mapping);
 }
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1eec414..c536caf 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -33,7 +33,6 @@
 #define FLUSH_STABLE		4	/* commit to stable storage */
 #define FLUSH_LOWPRI		8	/* low priority background flush */
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
-#define FLUSH_NOCOMMIT		32	/* Don't send the NFSv3/v4 COMMIT */
 
 #ifdef __KERNEL__
 

