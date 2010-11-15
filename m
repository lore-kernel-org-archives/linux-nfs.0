Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:46905 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab0KOMyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Nov 2010 07:54:12 -0500
Received: from daytona.int.panasas.com (daytona.int.panasas.com [172.17.28.41])
	by natasha.panasas.com (8.13.1/8.13.1) with ESMTP id oAFCsBf8019910
	for <linux-nfs@vger.kernel.org>; Mon, 15 Nov 2010 07:54:11 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2 v2] pnfs-submit: handle NFS4ERR_DELEG_REVOKED for LAYOUTRETURN
Date: Mon, 15 Nov 2010 14:54:07 +0200
Message-Id: <1289825647-19839-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1289758361-25204-1-git-send-email-bhalevy@panasas.com>
References: <1289758361-25204-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When getting NFS4ERR_DELEG_REVOKED just clear the lseg list.
If this was part of a singular LAYOUTRETURN call, simulate success
(for now).  If this was part of return on close, retry the close
compound without sending LAYOUTCOMMIT nor LAYOUTRETURN.

[use helper for pnfs_mark_layout_revoked to support !CONFIG_NFS_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   39 ++++++++++++++++++++++++++++++++++++---
 fs/nfs/pnfs.c     |    6 ++++--
 fs/nfs/pnfs.h     |   14 ++++++++++++++
 3 files changed, 54 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 76b3c7d..55505e4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1880,6 +1880,16 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			nfs4_close_clear_stateid_flags(state,
 					calldata->arg.fmode);
 			break;
+		case -NFS4ERR_DELEG_REVOKED:
+			if (calldata->res.op_bitmask & (NFS4_HAS_LAYOUTCOMMIT |
+							NFS4_HAS_LAYOUTRETURN)) {
+				pnfs_mark_layout_revoked(calldata->inode);
+				/* Retry without layout operations as
+				 * pnfs_roc will find roc_iomode==0 next time around
+				 */
+				rpc_restart_call_prepare(task);
+				break;
+			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_BAD_STATEID:
@@ -5639,6 +5649,7 @@ void nfs4_layoutreturn_set_stateid(struct inode *ino,
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
+	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server;
 
 	dprintk("--> %s\n", __func__);
@@ -5647,28 +5658,50 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 		return;
 
 	if (lrp->args.return_type == RETURN_FILE)
-		server = NFS_SERVER(lrp->args.inode);
+		server = NFS_SERVER(ino);
 	else
 		server = NULL;
 	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN) {
 		nfs_restart_rpc(task, lrp->clp);
 		return;
 	}
-	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE))
-		nfs4_layoutreturn_set_stateid(lrp->args.inode, &lrp->res);
+	switch (task->tk_status) {
+	case -NFS4ERR_DELEG_REVOKED:
+		task->tk_status = 0;	/* TODO: revalidate remaining layouts? */
+		if (lrp->args.return_type == RETURN_FILE)
+			pnfs_mark_layout_revoked(ino);
+		break;
+	case 0:
+		if (lrp->args.return_type == RETURN_FILE)
+			nfs4_layoutreturn_set_stateid(lrp->args.inode, &lrp->res);
+	}
 	dprintk("<-- %s\n", __func__);
 }
 
 void nfs4_layoutreturn_file_release(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
+	LIST_HEAD(tmp_list);
 
 	spin_lock(&ino->i_lock);
+	if (test_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags)) {
+		struct pnfs_layout_range range = {
+			.iomode = IOMODE_ANY,
+			.offset = 0,
+			.length = NFS4_MAX_UINT64,
+		};
+
+		/* layout driver's free_lseg may block, hence we don't
+		 * call pnfs_free_lseg_list under the spin_lock */
+		pnfs_clear_lseg_list(lo, &tmp_list, &range);
+		clear_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags);
+	}
 	lo->plh_block_lgets--;
 	lo->plh_outstanding--;
 	if (!pnfs_layoutgets_blocked(lo, NULL))
 		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&tmp_list);
 	put_layout_hdr(ino);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 90a868b..0b7fc1d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -375,7 +375,7 @@ static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 	}
 }
 
-static void
+void
 pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		     struct pnfs_layout_range *range)
 {
@@ -644,10 +644,12 @@ pnfs_roc(struct nfs4_closedata *data)
 	spin_lock(&data->inode->i_lock);
 	lo = NFS_I(data->inode)->layout;
 	if (!lo || lo->roc_iomode == 0 ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+	    test_bit(NFS_LAYOUT_REVOKED, &lo->plh_flags))
 		goto out_nolayout;
 
 	range.iomode = lo->roc_iomode;
+	lo->roc_iomode = 0;
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, &range)) {
 			mark_lseg_invalid(lseg, &tmp_list);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e553311..c5b4282 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -56,6 +56,7 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_NEED_LCOMMIT,	/* LAYOUTCOMMIT needed */
+	NFS_LAYOUT_REVOKED,		/* layout revoked by the server */
 };
 
 /* Per-layout driver specific registration structure */
@@ -223,6 +224,8 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
+void pnfs_clear_lseg_list(struct pnfs_layout_hdr *, struct list_head *tmp_list,
+			  struct pnfs_layout_range *);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
@@ -297,6 +300,12 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 	       test_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->plh_flags);
 }
 
+static inline void
+pnfs_mark_layout_revoked(struct inode *ino)
+{
+	set_bit(NFS_LAYOUT_REVOKED, &NFS_I(ino)->layout->plh_flags);
+}
+
 #else  /* CONFIG_NFS_V4_1 */
 
 static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
@@ -423,6 +432,11 @@ static inline void nfs4_layoutreturn_set_stateid(struct inode *ino,
 {
 }
 
+static inline void
+pnfs_mark_layout_revoked(struct inode *ino)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
-- 
1.7.2.3

