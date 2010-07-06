From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 1/6] SQUASME pnfs-submit: Collapse pnfs_try_to_write_data code path and avoid big fat inlines
Date: Tue,  6 Jul 2010 16:56:46 +0300
Message-ID: <1278424606-22270-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46197 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752766Ab0GFN4t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 09:56:49 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need to stutter, just say what you want in one simple sentence.

The thing that triggered this marvellous cleanup was that I did not like the
un-necessary pnfs_try_to_write_data inline. It appears that much more was
at stake.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c  |   40 ++++++++++++++++------------------------
 fs/nfs/pnfs.h  |   20 +-------------------
 fs/nfs/write.c |    3 ++-
 3 files changed, 19 insertions(+), 44 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c78e39c..b7b1738 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1522,24 +1522,25 @@ pnfs_writeback_done(struct nfs_write_data *data)
  * in data->res.verf->committed.  Do we need this ability
  * for non-file layout drivers?
  */
-static enum pnfs_try_status
-pnfs_writepages(struct nfs_write_data *wdata, int how)
+enum pnfs_try_status
+pnfs_try_to_write_data(struct nfs_write_data *wdata,
+			const struct rpc_call_ops *call_ops, int how)
 {
 	struct nfs_writeargs *args = &wdata->args;
 	struct inode *inode = wdata->inode;
-	int numpages;
 	enum pnfs_try_status trypnfs;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg = wdata->req->wb_lseg;
+	int numpages;
 
-	dprintk("%s: Writing ino:%lu %u@%llu\n",
-		__func__,
-		inode->i_ino,
-		args->count,
-		args->offset);
+	wdata->pdata.call_ops = call_ops;
+	wdata->pdata.pnfs_error = 0;
+	wdata->pdata.how = how;
+
+	dprintk("%s: Writing ino:%lu %u@%llu\n", __func__,
+		inode->i_ino, args->count, args->offset);
 
-	lseg = wdata->req->wb_lseg;
 	get_lseg(lseg);
 
 	/* Determine number of pages
@@ -1547,9 +1548,8 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 	numpages = nfs_page_array_len(args->pgbase, args->count);
 
 	dprintk("%s: Calling layout driver (how %d) write with %d pages\n",
-		__func__,
-		how,
-		numpages);
+		__func__, how, numpages);
+
 	if (!pnfs_use_rpc(nfss))
 		wdata->pdata.pnfsflags |= PNFS_NO_RPC;
 	wdata->pdata.lseg = lseg;
@@ -1567,6 +1567,9 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		wdata->pdata.pnfsflags &= ~PNFS_NO_RPC;
 		wdata->pdata.lseg = NULL;
 		put_lseg(lseg);
+		_pnfs_clear_lseg_from_pages(&wdata->pages);
+	} else {
+		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
 	}
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
@@ -1720,17 +1723,6 @@ int _pnfs_write_end(struct inode *inode, struct page *page,
 }
 
 enum pnfs_try_status
-_pnfs_try_to_write_data(struct nfs_write_data *data,
-			const struct rpc_call_ops *call_ops, int how)
-{
-	dprintk("--> %s\n", __func__);
-	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
-	data->pdata.how = how;
-	return pnfs_writepages(data, how);
-}
-
-enum pnfs_try_status
 _pnfs_try_to_commit(struct nfs_write_data *data,
 		    const struct rpc_call_ops *call_ops, int how)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 940ca68..91e892b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -44,7 +44,7 @@ int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *mntfh, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
-enum pnfs_try_status _pnfs_try_to_write_data(struct nfs_write_data *,
+enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
 enum pnfs_try_status _pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
@@ -135,24 +135,6 @@ pnfs_try_to_read_data(struct nfs_read_data *data,
 }
 
 static inline enum pnfs_try_status
-pnfs_try_to_write_data(struct nfs_write_data *data,
-		       const struct rpc_call_ops *call_ops,
-		       int how)
-{
-	struct inode *inode = data->inode;
-	enum pnfs_try_status ret;
-
-	if (!data->req->wb_lseg)
-		return PNFS_NOT_ATTEMPTED;
-	ret = _pnfs_try_to_write_data(data, call_ops, how);
-	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(inode, NFSIOS_PNFS_WRITE);
-	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
-	return ret;
-}
-
-static inline enum pnfs_try_status
 pnfs_try_to_commit(struct nfs_write_data *data,
 		   const struct rpc_call_ops *call_ops,
 		   int how)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f61c861..fd20fd5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -852,7 +852,8 @@ int pnfs_initiate_write(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops,
 			int how)
 {
-	if (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED)
+	if (data->req->wb_lseg &&
+	    (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED))
 		return pnfs_get_write_status(data);
 
 	return nfs_initiate_write(data, clnt, call_ops, how);
-- 
1.6.6.1

