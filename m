Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47293 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab0LOScT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:32:19 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] Revert "pnfs-submit: wave2: Pull out all recall initiated LAYOUTRETURNS"
Date: Wed, 15 Dec 2010 20:32:16 +0200
Message-Id: <1292437936-21908-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit fea1ffe711454410ba5277115c9aeaf814681f4a.

Conflicts:

	fs/nfs/callback_proc.c
---
 fs/nfs/callback.h      |    5 ++
 fs/nfs/callback_proc.c |  103 ++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4_fs.h       |    1 +
 fs/nfs/nfs4state.c     |    4 ++
 4 files changed, 84 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 7f55c7e..616c5c1 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -167,6 +167,7 @@ extern unsigned nfs4_callback_layoutrecall(
 extern bool matches_outstanding_recall(struct inode *ino,
 				       struct pnfs_layout_range *range);
 extern void notify_drained(struct nfs_client *clp, u64 mask);
+extern void nfs_client_return_layouts(struct nfs_client *clp);
 
 static inline void put_session_client(struct nfs4_session *session)
 {
@@ -182,6 +183,10 @@ find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
 
 #else /* CONFIG_NFS_V4_1 */
 
+static inline void nfs_client_return_layouts(struct nfs_client *clp)
+{
+}
+
 static inline struct nfs_client *
 find_client_from_cps(struct cb_process_state *cps, struct sockaddr *addr)
 {
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a9d162f..b6a2903 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -160,30 +160,88 @@ matches_outstanding_recall(struct inode *ino, struct pnfs_layout_range *range)
 	return rv;
 }
 
+/* Send a synchronous LAYOUTRETURN.  By the time this is called, we know
+ * all IO has been drained, any matching lsegs deleted, and that no
+ * overlapping LAYOUTGETs will be sent or processed for the duration
+ * of this call.
+ * Note that it is possible that when this is called, the stateid has
+ * been invalidated.  But will not be cleared, so can still use.
+ */
+static int
+pnfs_send_layoutreturn(struct nfs_client *clp,
+		       struct pnfs_cb_lrecall_info *cb_info)
+{
+	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
+	struct nfs4_layoutreturn *lrp;
+
+	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
+	if (!lrp)
+		return -ENOMEM;
+	lrp->args.reclaim = 0;
+	lrp->args.layout_type = args->cbl_layout_type;
+	lrp->args.return_type = args->cbl_recall_type;
+	lrp->clp = clp;
+	if (args->cbl_recall_type == RETURN_FILE) {
+		lrp->args.range = args->cbl_range;
+		lrp->args.inode = cb_info->pcl_ino;
+	} else {
+		lrp->args.range.iomode = IOMODE_ANY;
+		lrp->args.inode = NULL;
+	}
+	return nfs4_proc_layoutreturn(lrp, true);
+}
+
+/* Called by state manager to finish CB_LAYOUTRECALLS initiated by
+ * nfs4_callback_layoutrecall().
+ */
+void nfs_client_return_layouts(struct nfs_client *clp)
+{
+	struct pnfs_cb_lrecall_info *cb_info;
+
+	spin_lock(&clp->cl_lock);
+	while (true) {
+		if (list_empty(&clp->cl_layoutrecalls)) {
+			spin_unlock(&clp->cl_lock);
+			break;
+		}
+		cb_info = list_first_entry(&clp->cl_layoutrecalls,
+					   struct pnfs_cb_lrecall_info,
+					   pcl_list);
+		spin_unlock(&clp->cl_lock);
+		if (atomic_read(&cb_info->pcl_count) != 0)
+			break;
+		/* What do on error return?  These layoutreturns are
+		 * required by the protocol.  So if do not get
+		 * successful reply, probably have to do something
+		 * more drastic.
+		 */
+		pnfs_send_layoutreturn(clp, cb_info);
+		spin_lock(&clp->cl_lock);
+		/* Removing from the list unblocks LAYOUTGETs */
+		list_del(&cb_info->pcl_list);
+		clp->cl_cb_lrecall_count--;
+		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
+		kfree(cb_info);
+	}
+}
+
 void notify_drained(struct nfs_client *clp, u64 mask)
 {
 	atomic_t **ptr = clp->cl_drain_notification;
+	bool done = false;
 
 	/* clp lock not needed except to remove used up entries */
 	/* Should probably use functions defined in bitmap.h */
 	while (mask) {
-		if ((mask & 1) && (atomic_dec_and_test(*ptr))) {
-			struct pnfs_cb_lrecall_info *cb_info;
-
-			cb_info = container_of(*ptr,
-					       struct pnfs_cb_lrecall_info,
-					       pcl_count);
-			spin_lock(&clp->cl_lock);
-			/* Removing from the list unblocks LAYOUTGETs */
-			list_del(&cb_info->pcl_list);
-			clp->cl_cb_lrecall_count--;
-			clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
-			spin_unlock(&clp->cl_lock);
-			kfree(cb_info);
-		}
+		if ((mask & 1) && (atomic_dec_and_test(*ptr)))
+			done = true;
 		mask >>= 1;
 		ptr++;
 	}
+	if (done) {
+		set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
+		nfs4_schedule_state_manager(clp);
+	}
 }
 
 static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
@@ -208,9 +266,8 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 				 * does having a layout ref keep ino around?
 				 *  It should.
 				 */
-				/* Without this, layout can be freed as soon
-				 * as we release cl_lock.  Matched in
-				 * do_callback_layoutrecall.
+				/* We need to hold the reference until any
+				 * potential LAYOUTRETURN is finished.
 				 */
 				get_layout_hdr(lo);
 				cb_info->pcl_ino = lo->inode;
@@ -329,18 +386,6 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 			res = NFS4ERR_NOMATCHING_LAYOUT;
 		}
 		kfree(new);
-	} else {
-		/* We are currently using a referenced layout */
-		if (args->cbl_recall_type == RETURN_FILE) {
-			struct pnfs_layout_hdr *lo;
-
-			lo = NFS_I(new->pcl_ino)->layout;
-			spin_lock(&lo->inode->i_lock);
-			lo->plh_block_lgets--;
-			spin_unlock(&lo->inode->i_lock);
-			put_layout_hdr(lo);
-		}
-		res = NFS4ERR_DELAY;
 	}
 out:
 	dprintk("%s returning %i\n", __func__, res);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 15fea61..fe5c07d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -46,6 +46,7 @@ enum nfs4_client_state {
 	NFS4CLNT_DELEGRETURN,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_LAYOUT_RECALL,
 };
 
 enum nfs4_session_state {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index dc62928..acf3e3e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1577,6 +1577,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs_client_return_marked_delegations(clp);
 			continue;
 		}
+		if (test_and_clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state)) {
+			nfs_client_return_layouts(clp);
+			continue;
+		}
 		/* Recall session slots */
 		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
-- 
1.7.2.3

