Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34847 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756434Ab0KNSMr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 13:12:47 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/2] pnfs-submit: handle NFS4ERR_DELEG_REVOKED for LAYOUTRETURN
Date: Sun, 14 Nov 2010 20:12:41 +0200
Message-Id: <1289758361-25204-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1289744517-27949-1-git-send-email-bhalevy@panasas.com>
References: <1289744517-27949-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When getting NFS4ERR_DELEG_REVOKED just clear the lseg list.
If this was part of a singular LAYOUTRETURN call, simulate success
(for now).  If this was part of return on close, retry the close
compound without sending LAYOUTCOMMIT nor LAYOUTRETURN.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   40 +++++++++++++++++++++++++++++++++++++---
 fs/nfs/pnfs.c     |    6 ++++--
 fs/nfs/pnfs.h     |    3 +++
 3 files changed, 44 insertions(+), 5 deletions(-)

Untested yet...

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 76b3c7d..7aa902d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1880,6 +1880,17 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			nfs4_close_clear_stateid_flags(state,
 					calldata->arg.fmode);
 			break;
+		case -NFS4ERR_DELEG_REVOKED:
+			if (calldata->res.op_bitmask & (NFS4_HAS_LAYOUTCOMMIT |
+							NFS4_HAS_LAYOUTRETURN)) {
+				set_bit(NFS_LAYOUT_REVOKED,
+					&NFS_I(calldata->inode)->layout->plh_flags);
+				/* Retry without layout operations as
+				 * pnfs_roc will find roc_iomode==0 next time around
+				 */
+				rpc_restart_call_prepare(task);
+				break;
+			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_BAD_STATEID:
@@ -5639,6 +5650,7 @@ void nfs4_layoutreturn_set_stateid(struct inode *ino,
 static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
+	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server;
 
 	dprintk("--> %s\n", __func__);
@@ -5647,28 +5659,50 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
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
+			set_bit(NFS_LAYOUT_REVOKED, &NFS_I(ino)->layout->plh_flags);
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
index e553311..471813a 100644
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
-- 
1.7.2.3

