From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/12] NFS: Cleanup - move nfs_write_inode() into
 fs/nfs/write.c
Date: Mon, 25 Jan 2010 17:15:45 -0500
Message-ID: <20100125221545.16750.58436.stgit@localhost.localdomain>
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
Received: from mx2.netapp.com ([216.240.18.37]:17544 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754266Ab0AYWjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:39:13 -0500
In-Reply-To: <20100125221544.16750.70574.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The sole purpose of nfs_write_inode is to commit unstable writes, so
move it into fs/nfs/write.c, and make nfs_commit_inode static.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |   12 ------------
 fs/nfs/write.c         |   24 +++++++++++++++++++++++-
 include/linux/nfs_fs.h |    7 -------
 3 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 302aa89..8341709 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -97,18 +97,6 @@ u64 nfs_compat_user_ino64(u64 fileid)
 	return ino;
 }
 
-int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
-{
-	int ret;
-
-	ret = nfs_commit_inode(inode,
-			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
-	if (ret >= 0)
-		return 0;
-	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
-	return ret;
-}
-
 void nfs_clear_inode(struct inode *inode)
 {
 	/*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7ba56f8..e2e7464 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1391,7 +1391,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
-int nfs_commit_inode(struct inode *inode, int how)
+static int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	int res;
@@ -1406,13 +1406,35 @@ int nfs_commit_inode(struct inode *inode, int how)
 	}
 	return res;
 }
+
+static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+{
+	int ret;
+
+	ret = nfs_commit_inode(inode,
+			wbc->sync_mode == WB_SYNC_ALL ? FLUSH_SYNC : 0);
+	if (ret >= 0)
+		return 0;
+	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
+	return ret;
+}
 #else
 static inline int nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 {
 	return 0;
 }
+
+static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+{
+	return 0;
+}
 #endif
 
+int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
+{
+	return nfs_commit_unstable_pages(inode, wbc);
+}
+
 long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_control *wbc, int how)
 {
 	struct inode *inode = mapping->host;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d09db1b..384ea3e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -483,15 +483,8 @@ extern int nfs_wb_nocommit(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
-#else
-static inline int
-nfs_commit_inode(struct inode *inode, int how)
-{
-	return 0;
-}
 #endif
 
 static inline int

