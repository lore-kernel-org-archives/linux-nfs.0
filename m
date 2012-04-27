Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36842 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755074Ab2D0Vpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:36 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 13/13] NFSv4.1 resend LAYOUTGET on data server invalid layout errors
Date: Fri, 27 Apr 2012 17:53:53 -0400
Message-Id: <1335563633-7191-14-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
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
 fs/nfs/nfs4filelayout.c |   28 ++++++++++++++++++++++++----
 fs/nfs/nfs4filelayout.h |   13 +++++++++++++
 fs/nfs/pnfs.c           |    1 +
 fs/nfs/pnfs.h           |    1 +
 4 files changed, 39 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index eaaca89..474c630 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -182,6 +182,27 @@ static int filelayout_async_handle_error(struct rpc_task *task,
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
+		/*
+		 * Destroy layout so new i/o will get a new layout.
+		 * Layout will not be destroyed until all current lseg
+		 * references are put. Mark layout as invalid to resend failed
+		 * i/o and all i/o waiting on the slot table to the MDS until
+		 * layout is destroyed and a new valid layout is obtained.
+		 */
+		set_bit(NFS_LAYOUT_INVALID,
+				&NFS_I(state->inode)->layout->plh_flags);
+		pnfs_destroy_layout(NFS_I(state->inode));
+		rpc_wake_up(&tbl->slot_tbl_waitq);
+		goto reset;
 	/* RPC connection errors */
 	case -ECONNREFUSED:
 	case -EHOSTDOWN:
@@ -199,6 +220,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		nfs4_ds_disconnect(clp);
 		/* fall through */
 	default:
+reset:
 		dprintk("%s Retry through MDS. Error %d\n", __func__,
 			task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
@@ -263,9 +285,8 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 static void filelayout_read_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_read_data *rdata = data;
-	struct pnfs_layout_segment *lseg = rdata->header->lseg;
 
-	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg))) {
+	if (filelayout_reset_to_mds(rdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_read(rdata);
 		rpc_exit(task, 0);
@@ -366,9 +387,8 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 static void filelayout_write_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_write_data *wdata = data;
-	struct pnfs_layout_segment *lseg = wdata->header->lseg;
 
-	if (filelayout_test_devid_invalid(FILELAYOUT_DEVID_NODE(lseg))) {
+	if (filelayout_reset_to_mds(wdata->header->lseg)) {
 		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
 		filelayout_reset_write(wdata);
 		rpc_exit(task, 0);
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 95562ad..43fe802 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -129,11 +129,24 @@ filelayout_mark_devid_invalid(struct nfs4_deviceid_node *node)
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
index 98a7ec8..42af565 100644
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
index 681875d..549136a 100644
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

