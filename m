From: andros@netapp.com
Subject: [PATCH 2/5] SQUASHME: pnfs_submit: move pnfs_layout_state back to nfs_inode
Date: Tue, 29 Jun 2010 12:42:14 -0400
Message-ID: <1277829737-5465-3-git-send-email-andros@netapp.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com>
 <1277829737-5465-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: benny@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15343 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932137Ab0F2Qlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jun 2010 12:41:55 -0400
In-Reply-To: <1277829737-5465-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Prepare to embed struct pnfs_layout_tupe into layout driver private structs
and to make layout a pointer: state flags need to be accessible before
allocation.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c         |    2 +-
 fs/nfs/pnfs.c          |   16 ++++++++--------
 include/linux/nfs_fs.h |   10 +++++-----
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7989dea..66d7be2 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1364,7 +1364,6 @@ void nfs4_clear_inode(struct inode *inode)
 static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	nfsi->layout.pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
 	nfsi->layout.lo_cred = NULL;
@@ -1420,6 +1419,7 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
+	nfsi->pnfs_layout_state = 0;
 	seqlock_init(&nfsi->layout.seqlock);
 	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
 	INIT_LIST_HEAD(&nfsi->layout.segs);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf15b5c..d05cb03 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -951,7 +951,7 @@ get_lock_alloc_layout(struct inode *ino)
 		 * wait until bit is cleared if we lost this race.
 		 */
 		res = wait_on_bit_lock(
-			&nfsi->layout.pnfs_layout_state,
+			&nfsi->pnfs_layout_state,
 			NFS_INO_LAYOUT_ALLOC,
 			pnfs_wait_schedule, TASK_KILLABLE);
 		if (res) {
@@ -975,8 +975,8 @@ get_lock_alloc_layout(struct inode *ino)
 
 		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
 		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
-				 &nfsi->layout.pnfs_layout_state);
-		wake_up_bit(&nfsi->layout.pnfs_layout_state,
+				 &nfsi->pnfs_layout_state);
+		wake_up_bit(&nfsi->pnfs_layout_state,
 			    NFS_INO_LAYOUT_ALLOC);
 		break;
 	}
@@ -1104,12 +1104,12 @@ _pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if get layout already failed once goto out */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layout_state)) {
+	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
 		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
 		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
-				  &nfsi->layout.pnfs_layout_state);
+				  &nfsi->pnfs_layout_state);
 			nfsi->layout.pnfs_layout_suspend = 0;
 		} else
 			goto out_put;
@@ -1121,7 +1121,7 @@ _pnfs_update_layout(struct inode *ino,
 	send_layoutget(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout.pnfs_layout_state, lseg);
+		nfsi->pnfs_layout_state, lseg);
 	return;
 out_put:
 	if (lsegpp)
@@ -1226,12 +1226,12 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 	/* remember that get layout failed and suspend trying */
 	nfsi->layout.pnfs_layout_suspend = suspend;
 	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
-		&nfsi->layout.pnfs_layout_state);
+		&nfsi->pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
 		__func__, suspend);
 out:
 	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-		__func__, lgp->status, nfsi->layout.pnfs_layout_state, lseg);
+		__func__, lgp->status, nfsi->pnfs_layout_state, lseg);
 	return;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a33e86e..e216e24 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -105,11 +105,6 @@ struct pnfs_layout_type {
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
 	void *ld_data;			/* layout driver private data */
-	unsigned long pnfs_layout_state;
-	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
-	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
-	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
-	#define NFS_INO_LAYOUTCOMMIT     3	/* LAYOUTCOMMIT needed */
 	time_t pnfs_layout_suspend;
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
@@ -208,6 +203,11 @@ struct nfs_inode {
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
 	struct pnfs_layout_type layout;
+	unsigned long pnfs_layout_state;
+	#define NFS_INO_RO_LAYOUT_FAILED 0 /* ro LAYOUTGET failed stop trying */
+	#define NFS_INO_RW_LAYOUT_FAILED 1 /* rw LAYOUTGET failed stop trying */
+	#define NFS_INO_LAYOUT_ALLOC     2 /* bit lock for layout allocation */
+	#define NFS_INO_LAYOUTCOMMIT     3 /* LAYOUTCOMMIT needed */
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6

