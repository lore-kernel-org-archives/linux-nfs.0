From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-submit: clean up nfs_lock_alloc_layout
Date: Mon, 12 Jul 2010 21:40:15 +0300
Message-ID: <1278960015-32215-1-git-send-email-bhalevy@panasas.com>
References: <4C3B611C.1000208@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:33102 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751597Ab0GLSkY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 14:40:24 -0400
In-Reply-To: <4C3B611C.1000208@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a bug where the function returned without taking the i_lock
if the layout hdr was already allocated.
Simplify by moving inode locking to caller.

Rename function as it no longer grabs the lock.
Clean up the implementation so it's clearer what's going on
and what are the likely cases vs. the unlikely ones.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   42 ++++++++++++++++++++++--------------------
 1 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4ba7595..053a5c1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -938,36 +938,37 @@ alloc_init_layout(struct inode *ino)
 }
 
 /*
- * Lock and possibly allocate the inode layout
+ * Retrieve and possibly allocate the inode layout
  *
- * If successful, ino->i_lock is taken, and the caller must unlock.
+ * ino->i_lock must be taken by the caller.
  */
 static struct pnfs_layout_type *
-nfs_lock_alloc_layout(struct inode *ino)
+pnfs_alloc_layout(struct inode *ino)
 {
+	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_type *new = NULL;
 
-	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, NFS_I(ino)->layout);
+	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
-	if (NFS_I(ino)->layout == NULL) {
-		new = alloc_init_layout(ino);
-		if (new == NULL)
-			return NULL;
-		spin_lock(&ino->i_lock);
-		if (NFS_I(ino)->layout == NULL) {
-			NFS_I(ino)->layout = new;
-			new = NULL;
-		}
-	}
-	if (new) {
+	BUG_ON(!spin_is_locked(&ino->i_lock));
+	if (likely(nfsi->layout))
+		return nfsi->layout;
+
+	spin_unlock(&ino->i_lock);
+	new = alloc_init_layout(ino);
+	spin_lock(&ino->i_lock);
+
+	if (likely(nfsi->layout == NULL)) {	/* Won the race? */
+		nfsi->layout = new;
+	} else if (new) {
 		/* Reference the layout accross i_lock release and grab */
-		get_layout(NFS_I(ino)->layout);
+		get_layout(nfsi->layout);
 		spin_unlock(&ino->i_lock);
 		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
 		spin_lock(&ino->i_lock);
-		put_layout_locked(NFS_I(ino)->layout);
+		put_layout_locked(nfsi->layout);
 	}
-	return NFS_I(ino)->layout;
+	return nfsi->layout;
 }
 
 /*
@@ -1055,10 +1056,11 @@ _pnfs_update_layout(struct inode *ino,
 
 	if (take_ref)
 		*lsegpp = NULL;
-	lo = nfs_lock_alloc_layout(ino);
+	spin_lock(&ino->i_lock);
+	lo = pnfs_alloc_layout(ino);
 	if (lo == NULL) {
 		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
-		goto out;
+		goto out_unlock;
 	}
 
 	/* Check to see if the layout for the given range already exists */
-- 
1.7.1.1

