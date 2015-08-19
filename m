Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35834 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbbHSE4Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 00:56:24 -0400
Received: by pacgr6 with SMTP id gr6so148463349pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 21:56:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFSv4.1/pnfs: Fix a close/delegreturn hang when return-on-close is set
Date: Tue, 18 Aug 2015 23:56:19 -0500
Message-Id: <1439960180-19450-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The helper pnfs_roc() has already verified that we have no delegations,
and no further open files, hence no outstanding I/O and it has marked
all the return-on-close lsegs as being invalid.
Furthermore, it sets the NFS_LAYOUT_RETURN bit, thus serialising the
close/delegreturn with all future layoutget calls on this inode.

The checks in pnfs_roc_drain() for valid layout segments are therefore
redundant: those cannot exist until another layoutget completes.
The other check for whether or not NFS_LAYOUT_RETURN is set, actually
causes a hang, since we already know that we hold that flag.

To fix, we therefore strip out all the functionality in pnfs_roc_drain()
except the retrieval of the barrier state, and then rename the function
accordingly.

Reported-by: Christoph Hellwig <hch@infradead.org>
Fixes: 5c4a79fb2b1c ("Don't prevent layoutgets when doing return-on-close")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 12 ++++--------
 fs/nfs/pnfs.c     | 24 +-----------------------
 fs/nfs/pnfs.h     |  7 +++----
 3 files changed, 8 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f4e5816a77b0..bda7837dfe6b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2737,11 +2737,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
-		if (calldata->roc &&
-		    pnfs_roc_drain(inode, &calldata->roc_barrier, task)) {
-			nfs_release_seqid(calldata->arg.seqid);
-			goto out_wait;
-		    }
+		if (calldata->roc)
+			pnfs_roc_get_barrier(inode, &calldata->roc_barrier);
 	}
 	calldata->arg.share_access =
 		nfs4_map_atomic_open_share(NFS_SERVER(inode),
@@ -5289,9 +5286,8 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (d_data->roc &&
-	    pnfs_roc_drain(d_data->inode, &d_data->roc_barrier, task))
-		return;
+	if (d_data->roc)
+		pnfs_roc_get_barrier(d_data->inode, &d_data->roc_barrier);
 
 	nfs4_setup_sequence(d_data->res.server,
 			&d_data->args.seq_args,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6151f39c8291..6aabbb654021 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1141,25 +1141,14 @@ void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 	spin_unlock(&ino->i_lock);
 }
 
-bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
+void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *lo;
-	struct pnfs_layout_segment *lseg;
 	nfs4_stateid stateid;
 	u32 current_seqid;
-	bool layoutreturn = false;
 
 	spin_lock(&ino->i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list) {
-		if (!test_bit(NFS_LSEG_ROC, &lseg->pls_flags))
-			continue;
-		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
-			continue;
-		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-		spin_unlock(&ino->i_lock);
-		return true;
-	}
 	lo = nfsi->layout;
 	current_seqid = be32_to_cpu(lo->plh_stateid.seqid);
 
@@ -1168,18 +1157,7 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
 	 */
 	*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
 	stateid = lo->plh_stateid;
-	if (test_and_clear_bit(NFS_LAYOUT_RETURN_BEFORE_CLOSE,
-					   &lo->plh_flags))
-		layoutreturn = pnfs_prepare_layoutreturn(lo);
-	if (test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
-		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-
 	spin_unlock(&ino->i_lock);
-	if (layoutreturn) {
-		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, false);
-		return true;
-	}
-	return false;
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 738672a0f8da..a3d57a8fac76 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -267,7 +267,7 @@ int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
+void pnfs_roc_get_barrier(struct inode *ino, u32 *barrier);
 void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
@@ -605,10 +605,9 @@ pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
 {
 }
 
-static inline bool
-pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
+static inline void
+pnfs_roc_get_barrier(struct inode *ino, u32 *barrier)
 {
-	return false;
 }
 
 static inline void set_pnfs_layoutdriver(struct nfs_server *s,
-- 
2.4.3

