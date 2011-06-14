Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51972 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1FNCcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:17 -0400
Message-Id: <e198ec9dedc784fbd2f53a6923d725b13d59c580.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 06/33] pnfs: cleanup_layoutcommit
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:14 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

This gives layout driver a chance to cleanup structures they put in.
Also ensure layoutcommit does not commit more than isize, as block layout
driver may dirty pages beyond EOF.

Signed-off-by: Andy Adamson <andros@netapp.com>
[fixup layout header pointer for layoutcommit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 fs/nfs/nfs4proc.c       |    1 +
 fs/nfs/nfs4xdr.c        |    3 ++-
 fs/nfs/pnfs.c           |   15 +++++++++++++++
 fs/nfs/pnfs.h           |    5 +++++
 include/linux/nfs_xdr.h |    1 +
 5 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04450bf..75c07f5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5887,6 +5887,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 
+	pnfs_cleanup_layoutcommit(data->args.inode, data);
 	/* Matched by references in pnfs_set_layoutcommit */
 	put_lseg(data->lseg);
 	put_rpccred(data->cred);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b8f375e..f884a23 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1963,7 +1963,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
+	p = xdr_encode_hyper(p, args->lastbytewritten+1); /* length */
 	*p++ = cpu_to_be32(0); /* reclaim */
 	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
@@ -5469,6 +5469,7 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
 	int status;
 
 	status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
+	res->status = status;
 	if (status)
 		return status;
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5373960..7912635 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1299,6 +1299,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
 	loff_t end_pos = wdata->mds_offset + wdata->res.count;
+	loff_t isize = i_size_read(wdata->inode);
 	bool mark_as_dirty = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
@@ -1312,9 +1313,13 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
+	if (end_pos > isize)
+		end_pos = isize;
 	if (end_pos > wdata->lseg->pls_end_pos)
 		wdata->lseg->pls_end_pos = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	dprintk("%s: lseg %p end_pos %llu\n",
+		__func__, wdata->lseg, wdata->lseg->pls_end_pos);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -1323,6 +1328,16 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
+void pnfs_cleanup_layoutcommit(struct inode *inode,
+			       struct nfs4_layoutcommit_data *data)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+
+	if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
+		nfss->pnfs_curr_ld->cleanup_layoutcommit(NFS_I(inode)->layout,
+							 data);
+}
+
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
 {
 	/* lseg refcounting handled directly in nfs_write_end */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 57aefb6..d7f203b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -128,6 +128,9 @@ struct pnfs_layoutdriver_type {
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutreturn_args *args);
 
+	void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
+				      struct nfs4_layoutcommit_data *data);
+
 	void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
 				     struct xdr_stream *xdr,
 				     const struct nfs4_layoutcommit_args *args);
@@ -216,6 +219,8 @@ void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
+void pnfs_cleanup_layoutcommit(struct inode *inode,
+			       struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
 int pnfs_ld_write_done(struct nfs_write_data *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 1fa6f7a..253b6d4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -269,6 +269,7 @@ struct nfs4_layoutcommit_res {
 	struct nfs_fattr *fattr;
 	const struct nfs_server *server;
 	struct nfs4_sequence_res seq_res;
+	int status;
 };
 
 struct nfs4_layoutcommit_data {
-- 
1.7.4.1

