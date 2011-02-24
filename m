Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51608 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755267Ab1BXWNB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 17:13:01 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: iisaman@netapp.com
Subject: [PATCH] SQUASHME: pnfs: revert layout recall/get/return synchronization
Date: Thu, 24 Feb 2011 14:13:00 -0800
Message-Id: <1298585580-891-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

For now, revert code attempting a "forget-less" client model to match
the pnfs-submit-wave4 forgetful model implementation in preparation
for porting the tree onto it.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h         |   10 --
 fs/nfs/callback_proc.c    |  341 ++++++++++----------------------------------
 fs/nfs/client.c           |   14 ++-
 fs/nfs/inode.c            |    2 -
 fs/nfs/nfs4_fs.h          |    4 +-
 fs/nfs/nfs4proc.c         |   96 +++----------
 fs/nfs/nfs4state.c        |   35 +----
 fs/nfs/pnfs.c             |  312 +++++++++++++++++++++++------------------
 fs/nfs/pnfs.h             |   62 ++++++---
 include/linux/nfs_fs.h    |    2 -
 include/linux/nfs_fs_sb.h |    9 +-
 11 files changed, 337 insertions(+), 550 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 681f84b..892128f 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -164,10 +164,6 @@ struct cb_layoutrecallargs {
 extern unsigned nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
 	void *dummy, struct cb_process_state *cps);
-extern bool matches_outstanding_recall(struct inode *ino,
-				       struct pnfs_layout_range *range);
-extern void notify_drained(struct nfs_client *clp, u64 mask);
-extern void nfs_client_return_layouts(struct nfs_client *clp);
 
 extern void nfs4_check_drain_bc_complete(struct nfs4_session *ses);
 extern void nfs4_cb_take_slot(struct nfs_client *clp);
@@ -191,12 +187,6 @@ extern __be32 nfs4_callback_devicenotify(
 	struct cb_devicenotifyargs *args,
 	void *dummy, struct cb_process_state *cps);
 
-#else /* CONFIG_NFS_V4_1 */
-
-static inline void nfs_client_return_layouts(struct nfs_client *clp)
-{
-}
-
 #endif /* CONFIG_NFS_V4_1 */
 extern int check_gss_callback_principal(struct nfs_client *, struct svc_rqst *);
 extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 12ab7b3..cb9fef5 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -108,227 +108,89 @@ int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nf
 
 #if defined(CONFIG_NFS_V4_1)
 
-static bool
-_recall_matches_lget(struct pnfs_cb_lrecall_info *cb_info,
-		     struct inode *ino, struct pnfs_layout_range *range)
+static u32 initiate_file_draining(struct nfs_client *clp,
+				  struct cb_layoutrecallargs *args)
 {
-	struct cb_layoutrecallargs *cb_args = &cb_info->pcl_args;
-
-	switch (cb_args->cbl_recall_type) {
-	case RETURN_ALL:
-		return true;
-	case RETURN_FSID:
-		return !memcmp(&NFS_SERVER(ino)->fsid, &cb_args->cbl_fsid,
-			       sizeof(struct nfs_fsid));
-	case RETURN_FILE:
-		return (ino == cb_info->pcl_ino) &&
-			should_free_lseg(range, &cb_args->cbl_range);
-	default:
-		/* Should never hit here, as decode_layoutrecall_args()
-		 * will verify cb_info from server.
-		 */
-		BUG();
-	}
-}
+	struct pnfs_layout_hdr *lo;
+	struct inode *ino;
+	bool found = false;
+	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
+	LIST_HEAD(free_me_list);
 
-bool
-matches_outstanding_recall(struct inode *ino, struct pnfs_layout_range *range)
-{
-	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
-	struct pnfs_cb_lrecall_info *cb_info;
-	bool rv = false;
-
-	assert_spin_locked(&clp->cl_lock);
-	list_for_each_entry(cb_info, &clp->cl_layoutrecalls, pcl_list) {
-		if (_recall_matches_lget(cb_info, ino, range)) {
-			rv = true;
-			break;
-		}
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
+		if (nfs_compare_fh(&args->cbl_fh,
+				   &NFS_I(lo->plh_inode)->fh))
+			continue;
+		ino = igrab(lo->plh_inode);
+		if (!ino)
+			continue;
+		found = true;
+		/* Without this, layout can be freed as soon
+		 * as we release cl_lock.
+		 */
+		get_layout_hdr(lo);
+		break;
 	}
+	spin_unlock(&clp->cl_lock);
+	if (!found)
+		return NFS4ERR_NOMATCHING_LAYOUT;
+
+	spin_lock(&ino->i_lock);
+	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+	    mark_matching_lsegs_invalid(lo, &free_me_list,
+					&args->cbl_range))
+		rv = NFS4ERR_DELAY;
+	else
+		rv = NFS4ERR_NOMATCHING_LAYOUT;
+	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&free_me_list);
+	put_layout_hdr(lo);
+	iput(ino);
 	return rv;
 }
 
