Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47257 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab0LOSbh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:31:37 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] Revert "pnfs-submit: wave2: Remove LAYOUTRETURN from return on close"
Date: Wed, 15 Dec 2010 20:31:35 +0200
Message-Id: <1292437895-21782-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 5611feb54b4c0225f0924c6b059f281d45915b24.
---
 fs/nfs/nfs4_fs.h   |    2 +-
 fs/nfs/nfs4proc.c  |   16 ++-------
 fs/nfs/nfs4state.c |   16 +++++++-
 fs/nfs/pnfs.c      |  103 +++++-----------------------------------------------
 fs/nfs/pnfs.h      |   38 ++++++-------------
 5 files changed, 39 insertions(+), 136 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d58a130..a917872 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,7 +242,7 @@ extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
+extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 35af296..5331f28 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1841,8 +1841,6 @@ struct nfs4_closedata {
 	struct nfs_closeres res;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
-	bool roc;
-	u32 roc_barrier;
 };
 
 static void nfs4_free_closedata(void *data)
@@ -1850,7 +1848,6 @@ static void nfs4_free_closedata(void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state_owner *sp = calldata->state->owner;
 
-	pnfs_roc_release(calldata->roc, calldata->state->inode);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
@@ -1883,8 +1880,6 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
-			pnfs_roc_set_barrier(calldata->roc, state->inode,
-					     calldata->roc_barrier);
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
 			nfs4_close_clear_stateid_flags(state,
@@ -1937,11 +1932,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 
-	if (calldata->arg.fmode == 0) {
+	if (calldata->arg.fmode == 0)
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
-		pnfs_roc_drain(calldata->roc, state->inode,
-			       &calldata->roc_barrier, task);
-	}
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
@@ -1969,7 +1961,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -2004,7 +1996,6 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
-	calldata->roc = roc;
 	path_get(path);
 	calldata->path = *path;
 
@@ -2022,7 +2013,6 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 out_free_calldata:
 	kfree(calldata);
 out:
-	pnfs_roc_release(roc, state->inode);
 	nfs4_put_open_state(state);
 	nfs4_put_state_owner(sp);
 	return status;
@@ -5619,7 +5609,7 @@ static void nfs4_layoutreturn_release(void *calldata)
 		lo->plh_block_lgets--;
 		atomic_dec(&lo->plh_outstanding);
 		spin_unlock(&ino->i_lock);
-		put_layout_hdr(ino);
+		put_layout_hdr(lo);
 	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bca8386..6a1eb41 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -619,9 +619,21 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else {
-		bool roc = pnfs_roc(state->inode);
+		u32 roc_iomode;
+		struct nfs_inode *nfsi = NFS_I(state->inode);
+
+		if (has_layout(nfsi) &&
+		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
+			struct pnfs_layout_range range = {
+				.iomode = roc_iomode,
+				.offset = 0,
+				.length = NFS4_MAX_UINT64,
+			};
+
+			pnfs_return_layout(state->inode, &range, wait);
+		}
 
-		nfs4_do_close(path, state, gfp_mask, wait, roc);
+		nfs4_do_close(path, state, gfp_mask, wait);
 	}
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 904c110..1899dc6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -465,12 +465,9 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	newseq = be32_to_cpu(new->stateid.seqid);
 	if ((int)(newseq - oldseq) > 0) {
 		memcpy(&lo->stateid, &new->stateid, sizeof(new->stateid));
-		if (update_barrier) {
-			u32 new_barrier = be32_to_cpu(new->stateid.seqid);
-
-			if ((int)(new_barrier - lo->plh_barrier))
-				lo->plh_barrier = new_barrier;
-		} else {
+		if (update_barrier)
+			lo->plh_barrier = be32_to_cpu(new->stateid.seqid);
+		else {
 			/* Because of wraparound, we want to keep the barrier
 			 * "close" to the current seqids.  It needs to be
 			 * within 2**31 to count as "behind", so if it
@@ -618,7 +615,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
 
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
-		put_layout_hdr(ino);
+		put_layout_hdr(NFS_I(ino)->layout);
 		goto out;
 	}
 	lrp->args.reclaim = 0;
@@ -679,91 +676,6 @@ out:
 	return status;
 }
 
-bool pnfs_roc(struct inode *ino)
-{
-	struct pnfs_layout_hdr *lo;
-	struct pnfs_layout_segment *lseg, *tmp;
-	LIST_HEAD(tmp_list);
-	bool found = false;
-
-	spin_lock(&ino->i_lock);
-	lo = NFS_I(ino)->layout;
-	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
-		goto out_nolayout;
-	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
-		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
-			mark_lseg_invalid(lseg, &tmp_list);
-			found = true;
-		}
-	if (!found)
-		goto out_nolayout;
-	lo->plh_block_lgets++;
-	get_layout_hdr(lo); /* matched in pnfs_roc_release */
-	spin_unlock(&ino->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
-	return true;
-
-out_nolayout:
-	spin_unlock(&ino->i_lock);
-	return false;
-}
-
-void pnfs_roc_release(bool needed, struct inode *ino)
-{
-	if (needed) {
-		struct pnfs_layout_hdr *lo;
-
-		spin_lock(&ino->i_lock);
-		lo = NFS_I(ino)->layout;
-		lo->plh_block_lgets--;
-		put_layout_hdr_locked(lo);
-		spin_unlock(&ino->i_lock);
-	}
-}
-
-void pnfs_roc_set_barrier(bool needed, struct inode *ino, u32 barrier)
-{
-	if (needed) {
-		struct pnfs_layout_hdr *lo;
-
-		spin_lock(&ino->i_lock);
-		lo = NFS_I(ino)->layout;
-		if ((int)(barrier - lo->plh_barrier) > 0)
-			lo->plh_barrier = barrier;
-		spin_unlock(&ino->i_lock);
-	}
-}
-
-void pnfs_roc_drain(bool needed, struct inode *ino, u32 *barrier,
-		    struct rpc_task *task)
-{
-	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_segment *lseg;
-	bool found = false;
-
-	if (!needed)
-		return;
-	spin_lock(&ino->i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
-		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
-			rpc_sleep_on(&NFS_I(ino)->lo_rpcwaitq, task, NULL);
-			found = true;
-			break;
-		}
-	if (!found) {
-		struct pnfs_layout_hdr *lo = nfsi->layout;
-		u32 current_seqid = be32_to_cpu(lo->stateid.stateid.seqid);
-
-		/* Since close does not return a layout stateid for use as
-		 * a barrier, we choose the worst-case barrier.
-		 */
-		*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
-	}
-	spin_unlock(&ino->i_lock);
-	return;
-}
-
 /*
  * Compare two layout segments for sorting into layout cache.
  * We want to preferentially return RW over RO layouts, so ensure those
@@ -1032,8 +944,11 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
-		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
-		set_bit(NFS_LAYOUT_ROC, &lo->plh_flags);
+		/* FI: This needs to be re-examined.  At lo level,
+		 * all it needs is a bit indicating whether any of
+		 * the lsegs in the list have the flags set.
+		 */
+		lo->roc_iomode |= res->range.iomode;
 	}
 
 	/* Done processing layoutget. Set the layout stateid */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bbafee0..59eb0e8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -34,7 +34,6 @@
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
-	NFS_LSEG_ROC,		/* roc bit received from server */
 };
 
 struct pnfs_layout_segment {
@@ -60,7 +59,6 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_NEED_LCOMMIT,	/* LAYOUTCOMMIT needed */
-	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 };
 
 /* Per-layout driver specific registration structure */
@@ -103,6 +101,7 @@ struct pnfs_layout_hdr {
 	struct list_head	layouts;   /* other client layouts */
 	struct list_head	plh_bulk_recall; /* clnt list of bulk recalls */
 	struct list_head	segs;      /* layout segments list */
+	int			roc_iomode;/* return on close iomode, 0=none */
 	nfs4_stateid		stateid;
 	atomic_t		plh_outstanding; /* number of RPCs out */
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
@@ -223,11 +222,6 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 				struct pnfs_layout_range *range,
 				struct list_head *tmp_list);
-bool pnfs_roc(struct inode *ino);
-void pnfs_roc_release(bool needed, struct inode *ino);
-void pnfs_roc_set_barrier(bool needed, struct inode *ino, u32 barrier);
-void pnfs_roc_drain(bool needed, struct inode *ino, u32 *barrier,
-		    struct rpc_task *task);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
@@ -253,6 +247,14 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 	return nfss->pnfs_curr_ld != NULL;
 }
 
+/* Should the pNFS client commit and return the layout on close
+ */
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
+{
+	return nfsi->layout->roc_iomode;
+}
+
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
 				     bool wait)
@@ -336,26 +338,10 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	return 0;
 }
 
-static inline bool
-pnfs_roc(struct inode *ino)
-{
-	return false;
-}
-
-static inline void
-pnfs_roc_release(bool needed, struct inode *ino)
-{
-}
-
-static inline void
-pnfs_roc_set_barrier(bool needed, struct inode *ino, u32 barrier)
-{
-}
-
-static inline void
-pnfs_roc_drain(bool needed, struct inode *ino, u32 *barrier,
-	       struct rpc_task *task)
+static inline int
+pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 {
+	return 0;
 }
 
 static inline int pnfs_return_layout(struct inode *ino,
-- 
1.7.2.3

