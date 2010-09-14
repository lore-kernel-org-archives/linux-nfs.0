Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10214 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753652Ab0INKxu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 06:53:50 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] SQUASHME: pnfs: get rid of lo_waitq
Date: Tue, 14 Sep 2010 12:53:51 +0200
Message-Id: <1284461631-4662-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C8F53FA.5060308@panasas.com>
References: <4C8F53FA.5060308@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

it has no more users at this point.

SPLITME: refactor put_lseg{,_locked}

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c         |    1 -
 fs/nfs/pnfs.c          |   32 ++++++++++++++------------------
 include/linux/nfs_fs.h |    1 -
 3 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 059bdf7..8e5fbb5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1461,7 +1461,6 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 #ifdef CONFIG_NFS_V4_1
-	init_waitqueue_head(&nfsi->lo_waitq);
 	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layout");
 	nfsi->pnfs_layout_suspend = 0;
 	nfsi->layout = NULL;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0e8bb6f..e6261a3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -360,7 +360,6 @@ pnfs_layout_release(struct pnfs_layout_hdr *lo,
 	 */
 	put_layout_locked(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	wake_up_all(&nfsi->lo_waitq);
 }
 
 void
@@ -430,44 +429,41 @@ destroy_lseg(struct kref *kref)
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
-void
-put_lseg_locked(struct pnfs_layout_segment *lseg)
+static void
+put_lseg_common(struct nfs_inode *nfsi, struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
-	struct nfs_inode *nfsi;
-
-	if (!lseg)
-		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->kref.refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
-	nfsi = PNFS_NFS_INODE(lseg->layout);
 	kref_put(&lseg->kref, destroy_lseg);
-	if (do_wake_up) {
-		wake_up(&nfsi->lo_waitq);
+	if (do_wake_up)
 		rpc_wake_up(&nfsi->lo_rpcwaitq);
-	}
+}
+
+void
+put_lseg_locked(struct pnfs_layout_segment *lseg)
+{
+	if (!lseg)
+		return;
+
+	BUG_ON_UNLOCKED_LO(lseg->layout);
+	put_lseg_common(PNFS_NFS_INODE(lseg->layout), lseg);
 }
 
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
-	bool do_wake_up;
 	struct nfs_inode *nfsi;
 
 	if (!lseg)
 		return;
 
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
 	nfsi = PNFS_NFS_INODE(lseg->layout);
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	kref_put(&lseg->kref, destroy_lseg);
+	put_lseg_common(nfsi, lseg);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	if (do_wake_up)
-		wake_up(&nfsi->lo_waitq);
 }
 EXPORT_SYMBOL(put_lseg);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 196c0c6..745d14e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -212,7 +212,6 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 #if defined(CONFIG_NFS_V4_1)
-	wait_queue_head_t lo_waitq;
 	struct rpc_wait_queue lo_rpcwaitq;
 	struct pnfs_layout_hdr *layout;
 	time_t pnfs_layout_suspend;
-- 
1.7.2.2

