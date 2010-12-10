Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab0LJGIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:51 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLp023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:50 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 14/22] pnfs-submit: wave2: Don't wait in layoutget
Date: Thu,  9 Dec 2010 20:22:49 -0500
Message-Id: <1291944177-7819-15-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

instead, just go direct to MDS.  This simplifies things a lot.  The
primary problem that initiated this is that plh_outstanding accounting
was not correct, and there is no easy way to make it correct if it is
incremented within layoutget_prepare (due to ctrl-c issues).

This patch basically does three things:
- remove the rpc waitqs
- push plh_outstanding accounting outside of the layoutget rpc code
- shift pnfs_layoutgets_blocked() up and make static

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c    |    4 ---
 fs/nfs/client.c           |    2 -
 fs/nfs/inode.c            |    1 -
 fs/nfs/nfs4proc.c         |   45 +--------------------------------
 fs/nfs/pnfs.c             |   59 +++++++++++++++++++++++---------------------
 fs/nfs/pnfs.h             |    1 -
 include/linux/nfs_fs.h    |    1 -
 include/linux/nfs_fs_sb.h |    1 -
 8 files changed, 33 insertions(+), 81 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index d4aec46..4cd7e84 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -224,7 +224,6 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 		list_del(&cb_info->pcl_list);
 		clp->cl_cb_lrecall_count--;
 		clp->cl_drain_notification[1 << cb_info->pcl_notify_bit] = NULL;
-		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		kfree(cb_info);
 	}
 }
@@ -376,7 +375,6 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 		list_del(&new->pcl_list);
 		clp->cl_cb_lrecall_count--;
 		clp->cl_drain_notification[1 << bit_num] = NULL;
-		rpc_wake_up(&clp->cl_rpcwaitq_recall);
 		spin_unlock(&clp->cl_lock);
 		if (res == NFS4_OK) {
 			if (args->cbl_recall_type == RETURN_FILE) {
@@ -385,8 +383,6 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				lo = NFS_I(new->pcl_ino)->layout;
 				spin_lock(&lo->inode->i_lock);
 				lo->plh_block_lgets--;
-				if (!pnfs_layoutgets_blocked(lo, NULL))
-					rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
 				spin_unlock(&lo->inode->i_lock);
 				put_layout_hdr(new->pcl_ino);
 			}
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 172175f..f8e712f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -159,8 +159,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 #if defined(CONFIG_NFS_V4_1)
 	INIT_LIST_HEAD(&clp->cl_layouts);
 	INIT_LIST_HEAD(&clp->cl_layoutrecalls);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq_recall,
-			    "NFS client CB_LAYOUTRECALLS");
 #endif
 	nfs_fscache_get_client_cookie(clp);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bbeb337..54a2fc7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1460,7 +1460,6 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layoutreturn");
-	rpc_init_wait_queue(&nfsi->lo_rpcwaitq_stateid, "pNFS Layoutstateid");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5f6120a..b161393 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5357,43 +5357,17 @@ static void
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
-		return;
-	}
-	/* This needs after above check but atomic with it in order to properly
-	 * serialize openstateid LAYOUTGETs.
-	 */
-	nfsi->layout->plh_outstanding++;
-	spin_unlock(&ino->i_lock);
-
 	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task)) {
-		spin_lock(&ino->i_lock);
-		nfsi->layout->plh_outstanding--;
-		spin_unlock(&ino->i_lock);
+				&lgp->res.seq_res, 0, task))
 		return;
-	}
 	rpc_call_start(task);
 }
 
@@ -5422,9 +5396,6 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	default:
 		if (nfs4_async_handle_error(task, NFS_SERVER(ino),
 					    NULL, NULL) == -EAGAIN) {
-			spin_lock(&ino->i_lock);
-			NFS_I(ino)->layout->plh_outstanding--;
-			spin_unlock(&ino->i_lock);
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -5486,16 +5457,6 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 		status = task->tk_status;
 	if (status == 0)
 		status = pnfs_layout_process(lgp);
-	else {
-		struct inode *ino = lgp->args.inode;
-		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-
-		spin_lock(&ino->i_lock);
-		lo->plh_outstanding--;
-		if (!pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
-		spin_unlock(&ino->i_lock);
-	}
 	rpc_put_task(task);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
@@ -5654,8 +5615,6 @@ static void nfs4_layoutreturn_release(void *calldata)
 		spin_lock(&ino->i_lock);
 		lo->plh_block_lgets--;
 		lo->plh_outstanding--;
-		if (!pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 		spin_unlock(&ino->i_lock);
 		put_layout_hdr(ino);
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e35706..abb3eb0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -297,8 +297,6 @@ _put_lseg_common(struct pnfs_layout_segment *lseg)
 		list_del_init(&lseg->layout->layouts);
 		spin_unlock(&clp->cl_lock);
 		clear_bit(NFS_LAYOUT_BULK_RECALL, &lseg->layout->plh_flags);
-		if (!pnfs_layoutgets_blocked(lseg->layout, NULL))
-			rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq_stateid);
 	}
 	rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 }