-/* Send a synchronous LAYOUTRETURN.  By the time this is called, we know
- * all IO has been drained, any matching lsegs deleted, and that no
- * overlapping LAYOUTGETs will be sent or processed for the duration
- * of this call.
- * Note that it is possible that when this is called, the stateid has
- * been invalidated.  But will not be cleared, so can still use.
- */
-static int
-pnfs_send_layoutreturn(struct nfs_client *clp,
-		       struct pnfs_cb_lrecall_info *cb_info)
-{
-	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
-	struct nfs4_layoutreturn *lrp;
-
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-	if (!lrp)
-		return -ENOMEM;
-	lrp->args.reclaim = 0;
-	lrp->args.layout_type = args->cbl_layout_type;
-	lrp->args.return_type = args->cbl_recall_type;
-	lrp->clp = clp;
-	if (args->cbl_recall_type == RETURN_FILE) {
-		lrp->args.range = args->cbl_range;
-		lrp->args.inode = cb_info->pcl_ino;
-	} else {
-		lrp->args.range.iomode = IOMODE_ANY;
-		lrp->args.inode = NULL;
-	}
-	return nfs4_proc_layoutreturn(lrp, true);
-}
-
-/* Called by state manager to finish CB_LAYOUTRECALLS initiated by
- * nfs4_callback_layoutrecall().
- */
-void nfs_client_return_layouts(struct nfs_client *clp)
+static u32 initiate_bulk_draining(struct nfs_client *clp,
+				  struct cb_layoutrecallargs *args)
 {
-	struct pnfs_cb_lrecall_info *cb_info;
+	struct pnfs_layout_hdr *lo;
+	struct inode *ino;
+	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
+	struct pnfs_layout_hdr *tmp;
+	LIST_HEAD(recall_list);
+	LIST_HEAD(free_me_list);
+	struct pnfs_layout_range range = {
+		.iomode = IOMODE_ANY,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
 
-	dprintk("%s\n", __func__);
 	spin_lock(&clp->cl_lock);
-	while (true) {
-		if (list_empty(&clp->cl_layoutrecalls)) {
-			spin_unlock(&clp->cl_lock);
-			break;
-		}
-		cb_info = list_first_entry(&clp->cl_layoutrecalls,
-					   struct pnfs_cb_lrecall_info,
-					   pcl_list);
-		spin_unlock(&clp->cl_lock);
-		/* Were all recalled lsegs already forgotten */
-		if (atomic_read(&cb_info->pcl_count) != 0)
-			break;
-
-		/* What do on error return?  These layoutreturns are
-		 * required by the protocol.  So if do not get
-		 * successful reply, probably have to do something
-		 * more drastic.
-		 */
-		pnfs_send_layoutreturn(clp, cb_info);
-		spin_lock(&clp->cl_lock);
-		/* Removing from the list unblocks LAYOUTGETs */
-		list_del(&cb_info->pcl_list);
-		clp->cl_cb_lrecall_count--;
-		clp->cl_drain_notification[cb_info->pcl_notify_idx] = NULL;
-		spin_unlock(&clp->cl_lock);
-		rpc_wake_up(&clp->cl_rpcwaitq_recall);
-		kfree(cb_info);
-	}
-}
-
-void notify_drained(struct nfs_client *clp, u64 mask)
-{
-	atomic_t **ptr = clp->cl_drain_notification;
-	bool done = false;
-
-	/* clp lock not needed except to remove used up entries */
-	/* Should probably use functions defined in bitmap.h */
-	while (mask) {
-		if ((mask & 1) && atomic_dec_and_test(*ptr))
-			done = true;
-		mask >>= 1;
-		ptr++;
-	}
-	if (done) {
-		set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
-		nfs4_schedule_state_manager(clp);
+	list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
+		if ((args->cbl_recall_type == RETURN_FSID) &&
+		    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
+			   &args->cbl_fsid, sizeof(struct nfs_fsid)))
+			continue;
+		if (!igrab(lo->plh_inode))
+			continue;
+		get_layout_hdr(lo);
+		BUG_ON(!list_empty(&lo->plh_bulk_recall));
+		list_add(&lo->plh_bulk_recall, &recall_list);
 	}
-}
-
-static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
-{
-	struct nfs_client *clp = cb_info->pcl_clp;
-	struct pnfs_layout_hdr *lo;
-	int rv = NFS4ERR_NOMATCHING_LAYOUT;
-	struct cb_layoutrecallargs *args = &cb_info->pcl_args;
-
-	if (args->cbl_recall_type == RETURN_FILE) {
-		LIST_HEAD(free_me_list);
-
-		spin_lock(&clp->cl_lock);
-		list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
-			if (nfs_compare_fh(&args->cbl_fh,
-					   &NFS_I(lo->plh_inode)->fh))
-				continue;
-			if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
-				rv = NFS4ERR_DELAY;
-			else {
-				/* FIXME I need to better understand igrab and
-				 * does having a layout ref keep ino around?
-				 *  It should.
-				 */
-				/* We need to hold the reference until any
-				 * potential LAYOUTRETURN is finished.
-				 */
-				get_layout_hdr(lo);
-				cb_info->pcl_ino = lo->plh_inode;
-				rv = NFS4_OK;
-			}
-			break;
-		}
-		spin_unlock(&clp->cl_lock);
-
-		spin_lock(&lo->plh_inode->i_lock);
-		if (rv == NFS4_OK) {
-			lo->plh_block_lgets++;
-			if (nfs4_asynch_forget_layouts(lo, &args->cbl_range,
-						       cb_info->pcl_notify_idx,
-						       &cb_info->pcl_count,
-						       &free_me_list))
-				rv = NFS4ERR_DELAY;
-			else
-				rv = NFS4ERR_NOMATCHING_LAYOUT;
-		}
-		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
-		spin_unlock(&lo->plh_inode->i_lock);
-		pnfs_free_lseg_list(&free_me_list);
-	} else {
-		struct pnfs_layout_hdr *tmp;
-		LIST_HEAD(recall_list);
-		LIST_HEAD(free_me_list);
-		struct pnfs_layout_range range = {
-			.iomode = IOMODE_ANY,
-			.offset = 0,
-			.length = NFS4_MAX_UINT64,
-		};
-
-		spin_lock(&clp->cl_lock);
-		/* Per RFC 5661, 12.5.5.2.1.5, bulk recall must be serialized */
-		if (!list_is_singular(&clp->cl_layoutrecalls)) {
-			spin_unlock(&clp->cl_lock);
-			return NFS4ERR_DELAY;
-		}
-		list_for_each_entry(lo, &clp->cl_layouts, plh_layouts) {
-			if ((args->cbl_recall_type == RETURN_FSID) &&
-			    memcmp(&NFS_SERVER(lo->plh_inode)->fsid,
-				   &args->cbl_fsid, sizeof(struct nfs_fsid)))
-				continue;
-			get_layout_hdr(lo);
-			/* We could list_del(&lo->layouts) here */
-			BUG_ON(!list_empty(&lo->plh_bulk_recall));
-			list_add(&lo->plh_bulk_recall, &recall_list);
-		}
-		spin_unlock(&clp->cl_lock);
-		list_for_each_entry_safe(lo, tmp,
-					 &recall_list, plh_bulk_recall) {
-			spin_lock(&lo->plh_inode->i_lock);
-			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-			if (nfs4_asynch_forget_layouts(lo, &range,
-						       cb_info->pcl_notify_idx,
-						       &cb_info->pcl_count,
-						       &free_me_list))
-				rv = NFS4ERR_DELAY;
-			else
-				rv = NFS4ERR_NOMATCHING_LAYOUT;
-			list_del_init(&lo->plh_bulk_recall);
-			spin_unlock(&lo->plh_inode->i_lock);
-			pnfs_free_lseg_list(&free_me_list);
-			put_layout_hdr(lo);
-			rv = NFS4_OK;
-		}
+	spin_unlock(&clp->cl_lock);
+	list_for_each_entry_safe(lo, tmp,
+				 &recall_list, plh_bulk_recall) {
+		ino = lo->plh_inode;
+		spin_lock(&ino->i_lock);
+		set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
+		if (mark_matching_lsegs_invalid(lo, &free_me_list, &range))
+			rv = NFS4ERR_DELAY;
+		list_del_init(&lo->plh_bulk_recall);
+		spin_unlock(&ino->i_lock);
 		pnfs_free_lseg_list(&free_me_list);
+		put_layout_hdr(lo);
+		iput(ino);
 	}
 	return rv;
 }
