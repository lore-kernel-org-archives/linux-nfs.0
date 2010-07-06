From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 3/6] SQUASME pnfs-submit: Collapse pnfs_try_to_commit code path and avoid big fat inlines
Date: Tue,  6 Jul 2010 17:05:08 +0300
Message-ID: <1278425108-22400-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33562 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752225Ab0GFOFL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 10:05:11 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Collapse the intire pnfs_try_to_commit call chain into a single
function call.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |   26 +++++++++++---------------
 fs/nfs/pnfs.h |   23 +----------------------
 2 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9c7a6b..a30a8c3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -59,7 +59,6 @@ static int pnfs_initialized;
 
 static void pnfs_free_layout(struct pnfs_layout_type *lo,
 			     struct nfs4_pnfs_layout_segment *range);
-static enum pnfs_try_status pnfs_commit(struct nfs_write_data *data, int sync);
 static inline void get_layout(struct pnfs_layout_type *lo);
 
 /* Locking:
@@ -1715,17 +1714,6 @@ int _pnfs_write_end(struct inode *inode, struct page *page,
 	return status;
 }
 
-enum pnfs_try_status
-_pnfs_try_to_commit(struct nfs_write_data *data,
-		    const struct rpc_call_ops *call_ops, int how)
-{
-	dprintk("%s: Utilizing pNFS I/O\n", __func__);
-	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
-	data->pdata.how = how;
-	return pnfs_commit(data, how);
-}
-
 /* pNFS Commit callback function for all layout drivers */
 static void
 pnfs_commit_done(struct nfs_write_data *data)
@@ -1748,8 +1736,9 @@ pnfs_commit_done(struct nfs_write_data *data)
 	}
 }
 
-static enum pnfs_try_status
-pnfs_commit(struct nfs_write_data *data, int sync)
+enum pnfs_try_status
+pnfs_try_to_commit(struct nfs_write_data *data,
+		    const struct rpc_call_ops *call_ops, int sync)
 {
 	struct nfs_inode *nfsi = NFS_I(data->inode);
 	struct nfs_server *nfss = NFS_SERVER(data->inode);
@@ -1764,13 +1753,20 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	 * We still have to account for the possibility of some being NULL.
 	 * This will be done by passing the buck to the layout driver.
 	 */
+	data->pdata.call_ops = call_ops;
+	data->pdata.pnfs_error = 0;
+	data->pdata.how = sync;
 	data->pdata.lseg = NULL;
 	if (!pnfs_use_rpc(nfss))
 		data->pdata.pnfsflags |= PNFS_NO_RPC;
 	trypnfs = nfss->pnfs_curr_ld->ld_io_ops->commit(&nfsi->layout,
 							sync, data);
-	if (trypnfs == PNFS_NOT_ATTEMPTED)
+	if (trypnfs == PNFS_NOT_ATTEMPTED) {
 		data->pdata.pnfsflags &= ~PNFS_NO_RPC;
+		_pnfs_clear_lseg_from_pages(&data->pages);
+	} else {
+		nfs_inc_stats(data->inode, NFSIOS_PNFS_COMMIT);
+	}
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 20ebe3f..1a320f6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -57,7 +57,7 @@ void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
 unsigned int pnfs_getiosize(struct nfs_server *server);
 void pnfs_set_ds_iosize(struct nfs_server *server);
-enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
+enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
 					 const struct rpc_call_ops *, int);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *,
@@ -117,27 +117,6 @@ static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
 		!fsdata->bypass_eof;
 }
 
-static inline enum pnfs_try_status
-pnfs_try_to_commit(struct nfs_write_data *data,
-		   const struct rpc_call_ops *call_ops,
-		   int how)
-{
-	struct inode *inode = data->inode;
-	enum pnfs_try_status ret;
-
-	/* Unlike in pnfs_try_to_write_data and pnfs_try_to_read_data,
-	 * we have no guarantee that all nfs_pages point to the same
-	 * lseg.  However, if we reach here, we are guaranteed that at
-	 * least one points to some lseg.
-	 */
-	ret = _pnfs_try_to_commit(data, call_ops, how);
-	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(inode, NFSIOS_PNFS_COMMIT);
-	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
-	return ret;
-}
-
 static inline int pnfs_write_begin(struct file *filp, struct page *page,
 				   loff_t pos, unsigned len,
 				   struct pnfs_layout_segment *lseg,
-- 
1.6.6.1

