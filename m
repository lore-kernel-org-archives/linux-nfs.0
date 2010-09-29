Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7695 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752122Ab0I2LKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:10:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] pnfs: allow nfs4_proc_layoutget to sleep on invalid lsegs
Date: Wed, 29 Sep 2010 13:10:38 +0200
Message-Id: <1285758638-26971-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Introduce lo_rpcwaitq and sleep on it while there's an lseg marked invalid,
i.e. it is being returned (in the future, it could also be layoutget in progress).

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c         |    1 +
 fs/nfs/nfs4proc.c      |   25 ++++++++++++++++++++++---
 fs/nfs/pnfs.c          |   26 ++++++++++++++++----------
 include/linux/nfs_fs.h |    1 +
 4 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8cdea1a..e3d44a9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1459,6 +1459,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 	init_waitqueue_head(&nfsi->lo_waitq);
+	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layout");
 	nfsi->layout = NULL;
 #endif
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd87704..ebf5127 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5426,13 +5426,32 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_layoutget *lgp = calldata;
 	struct inode *ino = lgp->args.inode;
+	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_server *server = NFS_SERVER(ino);
+	struct pnfs_layout_segment *lseg;
 
 	dprintk("--> %s\n", __func__);
-	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task))
+	spin_lock(&ino->i_lock);
+	lseg = pnfs_has_layout(nfsi->layout, &lgp->args.range);
+	if (likely(!lseg)) {
+		spin_unlock(&ino->i_lock);
+		dprintk("%s: no lseg found, proceeding\n", __func__);
+		if (!nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
+					 &lgp->res.seq_res, 0, task))
+			rpc_call_start(task);
 		return;
-	rpc_call_start(task);
+	}
+	if (!lseg->valid) {
+		put_lseg_locked(lseg);
+		spin_unlock(&ino->i_lock);
+		dprintk("%s: invalid lseg found, waiting\n", __func__);
+		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
+		return;
+	}
+	*lgp->lsegpp = lseg;
+	spin_unlock(&ino->i_lock);
+	dprintk("%s: valid lseg found, no rpc required\n", __func__);
+	rpc_exit(task, NFS4_OK);
 }
 
 static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8339444..31a703d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -315,8 +315,10 @@ put_lseg_locked(struct pnfs_layout_segment *lseg)
 	do_wake_up = !lseg->valid;
 	nfsi = NFS_I(lseg->layout->inode);
 	kref_put(&lseg->kref, destroy_lseg);
-	if (do_wake_up)
+	if (do_wake_up) {
 		wake_up(&nfsi->lo_waitq);
+		rpc_wake_up(&nfsi->lo_rpcwaitq);
+	}
 }
 EXPORT_SYMBOL_GPL(put_lseg_locked);
 
@@ -975,17 +977,21 @@ pnfs_update_layout(struct inode *ino,
 
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_has_layout(lo, &arg);
-	if (lseg && !lseg->valid) {
-		put_lseg_locked(lseg);
+	if (lseg) {
+		if (lseg->valid) {
+			dprintk("%s: Using cached lseg %p for %llu@%llu "
+				"iomode %d)\n",
+				__func__,
+				lseg,
+				arg.length,
+				arg.offset,
+				arg.iomode);
+
+			goto out_unlock;
+		}
 		/* someone is cleaning the layout */
+		put_lseg_locked(lseg);
 		lseg = NULL;
-		goto out_unlock;
-	}
-
-	if (lseg) {
-		dprintk("%s: Using cached lseg %p for iomode %d)\n",
-			__func__, lseg, iomode);
-		goto out_unlock;
 	}
 
 	/* if LAYOUTGET already failed once we don't try again */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3184e63..1af18fd 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,6 +191,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 	wait_queue_head_t lo_waitq;
+	struct rpc_wait_queue lo_rpcwaitq;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.2.3