@@ -336,63 +198,16 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
-	struct pnfs_cb_lrecall_info *new;
-	int i;
-	u32 res;
+	u32 res = NFS4ERR_DELAY;
 
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
-	new = kmalloc(sizeof(*new), GFP_KERNEL);
-	if (!new) {
-		res = NFS4ERR_DELAY;
-		goto out;
-	}
-	memcpy(&new->pcl_args, args, sizeof(*args));
-	atomic_set(&new->pcl_count, 1);
-	new->pcl_clp = clp;
-	new->pcl_ino = NULL;
-	spin_lock(&clp->cl_lock);
-	if (clp->cl_cb_lrecall_count >= PNFS_MAX_CB_LRECALLS) {
-		kfree(new);
-		res = NFS4ERR_DELAY;
-		spin_unlock(&clp->cl_lock);
-		dprintk("%s: too many layout recalls\n", __func__);
+	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
 		goto out;
-	}
-	clp->cl_cb_lrecall_count++;
-	/* Adding to the list will block conflicting LGET activity */
-	list_add_tail(&new->pcl_list, &clp->cl_layoutrecalls);
-	for (i = 0; i < PNFS_MAX_CB_LRECALLS; i++)
-		if (!clp->cl_drain_notification[i]) {
-			clp->cl_drain_notification[i] = &new->pcl_count;
-			break;
-		}
-	BUG_ON(i >= PNFS_MAX_CB_LRECALLS);
-	new->pcl_notify_idx = i;
-	spin_unlock(&clp->cl_lock);
-	res = initiate_layout_draining(new);
-	if (res || atomic_dec_and_test(&new->pcl_count)) {
-		spin_lock(&clp->cl_lock);
-		list_del(&new->pcl_list);
-		clp->cl_cb_lrecall_count--;
-		clp->cl_drain_notification[new->pcl_notify_idx] = NULL;
-		rpc_wake_up(&clp->cl_rpcwaitq_recall);
-		spin_unlock(&clp->cl_lock);
-		if (res == NFS4_OK) {
-			if (args->cbl_recall_type == RETURN_FILE) {
-				struct pnfs_layout_hdr *lo;
-
-				lo = NFS_I(new->pcl_ino)->layout;
-				spin_lock(&lo->plh_inode->i_lock);
-				lo->plh_block_lgets--;
-				if (!pnfs_layoutgets_blocked(lo, NULL))
-					rpc_wake_up(&NFS_I(lo->plh_inode)->lo_rpcwaitq_stateid);
-				spin_unlock(&lo->plh_inode->i_lock);
-				put_layout_hdr(lo);
-			}
-			res = NFS4ERR_NOMATCHING_LAYOUT;
-		}
-		kfree(new);
-	}
+	if (args->cbl_recall_type == RETURN_FILE)
+		res = initiate_file_draining(clp, args);
+	else
+		res = initiate_bulk_draining(clp, args);
+	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
 out:
 	dprintk("%s returning %i\n", __func__, res);
 	return res;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 263c4f9..c77ab3e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -185,9 +185,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 		clp->cl_machine_cred = cred;
 #if defined(CONFIG_NFS_V4_1)
 	INIT_LIST_HEAD(&clp->cl_layouts);
-	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq_recall,
-			    "NFS client CB_LAYOUTRECALLS");
 #endif
 	nfs_fscache_get_client_cookie(clp);
 
@@ -246,6 +243,11 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 		idr_remove(&cb_ident_idr, clp->cl_cb_ident);
 }
 
