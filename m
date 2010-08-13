Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45275 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424Ab0HMVdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:33:20 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 41/50] pnfs_submit: signal layoutdriver commit
Date: Fri, 13 Aug 2010 17:31:53 -0400
Message-Id: <1281735122-1496-42-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-41-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
 <1281735122-1496-36-git-send-email-andros@netapp.com>
 <1281735122-1496-37-git-send-email-andros@netapp.com>
 <1281735122-1496-38-git-send-email-andros@netapp.com>
 <1281735122-1496-39-git-send-email-andros@netapp.com>
 <1281735122-1496-40-git-send-email-andros@netapp.com>
 <1281735122-1496-41-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pagelist.c        |    5 ++++-
 fs/nfs/write.c           |   12 +++++++-----
 include/linux/nfs_page.h |    3 ++-
 include/linux/nfs_xdr.h  |    2 ++
 4 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a014814..96e375e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -387,6 +387,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
  * @idx_start: lower bound of page->index to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  * @tag: tag to scan for
+ * @use_pnfs: will be set TRUE if commit needs to be handled by layout driver
  *
  * Moves elements from one of the inode request lists.
  * If the number of requests is set to 0, the entire address_space
@@ -396,7 +397,7 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
  */
 int nfs_scan_list(struct nfs_inode *nfsi,
 		struct list_head *dst, pgoff_t idx_start,
-		unsigned int npages, int tag)
+		  unsigned int npages, int tag, int *use_pnfs)
 {
 	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
 	struct nfs_page *req;
@@ -427,6 +428,8 @@ int nfs_scan_list(struct nfs_inode *nfsi,
 				radix_tree_tag_clear(&nfsi->nfs_page_tree,
 						req->wb_index, tag);
 				nfs_list_add_request(req, dst);
+				if (req->wb_lseg)
+					*use_pnfs = 1;
 				res++;
 				if (res == INT_MAX)
 					goto out;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fbc8657..18926d3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -546,7 +546,7 @@ nfs_need_commit(struct nfs_inode *nfsi)
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages)
+nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, unsigned int npages, int *use_pnfs)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int ret;
@@ -554,7 +554,8 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst, pgoff_t idx_start, u
 	if (!nfs_need_commit(nfsi))
 		return 0;
 
-	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT);
+	ret = nfs_scan_list(nfsi, dst, idx_start, npages, NFS_PAGE_TAG_COMMIT,
+			    use_pnfs);
 	if (ret > 0)
 		nfsi->ncommit -= ret;
 	if (nfs_need_commit(NFS_I(inode)))
@@ -1466,21 +1467,22 @@ int nfs_commit_inode(struct inode *inode, int how)
 	LIST_HEAD(head);
 	int may_wait = how & FLUSH_SYNC;
 	int res = 0;
+	int use_pnfs = 0;
 
 	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
 		goto out_mark_dirty;
 	spin_lock(&inode->i_lock);
-	res = nfs_scan_commit(inode, &head, 0, 0);
+	res = nfs_scan_commit(inode, &head, 0, 0, &use_pnfs);
 	spin_unlock(&inode->i_lock);
 	if (res) {
 		int error = nfs_commit_list(inode, &head, how);
 		if (error < 0)
 			return error;
-		if (may_wait)
+		if (may_wait) {
 			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
 					nfs_wait_bit_killable,
 					TASK_KILLABLE);
-		else
+		} else
 			goto out_mark_dirty;
 	} else
 		nfs_commit_clear_lock(NFS_I(inode));
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ce0a1a5..287ee81 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -83,7 +83,8 @@ extern	void nfs_release_request(struct nfs_page *req);
 
 
 extern	int nfs_scan_list(struct nfs_inode *nfsi, struct list_head *dst,
-			  pgoff_t idx_start, unsigned int npages, int tag);
+			  pgoff_t idx_start, unsigned int npages, int tag,
+			  int *use_pnfs);
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
 			     int (*doio)(struct inode *, struct list_head *, unsigned int, size_t, int),
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 544d282..e627788 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1012,6 +1012,8 @@ struct nfs_read_data {
 };
 
 struct nfs_write_data {
+	struct kref		refcount;	/* For pnfs commit splitting */
+	struct nfs_write_data	*parent;	/* For pnfs commit splitting */
 	int			flags;
 	struct rpc_task		task;
 	struct inode		*inode;
-- 
1.6.2.5

