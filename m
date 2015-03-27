Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37299 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbC0REC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:04:02 -0400
Received: by igcxg11 with SMTP id xg11so25545164igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:04:01 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs: Refactor pnfs_set_layoutcommit()
Date: Fri, 27 Mar 2015 13:03:59 -0400
Message-Id: <1427475839-14572-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_set_layoutcommit() and pnfs_commit_set_layoutcommit() are 100% identical
except for the function arguments. Refactor to eliminate the difference.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         |  5 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 ++--
 fs/nfs/pnfs.c                          | 43 ++++++----------------------------
 fs/nfs/pnfs.h                          |  3 +--
 4 files changed, 14 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 5639a2ef671a..a317b007e436 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -258,7 +258,8 @@ filelayout_set_layoutcommit(struct nfs_pgio_header *hdr)
 	    hdr->res.verf->committed != NFS_DATA_SYNC)
 		return;
 
-	pnfs_set_layoutcommit(hdr);
+	pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
+			hdr->mds_offset + hdr->res.count);
 	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
@@ -373,7 +374,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 	}
 
 	if (data->verf.committed == NFS_UNSTABLE)
-		pnfs_commit_set_layoutcommit(data);
+		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
 }
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index edfb27ea4ce2..92d2943e54f8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -891,7 +891,8 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 static void
 ff_layout_set_layoutcommit(struct nfs_pgio_header *hdr)
 {
-	pnfs_set_layoutcommit(hdr);
+	pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
+			hdr->mds_offset + hdr->res.count);
 	dprintk("%s inode %lu pls_end_pos %lu\n", __func__, hdr->inode->i_ino,
 		(unsigned long) NFS_I(hdr->inode)->layout->plh_lwb);
 }
@@ -1074,7 +1075,7 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	}
 
 	if (data->verf.committed == NFS_UNSTABLE)
-		pnfs_commit_set_layoutcommit(data);
+		pnfs_set_layoutcommit(data->inode, data->lseg, data->lwb);
 
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b96736df98e8..ea83f3c03c65 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1841,7 +1841,8 @@ void pnfs_ld_write_done(struct nfs_pgio_header *hdr)
 {
 	trace_nfs4_pnfs_write(hdr, hdr->pnfs_error);
 	if (!hdr->pnfs_error) {
-		pnfs_set_layoutcommit(hdr);
+		pnfs_set_layoutcommit(hdr->inode, hdr->lseg,
+				hdr->mds_offset + hdr->res.count);
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
 	} else
 		pnfs_ld_handle_write_error(hdr);
@@ -2099,11 +2100,10 @@ void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
 EXPORT_SYMBOL_GPL(pnfs_set_lo_fail);
 
 void
-pnfs_set_layoutcommit(struct nfs_pgio_header *hdr)
+pnfs_set_layoutcommit(struct inode *inode, struct pnfs_layout_segment *lseg,
+		loff_t end_pos)
 {
-	struct inode *inode = hdr->inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	loff_t end_pos = hdr->mds_offset + hdr->res.count;
 	bool mark_as_dirty = false;
 
 	spin_lock(&inode->i_lock);
@@ -2114,13 +2114,13 @@ pnfs_set_layoutcommit(struct nfs_pgio_header *hdr)
 			__func__, inode->i_ino);
 	} else if (end_pos > nfsi->layout->plh_lwb)
 		nfsi->layout->plh_lwb = end_pos;
-	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &hdr->lseg->pls_flags)) {
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags)) {
 		/* references matched in nfs4_layoutcommit_release */
-		pnfs_get_lseg(hdr->lseg);
+		pnfs_get_lseg(lseg);
 	}
 	spin_unlock(&inode->i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
-		__func__, hdr->lseg, nfsi->layout->plh_lwb);
+		__func__, lseg, nfsi->layout->plh_lwb);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -2129,35 +2129,6 @@ pnfs_set_layoutcommit(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
 
-void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data)
-{
-	struct inode *inode = data->inode;
-	struct nfs_inode *nfsi = NFS_I(inode);
-	bool mark_as_dirty = false;
-
-	spin_lock(&inode->i_lock);
-	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		nfsi->layout->plh_lwb = data->lwb;
-		mark_as_dirty = true;
-		dprintk("%s: Set layoutcommit for inode %lu ",
-			__func__, inode->i_ino);
-	} else if (data->lwb > nfsi->layout->plh_lwb)
-		nfsi->layout->plh_lwb = data->lwb;
-	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &data->lseg->pls_flags)) {
-		/* references matched in nfs4_layoutcommit_release */
-		pnfs_get_lseg(data->lseg);
-	}
-	spin_unlock(&inode->i_lock);
-	dprintk("%s: lseg %p end_pos %llu\n",
-		__func__, data->lseg, nfsi->layout->plh_lwb);
-
-	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
-	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
-	if (mark_as_dirty)
-		mark_inode_dirty_sync(inode);
-}
-EXPORT_SYMBOL_GPL(pnfs_commit_set_layoutcommit);
-
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data)
 {
 	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b5654e8da936..66bf5e1cf93d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -264,8 +264,7 @@ bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
 bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
-void pnfs_set_layoutcommit(struct nfs_pgio_header *);
-void pnfs_commit_set_layoutcommit(struct nfs_commit_data *data);
+void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
 int _pnfs_return_layout(struct inode *);
-- 
2.1.0

