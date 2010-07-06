From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 2/6] SQUASME pnfs-submit: Collapse pnfs_try_to_read_data code path and avoid big fat inlines
Date: Tue,  6 Jul 2010 16:57:20 +0300
Message-ID: <1278424640-22303-1-git-send-email-bharrosh@panasas.com>
References: <4C3334E3.7070600@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Fred Isaman <iisaman@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5661 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753272Ab0GFN5X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 09:57:23 -0400
In-Reply-To: <4C3334E3.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Collapse the intire pnfs_try_to_read_data call chain into a single
function call.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/pnfs.c |   29 +++++++++++------------------
 fs/nfs/pnfs.h |   19 +------------------
 fs/nfs/read.c |    3 ++-
 3 files changed, 14 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b7b1738..d9c7a6b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1614,24 +1614,24 @@ pnfs_read_done(struct nfs_read_data *data)
  * If no I/O device driver exists, or one does match the returned
  * fstype, then return a positive status for regular NFS processing.
  */
-static enum pnfs_try_status
-pnfs_readpages(struct nfs_read_data *rdata)
+enum pnfs_try_status
+pnfs_try_to_read_data(struct nfs_read_data *rdata,
+		       const struct rpc_call_ops *call_ops)
 {
 	struct nfs_readargs *args = &rdata->args;
 	struct inode *inode = rdata->inode;
 	int numpages, pgcount, temp;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg = rdata->req->wb_lseg;
 	enum pnfs_try_status trypnfs;
 
+	rdata->pdata.call_ops = call_ops;
+	rdata->pdata.pnfs_error = 0;
+
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
-		__func__,
-		inode->i_ino,
-		args->count,
-		args->offset);
+		__func__, inode->i_ino, args->count, args->offset);
 
-	lseg = rdata->req->wb_lseg;
 	get_lseg(lseg);
 
 	/* Determine number of pages. */
@@ -1658,21 +1658,14 @@ pnfs_readpages(struct nfs_read_data *rdata)
 		rdata->pdata.pnfsflags &= ~PNFS_NO_RPC;
 		rdata->pdata.lseg = NULL;
 		put_lseg(lseg);
+		_pnfs_clear_lseg_from_pages(&rdata->pages);
+	} else {
+		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
 	}
 	dprintk("%s End (trypnfs:%d)\n", __func__, trypnfs);
 	return trypnfs;
 }
 
-enum pnfs_try_status
-_pnfs_try_to_read_data(struct nfs_read_data *data,
-		       const struct rpc_call_ops *call_ops)
-{
-	dprintk("%s: Utilizing pNFS I/O\n", __func__);
-	data->pdata.call_ops = call_ops;
-	data->pdata.pnfs_error = 0;
-	return pnfs_readpages(data);
-}
-
 /*
  * This gives the layout driver an opportunity to read in page "around"
  * the data to be written.  It returns 0 on success, otherwise an error code
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 91e892b..20ebe3f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -46,7 +46,7 @@ void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *mntfh, u32
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
-enum pnfs_try_status _pnfs_try_to_read_data(struct nfs_read_data *,
+enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
 					    const struct rpc_call_ops *);
 int pnfs_initialize(void);
 void pnfs_uninitialize(void);
@@ -118,23 +118,6 @@ static inline int pnfs_grow_ok(struct pnfs_layout_segment *lseg,
 }
 
 static inline enum pnfs_try_status
-pnfs_try_to_read_data(struct nfs_read_data *data,
-		      const struct rpc_call_ops *call_ops)
-{
-	struct inode *inode = data->inode;
-	enum pnfs_try_status ret;
-
-	if (!data->req->wb_lseg)
-		return PNFS_NOT_ATTEMPTED;
-	ret = _pnfs_try_to_read_data(data, call_ops);
-	if (ret == PNFS_ATTEMPTED)
-		nfs_inc_stats(inode, NFSIOS_PNFS_READ);
-	else
-		_pnfs_clear_lseg_from_pages(&data->pages);
-	return ret;
-}
-
-static inline enum pnfs_try_status
 pnfs_try_to_commit(struct nfs_write_data *data,
 		   const struct rpc_call_ops *call_ops,
 		   int how)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 204d738..1bcab47 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -204,7 +204,8 @@ EXPORT_SYMBOL(nfs_initiate_read);
 int pnfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops)
 {
-	if (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED)
+	if (data->req->wb_lseg &&
+	    (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED))
 		return pnfs_get_read_status(data);
 
 	return nfs_initiate_read(data, clnt, call_ops);
-- 
1.6.6.1

