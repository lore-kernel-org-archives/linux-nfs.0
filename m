From: andros@netapp.com
Subject: [PATCH 09/10] SQUASHME pnfs_submit: remove unused threshold calculations
Date: Wed, 12 May 2010 10:44:21 -0400
Message-ID: <1273675462-15758-10-git-send-email-andros@netapp.com>
References: <1273675462-15758-1-git-send-email-andros@netapp.com>
 <1273675462-15758-2-git-send-email-andros@netapp.com>
 <1273675462-15758-3-git-send-email-andros@netapp.com>
 <1273675462-15758-4-git-send-email-andros@netapp.com>
 <1273675462-15758-5-git-send-email-andros@netapp.com>
 <1273675462-15758-6-git-send-email-andros@netapp.com>
 <1273675462-15758-7-git-send-email-andros@netapp.com>
 <1273675462-15758-8-git-send-email-andros@netapp.com>
 <1273675462-15758-9-git-send-email-andros@netapp.com>
Cc: iisaman@netapp.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3866 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755295Ab0ELOpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 10:45:03 -0400
In-Reply-To: <1273675462-15758-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

All layoutdrivers returned -1 or 0 for both get_read_threshold and
get_write_threshold policy operations. Remove the threshold policy ops and
the related helper functions.

Squash into: " pnfs: I/O size helpers"

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   98 ---------------------------------------------
 fs/nfs/pnfs.h             |    3 -
 include/linux/nfs4_pnfs.h |    6 ---
 3 files changed, 0 insertions(+), 107 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9276bf8..03308f0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1272,49 +1272,6 @@ out:
 	return status;
 }
 
-size_t
-pnfs_getthreshold(struct inode *inode, int iswrite)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
-	ssize_t threshold = 0;
-
-	if (!pnfs_enabled_sb(nfss) ||
-	    !nfss->pnfs_curr_ld->ld_policy_ops)
-		goto out;
-
-	if (iswrite && nfss->pnfs_curr_ld->ld_policy_ops->get_write_threshold) {
-		threshold = nfss->pnfs_curr_ld->ld_policy_ops->
-				get_write_threshold(&nfsi->layout, inode);
-		goto out;
-	}
-
-	if (!iswrite && nfss->pnfs_curr_ld->ld_policy_ops->get_read_threshold) {
-		threshold = nfss->pnfs_curr_ld->ld_policy_ops->
-				get_read_threshold(&nfsi->layout, inode);
-	}
-out:
-	return threshold;
-}
-
-/*
- * Ask the layout driver for the request size at which pNFS should be used
- * or standard NFSv4 I/O.  Writing directly to the NFSv4 server can
- * improve performance through its singularity and async behavior to
- * the underlying parallel file system.
- */
-static int
-below_threshold(struct inode *inode, size_t req_size, int iswrite)
-{
-	ssize_t threshold;
-
-	threshold = pnfs_getthreshold(inode, iswrite);
-	if ((ssize_t)req_size <= threshold)
-		return 1;
-	else
-		return 0;
-}
-
 void
 readahead_range(struct inode *inode, struct list_head *pages, loff_t *offset,
 		size_t *count)
@@ -1510,61 +1467,6 @@ pnfs_update_layout_commit(struct inode *inode,
 	dprintk("%s  virt update status %d\n", __func__, status);
 }
 
-/* This is utilized in the paging system to determine if
- * it should use the NFSv4 or pNFS read path.
- * If count < 0, we do not check the I/O size.
- */
-int
-pnfs_use_read(struct inode *inode, ssize_t count)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	/* Use NFSv4 I/O if there is no layout driver OR
-	 * count is below the threshold.
-	 */
-	if (!pnfs_enabled_sb(nfss) ||
-	    (count >= 0 && below_threshold(inode, count, 0)))
-		return 0;
-
-	return 1; /* use pNFS I/O */
-}
-
-/* Called only from pnfs4 nfs_rpc_ops => a layout driver is loaded */
-int
-pnfs_use_ds_io(struct list_head *head, struct inode *inode, int io)
-{
-	struct nfs_page	*req;
-	struct list_head *pos, *tmp;
-	int count = 0;
-
-	list_for_each_safe(pos, tmp, head) {
-		req = nfs_list_entry(head->next);
-		count += req->wb_bytes;
-	}
-	if (count >= 0 && below_threshold(inode, count, io))
-		return 0;
-	return 1; /* use pNFS data server I/O */
-}
-
-/* This is utilized in the paging system to determine if
- * it should use the NFSv4 or pNFS write path.
- * If count < 0, we do not check the I/O size.
- */
-int
-pnfs_use_write(struct inode *inode, ssize_t count)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-
-	/* Use NFSv4 I/O if there is no layout driver OR
-	 * count is below the threshold.
-	 */
-	if (!pnfs_enabled_sb(nfss) ||
-	    (count >= 0 && below_threshold(inode, count, 1)))
-		return 0;
-
-	return 1; /* use pNFS I/O */
-}
-
 static int
 pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b80157b..2475db3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -40,9 +40,6 @@ int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			enum pnfs_layoutreturn_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
-int pnfs_use_read(struct inode *inode, ssize_t count);
-int pnfs_use_ds_io(struct list_head *, struct inode *, int);
-int pnfs_use_write(struct inode *inode, ssize_t count);
 enum pnfs_try_status _pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
 enum pnfs_try_status _pnfs_try_to_read_data(struct nfs_read_data *,
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d9631de..4d47b48 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -182,12 +182,6 @@ struct layoutdriver_policy_operations {
 
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
-
-	/* Read requests under this value are sent to the NFSv4 server */
-	ssize_t (*get_read_threshold) (struct pnfs_layout_type *, struct inode *);
-
-	/* Write requests under this value are sent to the NFSv4 server */
-	ssize_t (*get_write_threshold) (struct pnfs_layout_type *, struct inode *);
 };
 
 /* Should the full nfs rpc cleanup code be used after io */
-- 
1.6.6

