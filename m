From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 05/10] pnfs-submit: Move pnfs_layout_state and pnfs_layout_suspend back to nfs_inode
Date: Mon, 14 Jun 2010 21:46:10 -0400
Message-ID: <1276566375-24566-6-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52267 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932186Ab0FOO3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:04 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 4D46F18166
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparing to make layout a pointer, need state flags accessible
before allocation.  pnfs_layout_suspend needs to be pulled out too,
since a temp error on first LAYOUTGET erases the layout.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c         |    2 +-
 fs/nfs/pnfs.c          |   24 ++++++++++++------------
 include/linux/nfs_fs.h |   10 +++++-----
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index be25ffc..1a03f9a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1364,7 +1364,7 @@ void nfs4_clear_inode(struct inode *inode)
 static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	nfsi->layout.pnfs_layout_state = 0;
+	nfsi->pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
 	nfsi->layout.lo_cred = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 21192b6..e667208 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -959,7 +959,7 @@ get_lock_alloc_layout(struct inode *ino)
 		 * wait until bit is cleared if we lost this race.
 		 */
 		res = wait_on_bit_lock(
-			&nfsi->layout.pnfs_layout_state,
+			&nfsi->pnfs_layout_state,
 			NFS_INO_LAYOUT_ALLOC,
 			pnfs_wait_schedule, TASK_KILLABLE);
 		if (res) {
@@ -993,8 +993,8 @@ get_lock_alloc_layout(struct inode *ino)
 
 		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
 		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
-				 &nfsi->layout.pnfs_layout_state);
-		wake_up_bit(&nfsi->layout.pnfs_layout_state,
+				 &nfsi->pnfs_layout_state);
+		wake_up_bit(&nfsi->pnfs_layout_state,
 			    NFS_INO_LAYOUT_ALLOC);
 		break;
 	}
@@ -1122,13 +1122,13 @@ _pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if get layout already failed once goto out */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layout_state)) {
-		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
-		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
+	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
+		if (unlikely(nfsi->pnfs_layout_suspend &&
+		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
-				  &nfsi->layout.pnfs_layout_state);
-			nfsi->layout.pnfs_layout_suspend = 0;
+				  &nfsi->pnfs_layout_state);
+			nfsi->pnfs_layout_suspend = 0;
 		} else
 			goto out_put;
 	}
@@ -1139,7 +1139,7 @@ _pnfs_update_layout(struct inode *ino,
 	send_layoutget(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout.pnfs_layout_state, lseg);
+		nfsi->pnfs_layout_state, lseg);
 	return;
 out_put:
 	if (lsegpp)
@@ -1242,14 +1242,14 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 	}
 
 	/* remember that get layout failed and suspend trying */
-	nfsi->layout.pnfs_layout_suspend = suspend;
+	nfsi->pnfs_layout_suspend = suspend;
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
index 95d8d53..0b3419d 100644
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
-	time_t pnfs_layout_suspend;
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
@@ -209,6 +204,11 @@ struct nfs_inode {
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
 	struct pnfs_layout_type layout;
+	unsigned long pnfs_layout_state;
+	#define NFS_INO_RO_LAYOUT_FAILED 0	/* get ro layout failed stop trying */
+	#define NFS_INO_RW_LAYOUT_FAILED 1	/* get rw layout failed stop trying */
+	#define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
+	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6.1

