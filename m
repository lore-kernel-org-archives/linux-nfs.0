From: andros@netapp.com
Subject: [PATCH 3/5] SQUASHME: pnfs-submit: move pnfs_layout_suspend back to nfs_inode
Date: Tue, 29 Jun 2010 12:42:15 -0400
Message-ID: <1277829737-5465-4-git-send-email-andros@netapp.com>
References: <1277829737-5465-1-git-send-email-andros@netapp.com>
 <1277829737-5465-2-git-send-email-andros@netapp.com>
 <1277829737-5465-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
To: benny@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23289 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140Ab0F2Ql4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jun 2010 12:41:56 -0400
In-Reply-To: <1277829737-5465-3-git-send-email-andros@netapp.com>
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
index 66d7be2..cb12d33 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1420,6 +1420,7 @@ static void pnfs_init_once(struct nfs_inode *nfsi)
 #ifdef CONFIG_NFS_V4_1
 	init_waitqueue_head(&nfsi->lo_waitq);
 	nfsi->pnfs_layout_state = 0;
+	nfsi->pnfs_layout_suspend = 0;
 	seqlock_init(&nfsi->layout.seqlock);
 	INIT_LIST_HEAD(&nfsi->layout.lo_layouts);
 	INIT_LIST_HEAD(&nfsi->layout.segs);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d05cb03..7f6ace2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1105,12 +1105,12 @@ _pnfs_update_layout(struct inode *ino,
 
 	/* if get layout already failed once goto out */
 	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
-		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
-		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
+		if (unlikely(nfsi->pnfs_layout_suspend &&
+		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
 				  &nfsi->pnfs_layout_state);
-			nfsi->layout.pnfs_layout_suspend = 0;
+			nfsi->pnfs_layout_suspend = 0;
 		} else
 			goto out_put;
 	}
@@ -1224,7 +1224,7 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 	}
 
 	/* remember that get layout failed and suspend trying */
-	nfsi->layout.pnfs_layout_suspend = suspend;
+	nfsi->pnfs_layout_suspend = suspend;
 	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
 		&nfsi->pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e216e24..cebc958 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -105,7 +105,6 @@ struct pnfs_layout_type {
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
 	void *ld_data;			/* layout driver private data */
-	time_t pnfs_layout_suspend;
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
@@ -208,6 +207,7 @@ struct nfs_inode {
 	#define NFS_INO_RW_LAYOUT_FAILED 1 /* rw LAYOUTGET failed stop trying */
 	#define NFS_INO_LAYOUT_ALLOC     2 /* bit lock for layout allocation */
 	#define NFS_INO_LAYOUTCOMMIT     3 /* LAYOUTCOMMIT needed */
+	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.6

