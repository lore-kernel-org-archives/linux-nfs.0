Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27362 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221Ab1AFLhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 06:37:03 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/15] pnfs: layout roc code
Date: Thu,  6 Jan 2011 06:36:32 -0500
Message-Id: <1294313792-14280-16-git-send-email-iisaman@netapp.com>
In-Reply-To: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
References: <1294313792-14280-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A layout can request return-on-close.  How this interacts with the
forgetful model of never sending LAYOUTRETURNS is a bit ambiguous.
We forget any layouts marked roc, and wait for them to be completely
forgotten before continuing with the close.  In addition, to compensate
for races with any inflight LAYOUTGETs, and the fact that we do not get
any layout stateid back from the server, we set the barrier to the worst
case scenario of current_seqid + number of outstanding LAYOUTGETS.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/client.c           |   12 ++++++
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/nfs4proc.c         |   21 ++++++++++-
 fs/nfs/nfs4state.c        |    7 +++-
 fs/nfs/pnfs.c             |   86 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h             |   29 +++++++++++++++
 include/linux/nfs_fs_sb.h |    1 +
 7 files changed, 152 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 11eb993..684b677 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -244,6 +244,11 @@ static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
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
@@ -256,6 +261,11 @@ void nfs_cleanup_cb_ident_idr(void)
 static void nfs_cb_idr_remove_locked(struct nfs_client *clp)
 {
 }
+
+static void pnfs_init_server(struct nfs_server *server)
+{
+}
+
 #endif /* CONFIG_NFS_V4 */
 
 /*
@@ -1024,6 +1034,8 @@ static struct nfs_server *nfs_alloc_server(void)
 		return NULL;
 	}
 
+	pnfs_init_server(server);
+
 	return server;
 }
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 8f169dc..18d64cb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
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
index a3549ce..88f590f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1839,6 +1839,8 @@ struct nfs4_closedata {
 	struct nfs_closeres res;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
+	bool roc;
+	u32 roc_barrier;
 };
 
 static void nfs4_free_closedata(void *data)
@@ -1846,6 +1848,8 @@ static void nfs4_free_closedata(void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state_owner *sp = calldata->state->owner;
 
+	if (calldata->roc)
+		pnfs_roc_release(calldata->state->inode);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
@@ -1878,6 +1882,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
+			if (calldata->roc)
+				pnfs_roc_set_barrier(state->inode,
+						     calldata->roc_barrier);
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
 			nfs4_close_clear_stateid_flags(state,
@@ -1930,8 +1937,15 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
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
@@ -1959,7 +1973,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -1994,6 +2008,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
+	calldata->roc = roc;
 	path_get(path);
 	calldata->path = *path;
 
@@ -2011,6 +2026,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 out_free_calldata:
 	kfree(calldata);
 out:
+	if (roc)
+		pnfs_roc_release(state->inode);
 	nfs4_put_open_state(state);
 	nfs4_put_state_owner(sp);
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6891ded..286084f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -606,8 +606,11 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 	if (!call_close) {
 		nfs4_put_open_state(state);
 		nfs4_put_state_owner(owner);
-	} else
-		nfs4_do_close(path, state, gfp_mask, wait);
+	} else {
+		bool roc = pnfs_roc(state->inode);
+
+		nfs4_do_close(path, state, gfp_mask, wait, roc);
+	}
 }
 
 void nfs4_close_state(struct path *path, struct nfs4_state *state, fmode_t fmode)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf4186b..bc40897 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -256,6 +256,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 			spin_unlock(&clp->cl_lock);
 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->pls_layout->plh_flags);
 		}
+		rpc_wake_up(&NFS_SERVER(ino)->roc_rpcwaitq);
 		list_add(&lseg->pls_list, tmp_list);
 		return 1;
 	}
@@ -401,7 +402,8 @@ pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
 	if ((stateid) &&
 	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
 		return true;
-	return test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 		(list_empty(&lo->plh_segs) &&
 		 (atomic_read(&lo->plh_outstanding) > lget));
 }
@@ -474,6 +476,83 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	return lseg;
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
@@ -732,6 +811,11 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	*lgp->lsegpp = lseg;
 	pnfs_insert_layout(lo, lseg);
 
+	if (res->return_on_close) {
+		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
+		set_bit(NFS_LAYOUT_ROC, &lo->plh_flags);
+	}
+
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
 	spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f91d0d4..e2612ea 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -32,6 +32,7 @@
 
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
+	NFS_LSEG_ROC,		/* roc bit received from server */
 };
 
 struct pnfs_layout_segment {
@@ -50,6 +51,7 @@ enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
+	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
@@ -72,6 +74,7 @@ struct pnfs_layout_hdr {
 	struct list_head	plh_segs;      /* layout segments list */
 	nfs4_stateid		plh_stateid;
 	atomic_t		plh_outstanding; /* number of RPCs out */
+	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
 	struct inode		*plh_inode;
@@ -162,6 +165,10 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				u32 iomode);
+bool pnfs_roc(struct inode *ino);
+void pnfs_roc_release(struct inode *ino);
+void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
+bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
 
 
 static inline int lo_fail_bit(u32 iomode)
@@ -193,6 +200,28 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	return NULL;
 }
 
+static inline bool
+pnfs_roc(struct inode *ino)
+{
+	return false;
+}
+
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
 static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
 {
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e93ada0..7f20c0b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -149,6 +149,7 @@ struct nfs_server {
 						   that are supported on this
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+	struct rpc_wait_queue	roc_rpcwaitq;
 #endif
 	void (*destroy)(struct nfs_server *);
 
-- 
1.7.2.1