+static void pnfs_init_server(struct nfs_server *server)
+{
+	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
+}
+
 #else
 static void nfs4_shutdown_client(struct nfs_client *clp)
 {
@@ -259,6 +261,10 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 {
 }
 
+static void pnfs_init_server(struct nfs_server *server)
+{
+}
+
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -1053,6 +1059,8 @@ static struct nfs_server *nfs_alloc_server(void)
 		return NULL;
 	}
 
+	pnfs_init_server(server);
+
 	return server;
 }
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5877097..fac88e1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1476,8 +1476,6 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
-	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layoutreturn");
-	rpc_init_wait_queue(&nfsi->lo_rpcwaitq_stateid, "pNFS Layoutstateid");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 41d456e..f2f1a44 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -44,9 +44,9 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
+	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
-	NFS4CLNT_LAYOUT_RECALL,
 };
 
 enum nfs4_session_state {
@@ -236,7 +236,7 @@ extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
+extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a1d9a70..a20f391 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1844,6 +1844,8 @@ struct nfs4_closedata {
 	struct nfs_closeres res;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
+	bool roc;
+	u32 roc_barrier;
 };
 
 static void nfs4_free_closedata(void *data)
@@ -1851,6 +1853,8 @@ static void nfs4_free_closedata(void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state_owner *sp = calldata->state->owner;
 
+	if (calldata->roc)
+		pnfs_roc_release(calldata->state->inode);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
@@ -1883,6 +1887,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
+			if (calldata->roc)
+				pnfs_roc_set_barrier(state->inode,
+						     calldata->roc_barrier);
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
 			nfs4_close_clear_stateid_flags(state,
@@ -1935,8 +1942,15 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 
-	if (calldata->arg.fmode == 0)
+	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
+		if (calldata->roc &&
+		    pnfs_roc_drain(calldata->inode, &calldata->roc_barrier)) {
+			rpc_sleep_on(&NFS_SERVER(calldata->inode)->roc_rpcwaitq,
+				     task, NULL);
+			return;
+		}
+	}
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
@@ -1964,7 +1978,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -1999,6 +2013,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
+	calldata->roc = roc;
 	path_get(path);
 	calldata->path = *path;
 
@@ -2016,6 +2031,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 out_free_calldata:
 	kfree(calldata);
 out:
+	if (roc)
+		pnfs_roc_release(state->inode);
 	nfs4_put_open_state(state);
 	nfs4_put_state_owner(sp);
 	return status;
@@ -5390,53 +5407,25 @@ static void
 nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
-	struct inode *ino = lgp->args.inode;
-	struct nfs_inode *nfsi = NFS_I(ino);
-	struct nfs_server *server = NFS_SERVER(ino);
-	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
+	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
 
 	dprintk("--> %s\n", __func__);
-	spin_lock(&clp->cl_lock);
-	if (matches_outstanding_recall(ino, &lgp->args.range)) {
-		rpc_sleep_on(&clp->cl_rpcwaitq_recall, task, NULL);
-		spin_unlock(&clp->cl_lock);
-		return;
-	}
-	spin_unlock(&clp->cl_lock);
 	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
 	 * right now covering the LAYOUTGET we are about to send.
 	 * However, that is not so catastrophic, and there seems
 	 * to be no way to prevent it completely.
 	 */
-	spin_lock(&ino->i_lock);
-	if (pnfs_layoutgets_blocked(nfsi->layout, NULL)) {
-		rpc_sleep_on(&nfsi->lo_rpcwaitq_stateid, task, NULL);
-		spin_unlock(&ino->i_lock);
+	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
+				&lgp->res.seq_res, 0, task))
 		return;
-	}
-	/* This needs after above check but atomic with it in order to properly
-	 * serialize openstateid LAYOUTGETs.
-	 */
-	atomic_inc(&nfsi->layout->plh_outstanding);
 	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
 					  NFS_I(lgp->args.inode)->layout,
 					  lgp->args.ctx->state)) {
 		rpc_exit(task, NFS4_OK);
-		goto err_out_locked;
+		return;
 	}
-	spin_unlock(&ino->i_lock);
 
-	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task)) {
-		goto err_out;
-	}
 	rpc_call_start(task);
-	return;
-err_out:
-	spin_lock(&ino->i_lock);
-err_out_locked:
-	atomic_dec(&nfsi->layout->plh_outstanding);
-	spin_unlock(&ino->i_lock);
 }
 
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
@@ -5463,12 +5452,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		/* Fall through */
 	default:
 		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
-			struct inode *ino = lgp->args.inode;
-
 			dprintk("<-- %s retrying\n", __func__);
-			spin_lock(&ino->i_lock);
-			atomic_dec(&NFS_I(ino)->layout->plh_outstanding);
-			spin_unlock(&ino->i_lock);
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -5481,7 +5465,6 @@ static void nfs4_layoutget_release(void *calldata)
 	struct nfs4_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	put_layout_hdr(NFS_I(lgp->args.inode)->layout);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	put_nfs_open_context(lgp->args.ctx);
@@ -5530,16 +5513,6 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 		status = task->tk_status;
 	if (status == 0)
 		status = pnfs_layout_process(lgp);
-	else {
-		struct inode *ino = lgp->args.inode;
-		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-
-		spin_lock(&ino->i_lock);
-		atomic_dec(&lo->plh_outstanding);
-		if (!pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
-		spin_unlock(&ino->i_lock);
-	}
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
@@ -5640,15 +5613,6 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_layoutreturn *lrp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct nfs_inode *nfsi = NFS_I(lrp->args.inode);
-
-		if (pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
-			dprintk("%s: waiting on barrier\n", __func__);
-			rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
-			return;
-		}
-	}
 	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
