Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51925 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933492Ab0LUCVD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 21:21:03 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/14] pnfs: wave 2: layout roc code
Date: Mon, 20 Dec 2010 21:20:46 -0500
Message-Id: <1292898046-7336-15-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
References: <1292898046-7336-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A lsyout can request return-on-close.  How this interacts with the
forgetful model of never sending LAYOUTRETURNS is a bit ambiguous.
We forget any layouts marked roc, and wait for them to be completely
forgotten before continuing with the close.  In addition, to compensate
for races with any inflight LAYOUTGETs, and the fact that we do not get
any layout stateid back from the server, we set the barrier to the worst
case scenario of current_seqid + number of outstanding LAYOUTGETS.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c         |    1 +
 fs/nfs/nfs4_fs.h       |    2 +-
 fs/nfs/nfs4proc.c      |   17 ++++++++-
 fs/nfs/nfs4state.c     |    7 +++-
 fs/nfs/pnfs.c          |   84 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h          |   27 +++++++++++++++
 include/linux/nfs_fs.h |    1 +
 7 files changed, 134 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 43a69da..c64bb40 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1450,6 +1450,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
+	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layoutreturn");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 426e887..e5b0bf0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,7 +242,7 @@ extern int nfs4_proc_async_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
+extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 58cebac..f1b3c63 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1838,6 +1838,8 @@ struct nfs4_closedata {
 	struct nfs_closeres res;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
+	bool roc;
+	u32 roc_barrier;
 };
 
 static void nfs4_free_closedata(void *data)
@@ -1845,6 +1847,8 @@ static void nfs4_free_closedata(void *data)
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state_owner *sp = calldata->state->owner;
 
+	if (calldata->roc)
+		pnfs_roc_release(calldata->state->inode);
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
@@ -1877,6 +1881,9 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	 */
 	switch (task->tk_status) {
 		case 0:
+			if (calldata->roc)
+				pnfs_roc_set_barrier(state->inode,
+						     calldata->roc_barrier);
 			nfs_set_open_stateid(state, &calldata->res.stateid, 0);
 			renew_lease(server, calldata->timestamp);
 			nfs4_close_clear_stateid_flags(state,
@@ -1929,8 +1936,11 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 
-	if (calldata->arg.fmode == 0)
+	if (calldata->arg.fmode == 0) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE];
+		if (calldata->roc)
+			pnfs_roc_drain(state->inode, &calldata->roc_barrier, task);
+	}
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
@@ -1958,7 +1968,7 @@ static const struct rpc_call_ops nfs4_close_ops = {
  *
  * NOTE: Caller must be holding the sp->so_owner semaphore!
  */
-int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait)
+int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	struct nfs4_closedata *calldata;
@@ -1993,6 +2003,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
+	calldata->roc = roc;
 	path_get(path);
 	calldata->path = *path;
 
@@ -2010,6 +2021,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, i
 out_free_calldata:
 	kfree(calldata);
 out:
+	if (roc)
+		pnfs_roc_release(state->inode);
 	nfs4_put_open_state(state);
 	nfs4_put_state_owner(sp);
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index fb23a32..a472b7c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -607,8 +607,11 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
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
index 531d98c..3f39640 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -258,6 +258,7 @@ put_lseg_locked(struct pnfs_layout_segment *lseg,
 			spin_unlock(&clp->cl_lock);
 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->layout->plh_flags);
 		}
+		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 		list_add(&lseg->fi_list, tmp_list);
 	}
 }
@@ -471,6 +472,84 @@ send_layoutget(struct pnfs_layout_hdr *lo,
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
+	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
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
+void pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_segment *lseg;
+	bool found = false;
+
+	spin_lock(&ino->i_lock);
+	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
+		if (test_bit(NFS_LSEG_ROC, &lseg->pls_flags)) {
+			rpc_sleep_on(&NFS_I(ino)->lo_rpcwaitq, task, NULL);
+			found = true;
+			break;
+		}
+	if (!found) {
+		struct pnfs_layout_hdr *lo = nfsi->layout;
+		u32 current_seqid = be32_to_cpu(lo->stateid.stateid.seqid);
+
+		/* Since close does not return a layout stateid for use as
+		 * a barrier, we choose the worst-case barrier.
+		 */
+		*barrier = current_seqid + atomic_read(&lo->plh_outstanding);
+	}
+	spin_unlock(&ino->i_lock);
+	return;
+}
+
 /*
  * Compare two layout segments for sorting into layout cache.
  * We want to preferentially return RW over RO layouts, so ensure those
@@ -729,6 +808,11 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
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
index 4c66a97..818fc41 100644
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
 
@@ -163,6 +165,10 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 bool mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				 struct list_head *tmp_list,
 				 u32 iomode);
+bool pnfs_roc(struct inode *ino);
+void pnfs_roc_release(struct inode *ino);
+void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
+void pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
 
 
 static inline int lo_fail_bit(u32 iomode)
@@ -194,6 +200,27 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
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
+static inline void
+pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task)
+{
+}
+
 static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
 {
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 29d504d..90515de 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -190,6 +190,7 @@ struct nfs_inode {
 	struct rw_semaphore	rwsem;
 
 	/* pNFS layout information */
+	struct rpc_wait_queue lo_rpcwaitq;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.2.1

