Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6496 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752409Ab1DVIFj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:05:39 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] SQUASHME: remove range from nfs4_layoutreturn_args
Date: Fri, 22 Apr 2011 11:05:24 +0300
Message-Id: <1303459524-16433-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DB125BD.3040703@panasas.com>
References: <4DB125BD.3040703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently we always return the layout for the whole file.

squash into "pnfs: layoutreturn" and "pnfs: layoutret_on_setattr"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c          |    2 +-
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/nfs4xdr.c        |    6 +++---
 fs/nfs/pnfs.c           |   26 ++++++++++----------------
 fs/nfs/pnfs.h           |   10 ++++------
 include/linux/nfs_xdr.h |    1 -
 6 files changed, 19 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9a48d1c..e9c6d9f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1426,7 +1426,7 @@ void nfs4_evict_inode(struct inode *inode)
 {
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
-	pnfs_return_layout(inode, NULL);
+	pnfs_return_layout(inode);
 	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 059a74c..801121f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2333,7 +2333,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
-		pnfs_return_layout(inode, NULL);
+		pnfs_return_layout(inode);
 
 	nfs_fattr_init(fattr);
 	
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 8c0e589..7e77a03 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1962,11 +1962,11 @@ encode_layoutreturn(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
 	*p++ = cpu_to_be32(args->reclaim);
 	*p++ = cpu_to_be32(args->layout_type);
-	*p++ = cpu_to_be32(args->range.iomode);
+	*p++ = cpu_to_be32(IOMODE_ANY);
 	*p = cpu_to_be32(RETURN_FILE);
 	p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
-	p = xdr_encode_hyper(p, args->range.offset);
-	p = xdr_encode_hyper(p, args->range.length);
+	p = xdr_encode_hyper(p, 0);
+	p = xdr_encode_hyper(p, NFS4_MAX_UINT64);
 	spin_lock(&args->inode->i_lock);
 	memcpy(stateid.data, NFS_I(args->inode)->layout->plh_stateid.data, NFS4_STATEID_SIZE);
 	spin_unlock(&args->inode->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b2066d2..ec2418b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -416,21 +416,22 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
  * Must be called under the i_lock (unless from the nfs4_evict_inode path)
  */
 static bool
-pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
-		     struct pnfs_layout_range *range)
+pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
 {
 	struct pnfs_layout_segment *lseg, *next;
+	struct pnfs_layout_range range = {
+		.iomode = IOMODE_ANY,
+		.length = NFS4_MAX_UINT64,
+	};
 	bool rv = false;
 
-	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
-		__func__, lo, range->offset, range->length, range->iomode);
 	if (list_empty(&lo->plh_segs)) {
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
 			put_layout_hdr_locked(lo);
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (should_free_lseg(&lseg->pls_range, range)) {
+		if (should_free_lseg(&lseg->pls_range, &range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode,
@@ -439,7 +440,6 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 			mark_lseg_invalid(lseg, tmp_list);
 			rv = true;
 		}
-	dprintk("%s:Return %d\n", __func__, rv);
 	return rv;
 }
 
@@ -667,7 +667,7 @@ out_err_free:
 }
 
 static int
-return_layout(struct inode *ino, struct pnfs_layout_range *range)
+return_layout(struct inode *ino)
 {
 	struct nfs4_layoutreturn *lrp;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -682,7 +682,6 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range)
 	}
 	lrp->args.reclaim = 0;
 	lrp->args.layout_type = server->pnfs_curr_ld->id;
-	lrp->args.range = *range;
 	lrp->args.inode = ino;
 	lrp->clp = server->nfs_client;
 
@@ -694,23 +693,18 @@ out:
 
 /* Initiates a LAYOUTRETURN(FILE) */
 int
-_pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range)
+_pnfs_return_layout(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo = NULL;
 	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_range arg;
 	LIST_HEAD(tmp_list);
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
 
-	arg.iomode = range ? range->iomode : IOMODE_ANY;
-	arg.offset = 0;
-	arg.length = NFS4_MAX_UINT64;
-
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo || !pnfs_clear_lseg_list(lo, &tmp_list, &arg)) {
+	if (!lo || !pnfs_clear_lseg_list(lo, &tmp_list)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: no layout segments to return\n", __func__);
 		goto out;
@@ -725,7 +719,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range)
 	if (status)
 		dprintk("%s: layoutcommit failed, status=%d. Returning layout anyway\n",
 			__func__, status);
-	status = return_layout(ino, &arg);
+	status = return_layout(ino);
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b5d1d22..2c8da75 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -202,7 +202,7 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
-int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *);
+int _pnfs_return_layout(struct inode *);
 int pnfs_write_done(struct nfs_write_data *);
 int pnfs_read_done(struct nfs_read_data *);
 
@@ -283,14 +283,13 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
 		PNFS_LAYOUTRET_ON_SETATTR;
 }
 
-static inline int pnfs_return_layout(struct inode *ino,
-				     struct pnfs_layout_range *range)
+static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *nfss = NFS_SERVER(ino);
 
 	if (pnfs_enabled_sb(nfss) && nfsi->layout)
-		return _pnfs_return_layout(ino, range);
+		return _pnfs_return_layout(ino);
 
 	return 0;
 }
@@ -336,8 +335,7 @@ pnfs_try_to_write_data(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-static inline int pnfs_return_layout(struct inode *ino,
-				     struct pnfs_layout_range *range)
+static inline int pnfs_return_layout(struct inode *ino)
 {
 	return 0;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 6506432..2bd48a2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -272,7 +272,6 @@ struct nfs4_layoutcommit_data {
 struct nfs4_layoutreturn_args {
 	__u32   reclaim;
 	__u32   layout_type;
-	struct pnfs_layout_range range;
 	struct inode *inode;
 	struct nfs4_sequence_args seq_args;
 };
-- 
1.7.3.4