@@ -5695,12 +5659,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 		struct inode *ino = lrp->args.inode;
 		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
 
-		spin_lock(&ino->i_lock);
-		lo->plh_block_lgets--;
-		atomic_dec(&lo->plh_outstanding);
-		if (!pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
-		spin_unlock(&ino->i_lock);
 		put_layout_hdr(lo);
 	}
 	kfree(calldata);
@@ -5731,14 +5689,6 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-		/* FIXME we should test for BULK here */
-		spin_lock(&lo->plh_inode->i_lock);
-		BUG_ON(lo->plh_block_lgets == 0);
-		atomic_inc(&lo->plh_outstanding);
-		spin_unlock(&lo->plh_inode->i_lock);
-	}
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 39e3067..6da026a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -153,7 +153,7 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 	int status;
 	struct nfs_fsinfo fsinfo;
 
-	if (is_ds_only_client(clp)) {
+	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
 		nfs4_schedule_state_renewal(clp);
 		return 0;
 	}
@@ -229,7 +229,6 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	int status;
-	u32 req_exchange_flags = clp->cl_exchange_flags;
 
 	nfs4_begin_drain_session(clp);
 	status = nfs4_proc_exchange_id(clp, cred);
@@ -238,16 +237,6 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
 	status = nfs4_proc_create_session(clp);
 	if (status != 0)
 		goto out;
-	if (is_ds_only_session(req_exchange_flags)) {
-		clp->cl_exchange_flags &=
-		     ~(EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_NON_PNFS);
-		if (!is_ds_only_session(clp->cl_exchange_flags)) {
-			nfs4_destroy_session(clp->cl_session);
-			clp->cl_session = NULL;
-			status = -ENOTSUPP;
-			goto out;
-		}
-	}
 	nfs41_setup_state_renewal(clp);
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 out:
@@ -679,22 +668,9 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
 	} else {
-		u32 roc_iomode;
-		struct nfs_inode *nfsi = NFS_I(state->inode);
-
-		/* FIXME: should return the layout only on last close */
-		if (has_layout(nfsi) &&
-		    (roc_iomode = pnfs_layout_roc_iomode(nfsi)) != 0) {
-			struct pnfs_layout_range range = {
-				.iomode = roc_iomode,
-				.offset = 0,
-				.length = NFS4_MAX_UINT64,
-			};
-
-			pnfs_return_layout(state->inode, &range, wait);
-		}
+		bool roc = pnfs_roc(state->inode);
 
-		nfs4_do_close(path, state, gfp_mask, wait);
+		nfs4_do_close(path, state, gfp_mask, wait, roc);
 	}
 }
 
@@ -1046,6 +1022,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
 }
+EXPORT_SYMBOL_GPL(nfs4_schedule_state_recovery);
 
 int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
@@ -1684,10 +1661,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs_client_return_marked_delegations(clp);
 			continue;
 		}
-		if (test_and_clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state)) {
-			nfs_client_return_layouts(clp);
-			continue;
-		}
 		/* Recall session slots */
 		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b8be3c5..e2adcaa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -293,25 +293,22 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
-	lseg->pls_notify_mask = 0;
 }
 
 static void free_lseg(struct pnfs_layout_segment *lseg)
 {
 	struct inode *ino = lseg->pls_layout->plh_inode;
-	u64 mask = lseg->pls_notify_mask;
 
 	BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	notify_drained(NFS_SERVER(ino)->nfs_client, mask);
-	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+	/* Matched by get_layout_hdr in pnfs_insert_layout */
 	put_layout_hdr(NFS_I(ino)->layout);
 }
 
 static void
-_put_lseg_common(struct pnfs_layout_segment *lseg)
+put_lseg_common(struct pnfs_layout_segment *lseg)
 {
-	struct inode *ino = lseg->pls_layout->plh_inode;
+	struct inode *inode = lseg->pls_layout->plh_inode;
 
 	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	list_del_init(&lseg->pls_list);
@@ -319,26 +316,8 @@ _put_lseg_common(struct pnfs_layout_segment *lseg)
 		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
 		/* Matched by initial refcount set in alloc_init_layout_hdr */
 		put_layout_hdr_locked(lseg->pls_layout);
-		if (!pnfs_layoutgets_blocked(lseg->pls_layout, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
-	}
-	rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
-}
-
-/* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
- * could sleep, so must be called outside of the lock.
- */
-static void
-put_lseg_locked(struct pnfs_layout_segment *lseg,
-		struct list_head *tmp_list)
-{
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount),
-		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
-		_put_lseg_common(lseg);
-		list_add(&lseg->pls_list, tmp_list);
 	}
+	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
 void
@@ -354,20 +333,13 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
 	ino = lseg->pls_layout->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
-		_put_lseg_common(lseg);
+		put_lseg_common(lseg);
 		spin_unlock(&ino->i_lock);
 		free_lseg(lseg);
 	}
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
-void get_lseg(struct pnfs_layout_segment *lseg)
-{
-	atomic_inc(&lseg->pls_refcount);
-	smp_mb__after_atomic_inc();
-}
-EXPORT_SYMBOL_GPL(get_lseg);
-
 static inline u64
 end_offset(u64 start, u64 len)
 {
@@ -448,12 +420,50 @@ static bool mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 		 * list.  It will now be removed when all
 		 * outstanding io is finished.
 		 */
-		put_lseg_locked(lseg, tmp_list);
+		dprintk("%s: lseg %p ref %d\n", __func__, lseg,
+			atomic_read(&lseg->pls_refcount));
+		if (atomic_dec_and_test(&lseg->pls_refcount)) {
+			put_lseg_common(lseg);
+			list_add(&lseg->pls_list, tmp_list);
+			rv = true;
+		}
 	}
 
 	return rv;
 }
 
