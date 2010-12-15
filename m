Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47300 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab0LOSce (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Dec 2010 13:32:34 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] Revert "pnfs-submit: wave2: Don't wait in layoutget"
Date: Wed, 15 Dec 2010 20:32:28 +0200
Message-Id: <1292437948-21945-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D0908F9.4060208@panasas.com>
References: <4D0908F9.4060208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This reverts commit 9628f174680a6ec76aa6e1afa8678631a5efd39b.

Conflicts:

	fs/nfs/nfs4proc.c
	fs/nfs/pnfs.c
---
 fs/nfs/callback_proc.c    |    4 +++
 fs/nfs/client.c           |    2 +
 fs/nfs/inode.c            |    1 +
 fs/nfs/nfs4proc.c         |   47 ++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.c             |   58 +++++++++++++++++++++------------------------
 fs/nfs/pnfs.h             |    1 +
 include/linux/nfs_fs.h    |    1 +
 include/linux/nfs_fs_sb.h |    1 +
 8 files changed, 82 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b6a2903..6d48236 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -221,6 +221,7 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 		list_del(&cb_info->pcl_list);
 		clp->cl_cb_lrecall_count--;
 		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
+		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		kfree(cb_info);
 	}
 }
@@ -372,6 +373,7 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 		list_del(&new->pcl_list);
 		clp->cl_cb_lrecall_count--;
 		clp->cl_drain_notification[1 << bit_num] = NULL;
+		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		spin_unlock(&clp->cl_lock);
 		if (res == NFS4_OK) {
 			if (args->cbl_recall_type == RETURN_FILE) {
@@ -380,6 +382,8 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				lo = NFS_I(new->pcl_ino)->layout;
 				spin_lock(&lo->inode->i_lock);
 				lo->plh_block_lgets--;
+				if (!pnfs_layoutgets_blocked(lo, NULL))
+					rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
 				spin_unlock(&lo->inode->i_lock);
 				put_layout_hdr(lo);
 			}
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f8e712f..172175f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -159,6 +159,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 #if defined(CONFIG_NFS_V4_1)
 	INIT_LIST_HEAD(&clp->cl_layouts);
 	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq_recall,
+			    "NFS client CB_LAYOUTRECALLS");
 #endif
 	nfs_fscache_get_client_cookie(clp);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e557d96..1e19d5d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1461,6 +1461,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layoutreturn");
+	rpc_init_wait_queue(&nfsi->lo_rpcwaitq_stateid, "pNFS Layoutstateid");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1c79c09..b0a48d8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5357,17 +5357,43 @@ static void
 nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
-	struct nfs_server *server = NFS_SERVER(lgp->args.inode);
+	struct inode *ino = lgp->args.inode;
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct nfs_server *server = NFS_SERVER(ino);
+	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 
 	dprintk("--> %s\n", __func__);
+	spin_lock(&clp->cl_lock);
+	if (matches_outstanding_recall(ino, &lgp->args.range)) {
+		rpc_sleep_on(&clp->cl_rpcwaitq_recall, task, NULL);
+		spin_unlock(&clp->cl_lock);
+		return;
+	}
+	spin_unlock(&clp->cl_lock);
 	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
 	 * right now covering the LAYOUTGET we are about to send.
 	 * However, that is not so catastrophic, and there seems
 	 * to be no way to prevent it completely.
 	 */
+	spin_lock(&ino->i_lock);
+	if (pnfs_layoutgets_blocked(nfsi->layout, NULL)) {
+		rpc_sleep_on(&nfsi->lo_rpcwaitq_stateid, task, NULL);
+		spin_unlock(&ino->i_lock);
+		return;
+	}
+	/* This needs after above check but atomic with it in order to properly
+	 * serialize openstateid LAYOUTGETs.
+	 */
+	atomic_inc(&nfsi->layout->plh_outstanding);
+	spin_unlock(&ino->i_lock);
+
 	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task))
+				&lgp->res.seq_res, 0, task)) {
+		spin_lock(&ino->i_lock);
+		atomic_dec(&nfsi->layout->plh_outstanding);
+		spin_unlock(&ino->i_lock);
 		return;
+	}
 	rpc_call_start(task);
 }
 
@@ -5395,6 +5421,11 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		/* Fall through */
 	default:
 		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
+			struct inode *ino = lgp->args.inode;
+
+			spin_lock(&ino->i_lock);
+			atomic_dec(&NFS_I(ino)->layout->plh_outstanding);
+			spin_unlock(&ino->i_lock);
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -5456,6 +5487,16 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 		status = task->tk_status;
 	if (status == 0)
 		status = pnfs_layout_process(lgp);
