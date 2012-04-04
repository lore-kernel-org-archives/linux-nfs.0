Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756702Ab2DDUXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Apr 2012 16:23:18 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 resend LAYOUTGET on data server invalid layout errors
Date: Wed,  4 Apr 2012 16:22:37 -0400
Message-Id: <1333570957-2008-2-git-send-email-andros@netapp.com>
In-Reply-To: <1333570957-2008-1-git-send-email-andros@netapp.com>
References: <1333570957-2008-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The "invalid layout" class of errors is handled by destroying the layout and
getting a new layout from the server.  Currently, the layout must be
destroyed before a new layout can be obtained.

This means that all references (e.g.lsegs) to the "to be destroyed" layout
header must be dropped before it can be destroyed. This in turn means waiting
for all in flight RPC's using the old layout as well as draining the data
server session slot table wait queue.

Set the NFS_LAYOUT_INVALID flag to redirect I/O to the MDS while waiting for
the old layout to be destroyed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   27 +++++++++++++++++++++++----
 fs/nfs/nfs4filelayout.h |   13 +++++++++++++
 fs/nfs/pnfs.c           |    1 +
 fs/nfs/pnfs.h           |    1 +
 4 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index a8932a5..f7d2273 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -162,6 +162,25 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		break;
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		break;
+	/* Invalidate Layout errors */
+	case -NFS4ERR_PNFS_NO_LAYOUT:
+	case -ESTALE:           /* mapped NFS4ERR_STALE */
+	case -EBADHANDLE:       /* mapped NFS4ERR_BADHANDLE */
+	case -EISDIR:           /* mapped NFS4ERR_ISDIR */
+	case -NFS4ERR_FHEXPIRED:
+	case -NFS4ERR_WRONG_TYPE:
+		dprintk("%s Invalid layout error %d\n", __func__,
+			task->tk_status);
+		/* Destroy layout so new i/o will get a new layout.
+		 * Layout will not be destroyed until all current lseg
+		 * references are put. Resend failed i/o and all i/o
+		 * waiting on the slot table to the MDS. Mark
+		 * layout as invaid until it is destroyed */
+		set_bit(NFS_LAYOUT_INVALID,
+				&NFS_I(state->inode)->layout->plh_flags);
+		pnfs_destroy_layout(NFS_I(state->inode));
+		rpc_wake_up(&tbl->slot_tbl_waitq);
+		goto reset;
 	/* RPC connection errors */
 	case -ECONNREFUSED:
 	case -EHOSTDOWN:
@@ -177,6 +196,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		nfs4_ds_disconnect(clp);
 		/* fall through */
 	default:
+reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
@@ -240,7 +260,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = (struct nfs_read_data *)data;
 
-	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(rdata->lseg))) {
+	if (filelayout_reset_to_mds(rdata->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_read(task, rdata);
 		rpc_restart_call_prepare(task);
@@ -341,7 +361,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = (struct nfs_write_data *)data;
 
-	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(wdata->lseg))) {
+	if (filelayout_reset_to_mds(wdata->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_write(task, wdata);
 		rpc_restart_call_prepare(task);
@@ -882,11 +902,10 @@ filelayout_choose_commit_list(struct nfs_page *req,
 			      struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
-	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	u32 i, j;
 	struct list_head *list;
 
-	if (fl->commit_through_mds || filelayout_test_devid_invalid(devid))
+	if (fl->commit_through_mds || filelayout_reset_to_mds(lseg))
 		return &NFS_I(req->wb_context->dentry->d_inode)->commit_list;
 
 	/* Note that we are calling nfs4_fl_calc_j_index on each page
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index ff86c86..5a2a70c 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -118,11 +118,24 @@ filelayout_mark_devid_invalid(struct nfs4_deviceid_node *node)
 }
 
 static inline bool
+filelayout_test_layout_invalid(struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS_LAYOUT_INVALID, &lo->plh_flags);
+}
+
+static inline bool
 filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
 {
 	return test_bit(NFS_DEVICEID_INVALID, &node->flags);
 }
 
+static inline bool
+filelayout_reset_to_mds(struct pnfs_layout_segment *lseg)
+{
+	return filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg)) ||
+		filelayout_test_layout_invalid(lseg->pls_layout);
+}
+
 extern struct nfs_fh *
 nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, u32 j);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b5d4515..751e54e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -455,6 +455,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 }
+EXPORT_SYMBOL_GPL(pnfs_destroy_layout);
 
 /*
  * Called by the state manger to remove all layouts established under an
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3bd7e87..e599b5c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -63,6 +63,7 @@ enum {
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
+	NFS_LAYOUT_INVALID,		/* layout is being destroyed */
 };
 
 enum layoutdriver_policy_flags {
-- 
1.7.6.4