+/* Returns count of number of matching invalid lsegs remaining in list
+ * after call.
+ */
+int
+mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+			    struct list_head *tmp_list,
+			    struct pnfs_layout_range *recall_range)
+{
+	struct pnfs_layout_segment *lseg, *next;
+	int invalid = 0, removed = 0;
+
+	dprintk("%s:Begin lo %p\n", __func__, lo);
+
+	if (list_empty(&lo->plh_segs)) {
+		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
+			put_layout_hdr_locked(lo);
+		return 0;
+	}
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
+		if (should_free_lseg(&lseg->pls_range, recall_range)) {
+			dprintk("%s: freeing lseg %p iomode %d "
+				"offset %llu length %llu\n", __func__,
+				lseg, lseg->pls_range.iomode,
+				lseg->pls_range.offset,
+				lseg->pls_range.length);
+			invalid++;
+			removed += mark_lseg_invalid(lseg, tmp_list);
+		}
+	dprintk("%s:Return %i\n", __func__, invalid - removed);
+	return invalid - removed;
+}
+
 /* Returns false if there was nothing to do, true otherwise */
 static bool
 pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
@@ -464,7 +474,6 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
-
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	if (list_empty(&lo->plh_segs)) {
 		if (!test_and_set_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags))
@@ -475,7 +484,8 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		if (should_free_lseg(&lseg->pls_range, range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
-				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
+				lseg, lseg->pls_range.iomode,
+				lseg->pls_range.offset,
 				lseg->pls_range.length);
 			mark_lseg_invalid(lseg, tmp_list);
 			rv = true;
@@ -505,32 +515,28 @@ pnfs_free_lseg_list(struct list_head *free_me)
 		list_del_init(&lo->plh_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	list_for_each_entry_safe(lseg, tmp, free_me, pls_list)
+	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
+		list_del(&lseg->pls_list);
 		free_lseg(lseg);
-	INIT_LIST_HEAD(free_me);
+	}
 }
 
 void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 	struct pnfs_layout_hdr *lo;
+	LIST_HEAD(tmp_list);
 	struct pnfs_layout_range range = {
 		.iomode = IOMODE_ANY,
 		.offset = 0,
 		.length = NFS4_MAX_UINT64,
 	};
-	LIST_HEAD(tmp_list);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		pnfs_clear_lseg_list(lo, &tmp_list, &range);
-		WARN_ON(!list_empty(&nfsi->layout->plh_segs));
-		WARN_ON(!list_empty(&nfsi->layout->plh_layouts));
-
-		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
-		put_layout_hdr_locked(lo);
+		mark_matching_lsegs_invalid(lo, &tmp_list, &range);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -587,6 +593,21 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	}
 }
 
+/* lget is set to 1 if called from inside send_layoutget call chain */
+static bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
+			int lget)
+{
+	if ((stateid) &&
+	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
+		return true;
+	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+		(list_empty(&lo->plh_segs) &&
+		 (atomic_read(&lo->plh_outstanding) > lget));
+}
+
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *open_state)
@@ -594,10 +615,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 	int status = 0;
 
 	dprintk("--> %s\n", __func__);
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	if (lo->plh_block_lgets ||
-	    test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+	spin_lock(&lo->plh_inode->i_lock);
+	if (pnfs_layoutgets_blocked(lo, NULL, 1)) {
 		status = -EAGAIN;
 	} else if (list_empty(&lo->plh_segs)) {
 		int seq;
@@ -609,6 +628,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 		} while (read_seqretry(&open_state->seqlock, seq));
 	} else
 		memcpy(dst->data, lo->plh_stateid.data, sizeof(lo->plh_stateid.data));
+	spin_unlock(&lo->plh_inode->i_lock);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
 }
@@ -633,10 +653,8 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	BUG_ON(ctx == NULL);
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
-	if (lgp == NULL) {
-		put_layout_hdr(lo);
+	if (lgp == NULL)
 		return NULL;
-	}
 	lgp->args.minlength = PAGE_CACHE_SIZE;
 	if (lgp->args.minlength > range->length)
 		lgp->args.minlength = range->length;
@@ -658,51 +676,6 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	return lseg;
 }
 
-bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
-				struct pnfs_layout_range *range,
-				int notify_idx, atomic_t *notify_count,
-				struct list_head *tmp_list)
-{
-	bool rv = false;
-	struct pnfs_layout_segment *lseg, *tmp;
-
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
-		if (should_free_lseg(&lseg->pls_range, range)) {
-			if (lseg->pls_notify_mask & (1 << notify_idx)) {
-				lseg->pls_notify_mask |= (1 << notify_idx);
-				atomic_inc(notify_count);
-			}
-			mark_lseg_invalid(lseg, tmp_list);
-			rv = true;
-		}
-
-	dprintk("%s:Return %d\n", __func__, rv);
-	return rv;
-}
-
-/* Return true if there is layout based io in progress in the given range.
- * Assumes range has already been marked invalid, and layout marked to
- * prevent any new lseg from being inserted.
- */
-bool
-pnfs_return_layout_barrier(struct nfs_inode *nfsi,
-			   struct pnfs_layout_range *range)
-{
-	struct pnfs_layout_segment *lseg;
-	bool ret = false;
-
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
-		if (should_free_lseg(&lseg->pls_range, range)) {
-			ret = true;
-			break;
-		}
-	spin_unlock(&nfsi->vfs_inode.i_lock);
-	dprintk("%s:Return %d\n", __func__, ret);
-	return ret;
-}
-
 static int
 return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
 {
@@ -754,7 +727,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		dprintk("%s: no layout segments to return\n", __func__);
 		goto out;
 	}
