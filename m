Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:37289 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbaHGCPT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 22:15:19 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so4318920pdb.13
        for <linux-nfs@vger.kernel.org>; Wed, 06 Aug 2014 19:15:18 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/2] nfs41: add a helper function to set layoutcommit after commit
Date: Thu,  7 Aug 2014 10:15:02 +0800
Message-Id: <1407377703-6593-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Track lwb in nfs_commit_data so that we can use it to setup
layoutcommit in commit_done callback.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c           | 29 +++++++++++++++++++++++++++++
 fs/nfs/pnfs.h           |  1 +
 fs/nfs/write.c          | 15 +++++++++++++++
 include/linux/nfs_xdr.h |  1 +
 4 files changed, 46 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4e85315..f36aeef 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1797,6 +1797,35 @@ pnfs_set_layoutcommit(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
+void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data)
+{
+	struct inode *inode = data->inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	bool mark_as_dirty = false;
+
+	spin_lock(&inode->i_lock);
+	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		mark_as_dirty = true;
+		dprintk("%s: Set layoutcommit for inode %lu ",
+			__func__, inode->i_ino);
+	}
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &data->lseg->pls_flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		pnfs_get_lseg(data->lseg);
+	}
+	if (data->lwb > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = data->lwb;
+	spin_unlock(&inode->i_lock);
+	dprintk("%s: lseg %p end_pos %llu\n",
+		__func__, data->lseg, nfsi->layout->plh_lwb);
+
+	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
+	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
+	if (mark_as_dirty)
+		mark_inode_dirty_sync(inode);
+}
+EXPORT_SYMBOL_GPL(pnfs_commit_set_layoutcommit);
+
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 {
 	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aca3dff..79c6311 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -219,6 +219,7 @@ void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct nfs_pgio_header *);
+void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1065de2..79c1d6b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1525,6 +1525,18 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_commit);
 
+static loff_t nfs_get_lwb(struct list_head *head)
+{
+	loff_t lwb = 0;
+	struct nfs_page *req;
+
+	list_for_each_entry(req, head, wb_list)
+		if (lwb < (req_offset(req) + req->wb_bytes))
+			lwb = req_offset(req) + req->wb_bytes;
+
+	return lwb;
+}
+
 /*
  * Set up the argument/result storage required for the RPC call.
  */
@@ -1544,6 +1556,9 @@ void nfs_init_commit(struct nfs_commit_data *data,
 	data->inode	  = inode;
 	data->cred	  = first->wb_context->cred;
 	data->lseg	  = lseg; /* reference transferred */
+	/* only set lwb for pnfs commit */
+	if (lseg)
+		data->lwb = nfs_get_lwb(&data->pages);
 	data->mds_ops     = &nfs_commit_ops;
 	data->completion_ops = cinfo->completion_ops;
 	data->dreq	  = cinfo->dreq;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0040629..e563b2c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1328,6 +1328,7 @@ struct nfs_commit_data {
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
 	int			ds_commit_index;
+	loff_t			lwb;
 	const struct rpc_call_ops *mds_ops;
 	const struct nfs_commit_completion_ops *completion_ops;
 	int (*commit_done_cb) (struct rpc_task *task, struct nfs_commit_data *data);
-- 
1.9.1

