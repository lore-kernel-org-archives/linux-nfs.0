Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43586 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754856Ab2JKUlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Oct 2012 16:41:05 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: Do not call pnfs_return_layout() from an rpciod context
Date: Thu, 11 Oct 2012 16:40:30 -0400
Message-Id: <1349988031-1122-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the call to pnfs_return_layout() to the read and write rpc_release()
callbacks, so that it gets called from nfsiod, which is a more appropriate
context.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 18 +++++++++++++++---
 fs/nfs/pnfs.h           |  1 +
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 816c2d0..e7aee56 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -122,12 +122,21 @@ static void filelayout_reset_read(struct nfs_read_data *data)
 	}
 }
 
+static void filelayout_fenceme(struct inode *inode, struct pnfs_layout_hdr *lo)
+{
+	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
+		return;
+	clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
+	pnfs_return_layout(inode);
+}
+
 static int filelayout_async_handle_error(struct rpc_task *task,
 					 struct nfs4_state *state,
 					 struct nfs_client *clp,
 					 struct pnfs_layout_segment *lseg)
 {
-	struct inode *inode = lseg->pls_layout->plh_inode;
+	struct pnfs_layout_hdr *lo = lseg->pls_layout;
+	struct inode *inode = lo->plh_inode;
 	struct nfs_server *mds_server = NFS_SERVER(inode);
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(lseg);
 	struct nfs_client *mds_client = mds_server->nfs_client;
@@ -204,8 +213,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
-		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags);
-		_pnfs_return_layout(inode);
+		set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
@@ -330,7 +338,9 @@ static void filelayout_read_count_stats(struct rpc_task *task, void *data)
 static void filelayout_read_release(void *data)
 {
 	struct nfs_read_data *rdata = data;
+	struct pnfs_layout_hdr *lo = rdata->header->lseg->pls_layout;
 
+	filelayout_fenceme(lo->plh_inode, lo);
 	nfs_put_client(rdata->ds_clp);
 	rdata->header->mds_ops->rpc_release(data);
 }
@@ -428,7 +438,9 @@ static void filelayout_write_count_stats(struct rpc_task *task, void *data)
 static void filelayout_write_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
+	struct pnfs_layout_hdr *lo = wdata->header->lseg->pls_layout;
 
+	filelayout_fenceme(lo->plh_inode, lo);
 	nfs_put_client(wdata->ds_clp);
 	wdata->header->mds_ops->rpc_release(data);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2d722db..dbf7bba 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -62,6 +62,7 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
+	NFS_LAYOUT_RETURN,		/* Return this layout ASAP */
 };
 
 enum layoutdriver_policy_flags {
-- 
1.7.11.7