-	lo->plh_block_lgets++;
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
@@ -775,6 +747,83 @@ out:
 	return status;
 }
 
+bool pnfs_roc(struct inode *ino)
+{
+	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_segment *lseg, *tmp;
+	LIST_HEAD(tmp_list);
+	bool found = false;
+
+	spin_lock(&ino->i_lock);
+	lo = NFS_I(ino)->layout;
+	if (!lo || !test_and_clear_bit(NFS_LAYOUT_ROC, &lo->plh_flags) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags))
+		goto out_nolayout;
+	list_for_each_entry_safe(lseg, tmp, &lo->plh_segs, pls_list)
+		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+			mark_lseg_invalid(lseg, &tmp_list);
+			found = true;
+		}
+	if (!found)
+		goto out_nolayout;
+	lo->plh_block_lgets++;
+	get_layout_hdr(lo); /* matched in pnfs_roc_release */
+	spin_unlock(&ino->i_lock);
+	pnfs_free_lseg_list(&tmp_list);
+	return true;
+
+out_nolayout:
+	spin_unlock(&ino->i_lock);
+	return false;
+}
+
+void pnfs_roc_release(struct inode *ino)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&ino->i_lock);
+	lo = NFS_I(ino)->layout;
+	lo->plh_block_lgets--;
+	put_layout_hdr_locked(lo);
+	spin_unlock(&ino->i_lock);
+}
+
+void pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&ino->i_lock);
+	lo = NFS_I(ino)->layout;
+	if ((int)(barrier - lo->plh_barrier) > 0)
+		lo->plh_barrier = barrier;
+	spin_unlock(&ino->i_lock);
+}
+
+bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_segment *lseg;
+	bool found = false;
+
+	spin_lock(&ino->i_lock);
+	list_for_each_entry(lseg, &nfsi->layout->plh_segs, pls_list)
+		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+			found = true;
+			break;
+		}
+	if (!found) {
+		struct pnfs_layout_hdr *lo = nfsi->layout;
+		u32 current_seqid = be32_to_cpu(lo->plh_stateid.stateid.seqid);
+
+		/* Since close does not return a layout stateid for use as
+		 * a barrier, we choose the worst-case barrier.
+		 */
+		*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
+	}
+	spin_unlock(&ino->i_lock);
+	return found;
+}
+
 /*
  * Compare two layout segments for sorting into layout cache.
  * We want to preferentially return RW over RO layouts, so ensure those
@@ -827,9 +876,6 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 	}
 	if (!found) {
 		list_add_tail(&lseg->pls_list, &lo->plh_segs);
-		if (list_is_singular(&lo->plh_segs) &&
-		    !pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(lo->plh_inode)->lo_rpcwaitq_stateid);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu at tail\n",
 			__func__, lseg, lseg->pls_range.iomode,
@@ -925,8 +971,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    is_matching_lseg(lseg, range)) {
-			get_lseg(lseg);
-			ret = lseg;
+			ret = get_lseg(lseg);
 			break;
 		}
 		if (cmp_layout(range, &lseg->pls_range) > 0)
@@ -970,14 +1015,25 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	}
 
+	/* Do we even need to bother with this? */
+	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+		dprintk("%s matches recall, use MDS\n", __func__);
+		goto out_unlock;
+	}
+
+	/* if LAYOUTGET already failed once we don't try again */
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
+		goto out_unlock;
+
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_find_lseg(lo, &arg);
 	if (lseg)
 		goto out_unlock;
 
-	/* if LAYOUTGET already failed once we don't try again */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
+	if (pnfs_layoutgets_blocked(lo, NULL, 0))
 		goto out_unlock;
+	atomic_inc(&lo->plh_outstanding);
 
 	get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs))
@@ -999,29 +1055,17 @@ pnfs_update_layout(struct inode *ino,
 		list_del_init(&lo->plh_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
+	atomic_dec(&lo->plh_outstanding);
+	put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->plh_flags, lseg);
+		nfsi->layout->plh_flags ? nfsi->layout->plh_flags : -1, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
 	goto out;
 }
 
-bool
-pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid)
-{
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	if ((stateid) &&
-	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
-		return true;
-	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags) ||
-		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		(list_empty(&lo->plh_segs) &&
-		 (atomic_read(&lo->plh_outstanding) != 0));
-}
-
 int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
@@ -1041,52 +1085,40 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			status = PTR_ERR(lseg);
 		dprintk("%s: Could not allocate layout: error %d\n",
 		       __func__, status);
-		spin_lock(&ino->i_lock);
 		goto out;
 	}
 
-	/* decrement needs to be done before call to pnfs_layoutget_blocked */
-	atomic_dec(&lo->plh_outstanding);
-	spin_lock(&clp->cl_lock);
-	if (matches_outstanding_recall(ino, &res->range)) {
-		spin_unlock(&clp->cl_lock);
+	spin_lock(&ino->i_lock);
+	if (test_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state) ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		dprintk("%s forget reply due to recall\n", __func__);
 		goto out_forget_reply;
 	}
-	spin_unlock(&clp->cl_lock);
 
