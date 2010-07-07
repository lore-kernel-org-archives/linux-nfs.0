From: andros@netapp.com
Subject: [PATCH 02/16] SQUASHME: pnfs-submit: move pnfs_layout_suspend back to nfs_inode
Date: Wed,  7 Jul 2010 18:34:09 -0400
Message-ID: <1278542063-4009-3-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820Ab0GGWeX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:23 -0400
In-Reply-To: <1278542063-4009-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@netapp.com>

Prepare to embed struct pnfs_layout_tupe into layout driver private structs
and to make layout a pointer. Since a temp error on first LAYOUTGET
erases the layout, the suspend timer needs to be moved.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c         |    1 +
 fs/nfs/pnfs.c          |    8 ++++----
 include/linux/nfs_fs.h |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 229cdab..3d51602 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1396,6 +1396,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	init_rwsem(&nfsi->rwsem);
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
+	nfsi->pnfs_layout_suspend = 0;
 	seqlock_init(&nfsi->layout.seqlock);
 	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
 	INIT_LIST_HEAD(&nfsi->layout.segs);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5d472c6..53c15b1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1114,12 +1114,12 @@ _pnfs_update_layout(struct inode *ino,
 
 	/* if get layout already failed once goto out */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layout_state)) {
-		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
-		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
+		if (unlikely(nfsi->pnfs_layout_suspend &&
+		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
 				  &nfsi->layout.pnfs_layout_state);
-			nfsi->layout.pnfs_layout_suspend = 0;
+			nfsi->pnfs_layout_suspend = 0;
 		} else
 			goto out_put;
 	}
@@ -1233,7 +1233,7 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 	}
 
 	/* remember that get layout failed and suspend trying */
-	nfsi->layout.pnfs_layout_suspend = suspend;
+	nfsi->pnfs_layout_suspend = suspend;
 	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
 		&nfsi->layout.pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3394d1e..b612746 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -110,7 +110,6 @@ struct pnfs_layout_type {
 	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
 	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
 	#define NFS_INO_LAYOUTCOMMIT     3      /* LAYOUTCOMMIT needed */
-	time_t pnfs_layout_suspend;
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
@@ -208,6 +207,7 @@ struct nfs_inode {
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
 	struct pnfs_layout_type layout;
+	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6