+	else {
+		struct inode *ino = lgp->args.inode;
+		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
+
+		spin_lock(&ino->i_lock);
+		atomic_dec(&lo->plh_outstanding);
+		if (!pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
+		spin_unlock(&ino->i_lock);
+	}
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
@@ -5614,6 +5655,8 @@ static void nfs4_layoutreturn_release(void *calldata)
 		spin_lock(&ino->i_lock);
 		lo->plh_block_lgets--;
 		atomic_dec(&lo->plh_outstanding);
+		if (!pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 		spin_unlock(&ino->i_lock);
 		put_layout_hdr(lo);
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8b44c41..b778032 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -308,6 +308,8 @@ _put_lseg_common(struct pnfs_layout_segment *lseg)
 		list_del_init(&lseg->layout->layouts);
 		spin_unlock(&clp->cl_lock);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->layout->plh_flags);
+		if (!pnfs_layoutgets_blocked(lseg->layout, NULL))
+			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 	}
 	rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 }
@@ -481,21 +483,6 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	}
 }
 
-/* lget is set to 1 if called from inside send_layoutget call chain */
-static bool
-pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
-			int lget)
-{
-	assert_spin_locked(&lo->inode->i_lock);
-	if ((stateid) &&
-	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
-		return true;
-	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		(list_empty(&lo->segs) &&
-		 (atomic_read(&lo->plh_outstanding) > lget));
-}
-
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *open_state)
@@ -504,7 +491,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->inode->i_lock);
-	if (pnfs_layoutgets_blocked(lo, NULL, 1)) {
+	if (lo->plh_block_lgets ||
+	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
 		/* We avoid -EAGAIN, as that has special meaning to
 		 * some callers.
 		 */
@@ -719,6 +707,9 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 	}
 	if (!found) {
 		list_add_tail(&lseg->fi_list, &lo->segs);
+		if (list_is_singular(&lo->segs) &&
+		    !pnfs_layoutgets_blocked(lo, NULL))
+			rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu at tail\n",
 			__func__, lseg, lseg->range.iomode,
@@ -836,13 +827,6 @@ pnfs_update_layout(struct inode *ino,
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
-	spin_lock(&clp->cl_lock);
-	if (matches_outstanding_recall(ino, &arg)) {
-		dprintk("%s matches recall, use MDS\n", __func__);
-		spin_unlock(&clp->cl_lock);
-		return NULL;
-	}
-	spin_unlock(&clp->cl_lock);
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino);
 	if (lo == NULL) {
@@ -859,10 +843,6 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
-	if (pnfs_layoutgets_blocked(lo, NULL, 0))
-		goto out_unlock;
-	atomic_inc(&lo->plh_outstanding);
-
 	get_layout_hdr(lo); /* Matched in pnfs_layoutget_release */
 	if (list_empty(&lo->segs)) {
 		/* The lo must be on the clp list if there is any
@@ -886,8 +866,6 @@ pnfs_update_layout(struct inode *ino,
 		}
 		spin_unlock(&ino->i_lock);
 	}
-	atomic_dec(&lo->plh_outstanding);
-	spin_unlock(&ino->i_lock);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
@@ -897,6 +875,19 @@ out_unlock:
 	goto out;
 }
 
+bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid)
+{
+	assert_spin_locked(&lo->inode->i_lock);
+	if ((stateid) &&
+	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
+		return true;
+	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+		(list_empty(&lo->segs) &&
+		 (atomic_read(&lo->plh_outstanding) != 0));
+}
+
 int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
@@ -927,11 +918,13 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			status = PTR_ERR(lseg);
 		dprintk("%s: Could not allocate layout: error %d\n",
 		       __func__, status);
+		spin_lock(&ino->i_lock);
 		goto out;
 	}
 
 	spin_lock(&ino->i_lock);
 	/* decrement needs to be done before call to pnfs_layoutget_blocked */
+	atomic_dec(&lo->plh_outstanding);
 	spin_lock(&clp->cl_lock);
 	if (matches_outstanding_recall(ino, &res->range)) {
 		spin_unlock(&clp->cl_lock);
@@ -940,7 +933,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	spin_unlock(&clp->cl_lock);
 
-	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
+	if (pnfs_layoutgets_blocked(lo, &res->stateid)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
@@ -960,14 +953,17 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid, false);
-	spin_unlock(&ino->i_lock);
 out:
+	if (!pnfs_layoutgets_blocked(lo, NULL))
+		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
+	spin_unlock(&ino->i_lock);
 	return status;
 
 out_forget_reply:
 	spin_unlock(&ino->i_lock);
 	lseg->layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	spin_lock(&ino->i_lock);
 	goto out;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index b011b3c..3585bd2 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -218,6 +218,7 @@ enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
+bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index caed83e..b4bb8d6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,6 +191,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct rpc_wait_queue lo_rpcwaitq;
+	struct rpc_wait_queue	lo_rpcwaitq_stateid;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b02f486..96cb62f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -88,6 +88,7 @@ struct nfs_client {
 	unsigned long		cl_cb_lrecall_count;
 #define PNFS_MAX_CB_LRECALLS (64)
 	atomic_t		*cl_drain_notification[PNFS_MAX_CB_LRECALLS];
+	struct rpc_wait_queue	cl_rpcwaitq_recall;
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.7.2.3