-	spin_lock(&ino->i_lock);
-	if (pnfs_layoutgets_blocked(lo, &res->stateid)) {
+	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
 	init_lseg(lo, lseg);
 	lseg->pls_range = res->range;
-	get_lseg(lseg);
-	*lgp->lsegpp = lseg;
+	*lgp->lsegpp = get_lseg(lseg);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
-		/* FI: This needs to be re-examined.  At lo level,
-		 * all it needs is a bit indicating whether any of
-		 * the lsegs in the list have the flags set.
-		 */
-		lo->roc_iomode |= res->range.iomode;
+		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
+		set_bit(NFS_LAYOUT_ROC, &lo->plh_flags);
 	}
 
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
-out:
-	if (!pnfs_layoutgets_blocked(lo, NULL))
-		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 	spin_unlock(&ino->i_lock);
+out:
 	return status;
 
 out_forget_reply:
 	spin_unlock(&ino->i_lock);
 	lseg->pls_layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	spin_lock(&ino->i_lock);
 	goto out;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 60d0fbe..d296444 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -35,6 +35,7 @@
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
+	NFS_LSEG_ROC,		/* roc bit received from server */
 };
 
 struct pnfs_layout_segment {
@@ -43,7 +44,6 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
-	u64 pls_notify_mask;
 };
 
 enum pnfs_try_status {
@@ -66,6 +66,7 @@ enum {
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_NEED_LCOMMIT,	/* LAYOUTCOMMIT needed */
+	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
@@ -177,15 +178,6 @@ struct pnfs_device {
 	unsigned int  pglen;
 };
 
-struct pnfs_cb_lrecall_info {
-	struct list_head	pcl_list; /* hook into cl_layoutrecalls list */
-	atomic_t		pcl_count;
-	int			pcl_notify_idx;
-	struct nfs_client	*pcl_clp;
-	struct inode		*pcl_ino;
-	struct cb_layoutrecallargs pcl_args;
-};
-
 #define NFS4_PNFS_GETDEVLIST_MAXNUM 16
 
 struct pnfs_devicelist {
@@ -258,14 +250,12 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
-void get_lseg(struct pnfs_layout_segment *lseg);
 void put_lseg(struct pnfs_layout_segment *lseg);
 bool should_free_lseg(struct pnfs_layout_range *lseg_range,
 		      struct pnfs_layout_range *recall_range);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   loff_t pos, u64 count, enum pnfs_iomode access_type);
-bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *mntfh, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -287,7 +277,6 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
 			    size_t *);
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
-bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
@@ -299,10 +288,6 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
-bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
-				struct pnfs_layout_range *range,
-				int notify_bit, atomic_t *notify_count,
-				struct list_head *tmp_list);
 void pnfs_read_done(struct nfs_read_data *);
 void pnfs_writeback_done(struct nfs_write_data *);
 void pnfs_commit_done(struct nfs_write_data *);
@@ -310,6 +295,13 @@ int _pnfs_write_begin(struct inode *inode, struct page *page,
 		      loff_t pos, unsigned len,
 		      struct pnfs_layout_segment *lseg,
 		      struct pnfs_fsdata **fsdata);
+int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+				struct list_head *tmp_list,
+				struct pnfs_layout_range *recall_range);
+bool pnfs_roc(struct inode *ino);
+void pnfs_roc_release(struct inode *ino);
+void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
+bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 
 static inline bool
 has_layout(struct nfs_inode *nfsi)
@@ -323,6 +315,16 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
 }
 
+static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
+{
+	if (lseg) {
+		atomic_inc(&lseg->pls_refcount);
+		smp_mb__after_atomic_inc();
+	}
+	return lseg;
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
@@ -458,8 +460,10 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
 
-static inline void get_lseg(struct pnfs_layout_segment *lseg)
+static inline struct pnfs_layout_segment *
+get_lseg(struct pnfs_layout_segment *lseg)
 {
+	return NULL;
 }
 
 static inline void put_lseg(struct pnfs_layout_segment *lseg)
@@ -517,6 +521,28 @@ static inline int pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	return 0;
 }
 
+static inline void
+pnfs_roc_release(struct inode *ino)
+{
+}
+
+static inline void
+pnfs_roc_set_barrier(struct inode *ino, u32 barrier)
+{
+}
+
+static inline bool
+pnfs_roc_drain(struct inode *ino, u32 *barrier)
+{
+	return false;
+}
+
+static inline bool
+pnfs_roc(struct inode *ino)
+{
+	return false;
+}
+
 static inline bool
 pnfs_ld_layoutret_on_setattr(struct inode *inode)
 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0b69651..db78995 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -190,8 +190,6 @@ struct nfs_inode {
 	struct rw_semaphore	rwsem;
 
 	/* pNFS layout information */
-	struct rpc_wait_queue lo_rpcwaitq;
-	struct rpc_wait_queue	lo_rpcwaitq_stateid;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ffbff58..8c784d0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -30,6 +30,8 @@ struct nfs_client {
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
+#define NFS_CS_STOP_RENEW	4		/* no more state to renew */
+#define NFS_CS_CHECK_LEASE_TIME	5		/* need to check lease time */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
@@ -79,12 +81,6 @@ struct nfs_client {
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
 	struct list_head	cl_layouts;
-	atomic_t		cl_recall_count; /* no. of lsegs in recall */
-	struct list_head	cl_layoutrecalls;
-	unsigned long		cl_cb_lrecall_count;
-#define PNFS_MAX_CB_LRECALLS (64)
-	atomic_t		*cl_drain_notification[PNFS_MAX_CB_LRECALLS];
-	struct rpc_wait_queue	cl_rpcwaitq_recall;
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
@@ -160,6 +156,7 @@ struct nfs_server {
 						   that are supported on this
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+	struct rpc_wait_queue		roc_rpcwaitq;
 	void			       *pnfs_ld_data; /* Per-mount data */
 	unsigned int			ds_rsize;  /* Data server read size */
 	unsigned int			ds_wsize;  /* Data server write size */
-- 
1.7.3.4

