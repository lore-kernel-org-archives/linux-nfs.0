Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab0KLItZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:25 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fK025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:13 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/22] pnfs-submit: Have LAYOUTGETS wait when lo->plh_block_lgets is set
Date: Fri, 12 Nov 2010 03:48:32 -0500
Message-Id: <1289551724-18575-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Preparing for changes to come, change blocking mechanism of LAYOUTGET.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c         |    3 ++-
 fs/nfs/nfs4proc.c      |   23 ++++++-----------------
 fs/nfs/pnfs.c          |   11 +++++++++++
 fs/nfs/pnfs.h          |    2 ++
 include/linux/nfs_fs.h |    1 +
 5 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 72f27cc..8727ade 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1459,7 +1459,8 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
-	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layout");
+	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layoutreturn");
+	rpc_init_wait_queue(&nfsi->lo_rpcwaitq_stateid, "pNFS Layoutstateid");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8dbd711..5ccde2a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5346,30 +5346,19 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	struct inode *ino = lgp->args.inode;
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *server = NFS_SERVER(ino);
-	struct pnfs_layout_segment *lseg;
 
 	dprintk("--> %s\n", __func__);
 	spin_lock(&ino->i_lock);
-	lseg = pnfs_has_layout(nfsi->layout, &lgp->args.range);
-	if (likely(!lseg)) {
+	if (pnfs_layoutgets_blocked(nfsi->layout)) {
+		rpc_sleep_on(&nfsi->lo_rpcwaitq_stateid, task, NULL);
 		spin_unlock(&ino->i_lock);
-		dprintk("%s: no lseg found, proceeding\n", __func__);
-		if (!nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-					 &lgp->res.seq_res, 0, task))
-			rpc_call_start(task);
 		return;
 	}
-	if (!lseg->valid) {
-		spin_unlock(&ino->i_lock);
-		dprintk("%s: invalid lseg found, waiting\n", __func__);
-		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
-		return;
-	}
-	get_lseg(lseg);
-	*lgp->lsegpp = lseg;
 	spin_unlock(&ino->i_lock);
-	dprintk("%s: valid lseg found, no rpc required\n", __func__);
-	rpc_exit(task, NFS4_OK);
+	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
+				&lgp->res.seq_res, 0, task))
+		return;
+	rpc_call_start(task);
 }
 
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8e699fd..120590b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -565,6 +565,9 @@ pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
 	lo = NFS_I(lrp->args.inode)->layout;
 	spin_lock(&lrp->args.inode->i_lock);
 	pnfs_clear_lseg_list(lo, &tmp_list, &lrp->args.range);
+	lo->plh_block_lgets--;
+	if (!pnfs_layoutgets_blocked(lo))
+		rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
 	if (!lrp->res.valid)
 		;	/* forgetful model internal release */
 	else if (!lrp->res.lrs_present)
@@ -638,6 +641,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 			goto out;
 		}
 
+		lo->plh_block_lgets++;
 		/* Reference matched in pnfs_layoutreturn_release */
 		get_layout_hdr_locked(lo);
 
@@ -870,6 +874,13 @@ out_unlock:
 	goto out;
 }
 
+bool
+pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo)
+{
+	assert_spin_locked(&lo->inode->i_lock);
+	return lo->plh_block_lgets;
+}
+
 int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ee5a752..a9a3bea 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -97,6 +97,7 @@ struct pnfs_layout_hdr {
 	struct list_head	segs;      /* layout segments list */
 	int			roc_iomode;/* return on close iomode, 0=none */
 	nfs4_stateid		stateid;
+	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	unsigned long		state;
 	struct rpc_cred		*cred;     /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
@@ -200,6 +201,7 @@ enum pnfs_try_status pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
+bool pnfs_layoutgets_blocked(struct pnfs_layout_hdr *lo);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_layoutreturn_release(struct nfs4_layoutreturn *lpr);
 void pnfs_destroy_layout(struct nfs_inode *);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index d8bfa42..061d81a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,6 +191,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	struct rpc_wait_queue lo_rpcwaitq;
+	struct rpc_wait_queue	lo_rpcwaitq_stateid;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.2.1