@@ -496,6 +494,20 @@ pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo, const nfs4_stateid *new,
 	}
 }
 
+/* lget is set to 1 if called from inside send_layoutget call chain */
+static bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid,
+			int lget)
+{
+	assert_spin_locked(&lo->inode->i_lock);
+	if ((stateid) &&
+	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
+		return true;
+	return lo->plh_block_lgets ||
+		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
+		(list_empty(&lo->segs) && (lo->plh_outstanding > lget));
+}
+
 int
 pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *open_state)
@@ -504,8 +516,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&lo->inode->i_lock);
-	if (lo->plh_block_lgets ||
-	    test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+	if (pnfs_layoutgets_blocked(lo, NULL, 1)) {
 		/* We avoid -EAGAIN, as that has special meaning to
 		 * some callers.
 		 */
@@ -720,9 +731,6 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 	}
 	if (!found) {
 		list_add_tail(&lseg->fi_list, &lo->segs);
-		if (list_is_singular(&lo->segs) &&
-		    !pnfs_layoutgets_blocked(lo, NULL))
-			rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
 		dprintk("%s: inserted lseg %p "
 			"iomode %d offset %llu length %llu at tail\n",
 			__func__, lseg, lseg->range.iomode,
@@ -839,6 +847,13 @@ pnfs_update_layout(struct inode *ino,
 
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
+	spin_lock(&clp->cl_lock);
+	if (matches_outstanding_recall(ino, &arg)) {
+		dprintk("%s matches recall, use MDS\n", __func__);
+		spin_unlock(&clp->cl_lock);
+		return NULL;
+	}
+	spin_unlock(&clp->cl_lock);
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino);
 	if (lo == NULL) {
@@ -855,6 +870,10 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
+	if (pnfs_layoutgets_blocked(lo, NULL, 0))
+		goto out_unlock;
+	lo->plh_outstanding++;
+
 	get_layout_hdr(lo); /* Matched in pnfs_layoutget_release */
 	if (list_empty(&lo->segs)) {
 		/* The lo must be on the clp list if there is any
@@ -868,16 +887,17 @@ pnfs_update_layout(struct inode *ino,
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, &arg);
+	spin_lock(&ino->i_lock);
 	if (!lseg) {
-		spin_lock(&ino->i_lock);
 		if (list_empty(&lo->segs)) {
 			spin_lock(&clp->cl_lock);
 			list_del_init(&lo->layouts);
 			spin_unlock(&clp->cl_lock);
 			clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 		}
-		spin_unlock(&ino->i_lock);
 	}
+	lo->plh_outstanding--;
+	spin_unlock(&ino->i_lock);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
@@ -887,18 +907,6 @@ out_unlock:
 	goto out;
 }
 
-bool
-pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid)
-{
-	assert_spin_locked(&lo->inode->i_lock);
-	if ((stateid) &&
-	    (int)(lo->plh_barrier - be32_to_cpu(stateid->stateid.seqid)) >= 0)
-		return true;
-	return lo->plh_block_lgets ||
-		test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-		(list_empty(&lo->segs) && lo->plh_outstanding);
-}
-
 int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
@@ -929,13 +937,11 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 			status = PTR_ERR(lseg);
 		dprintk("%s: Could not allocate layout: error %d\n",
 		       __func__, status);
-		spin_lock(&ino->i_lock);
 		goto out;
 	}
 
 	spin_lock(&ino->i_lock);
 	/* decrement needs to be done before call to pnfs_layoutget_blocked */
-	lo->plh_outstanding--;
 	spin_lock(&clp->cl_lock);
 	if (matches_outstanding_recall(ino, &res->range)) {
 		spin_unlock(&clp->cl_lock);
@@ -944,7 +950,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	}
 	spin_unlock(&clp->cl_lock);
 
-	if (pnfs_layoutgets_blocked(lo, &res->stateid)) {
+	if (pnfs_layoutgets_blocked(lo, &res->stateid, 1)) {
 		dprintk("%s forget reply due to state\n", __func__);
 		goto out_forget_reply;
 	}
@@ -964,17 +970,14 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 
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
 	lseg->layout = lo;
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
-	spin_lock(&ino->i_lock);
 	goto out;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4b6065f..8d2ab18 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -214,7 +214,6 @@ enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
-bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo, nfs4_stateid *stateid);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index b4bb8d6..caed83e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,7 +191,6 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct rpc_wait_queue lo_rpcwaitq;
-	struct rpc_wait_queue	lo_rpcwaitq_stateid;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c3127cc..956a103 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -87,7 +87,6 @@ struct nfs_client {
 	unsigned long		cl_cb_lrecall_count;
 #define PNFS_MAX_CB_LRECALLS (64)
 	atomic_t		*cl_drain_notification[PNFS_MAX_CB_LRECALLS];
-	struct rpc_wait_queue	cl_rpcwaitq_recall;
 	struct pnfs_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.7.2.1

