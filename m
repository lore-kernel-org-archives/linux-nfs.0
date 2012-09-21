Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58062 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab2IUBgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 21:36:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/14] NFSv4.1: Fix a race in the pNFS return-on-close code
Date: Thu, 20 Sep 2012 21:35:46 -0400
Message-Id: <1348191357-44503-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1348191357-44503-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348191357-44503-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we sleep after dropping the inode->i_lock, then we are no longer
atomic with respect to the rpc_wake_up() call in pnfs_layout_remove_lseg().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |  8 +++-----
 fs/nfs/pnfs.c     | 22 ++++++++++++----------
 fs/nfs/pnfs.h     |  4 ++--
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 87702a0..49d5c7d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2137,6 +2137,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
+	struct inode *inode = calldata->inode;
 	int call_close = 0;
 
 	dprintk("%s: begin!\n", __func__);
@@ -2170,16 +2171,13 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
 		if (calldata->roc &&
-		    pnfs_roc_drain(calldata->inode, &calldata->roc_barrier)) {
-			rpc_sleep_on(&NFS_SERVER(calldata->inode)->roc_rpcwaitq,
-				     task, NULL);
+		    pnfs_roc_drain(inode, &calldata->roc_barrier, task))
 			goto out;
-		}
 	}
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(inode),
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res,
 				task))
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 80aaaba..f3acb68 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -777,27 +777,29 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 	spin_unlock(&ino->i_lock);
 }
 
-bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
+bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg;
+	u32 current_seqid;
 	bool found = false;
 
 	spin_lock(&ino->i_lock);
 	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
 		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+			rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
 			found = true;
-			break;
+			goto out;
 		}
-	if (!found) {
-		struct pnfs_layout_hdr *lo = nfsi->layout;
-		u32 current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
+	lo = nfsi->layout;
+	current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
 
-		/* Since close does not return a layout stateid for use as
-		 * a barrier, we choose the worst-case barrier.
-		 */
-		*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
-	}
+	/* Since close does not return a layout stateid for use as
+	 * a barrier, we choose the worst-case barrier.
+	 */
+	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
+out:
 	spin_unlock(&ino->i_lock);
 	return found;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9735031..aa9fa1b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -210,7 +210,7 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
+bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
@@ -442,7 +442,7 @@ pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 }
 
 static inline bool
-pnfs_roc_drain(struct inode *ino, u32 *barrier)
+pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 {
 	return false;
 }
-- 
1.7.11.4

