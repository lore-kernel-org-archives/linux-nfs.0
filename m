Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35738 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193Ab1J0QFh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 12:05:37 -0400
Received: by mail-iy0-f174.google.com with SMTP id y12so3054806iab.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 09:05:37 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>,
        Jim Rees <rees@umich.edu>
Subject: [PATCH-v2] nfs4: serialize layoutcommit
Date: Sun, 23 Oct 2011 20:21:17 -0700
Message-Id: <1319426477-2111-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
And as Trond suggested , there is no need for client to optimize for
parallel layoutcommit. So add NFS_INO_LAYOUTCOMMITTING flag to
mark inflight layoutcommit and serialize lalyoutcommit with it.
Also mark_inode_dirty_sync if pnfs_layoutcommit_inode fails to issue
layoutcommit.

Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
change from v1:
remove else if after goto.

 fs/nfs/nfs4proc.c      |    6 ++++++
 fs/nfs/pnfs.c          |   25 ++++++++++++++++++++++---
 include/linux/nfs_fs.h |    1 +
 3 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2ae413..b60fddf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5950,6 +5950,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct pnfs_layout_segment *lseg, *tmp;
+	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
 
 	pnfs_cleanup_layoutcommit(data);
 	/* Matched by references in pnfs_set_layoutcommit */
@@ -5959,6 +5960,11 @@ static void nfs4_layoutcommit_release(void *calldata)
 				       &lseg->pls_flags))
 			put_lseg(lseg);
 	}
+
+	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
+	smp_mb__after_clear_bit();
+	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
+
 	put_rpccred(data->cred);
 	kfree(data);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ee73d9a..a2478bc 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1443,17 +1443,31 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (!data) {
-		mark_inode_dirty_sync(inode);
 		status = -ENOMEM;
 		goto out;
 	}
 
+	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
+		goto out_free;
+
+	if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {
+		if (!sync) {
+			status = -EAGAIN;
+			goto out_free;
+		}
+		status = wait_on_bit_lock(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING,
+					nfs_wait_bit_killable, TASK_KILLABLE);
+		if (status)
+			goto out_free;
+	}
+
 	INIT_LIST_HEAD(&data->lseg_list);
 	spin_lock(&inode->i_lock);
 	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
 		spin_unlock(&inode->i_lock);
-		kfree(data);
-		goto out;
+		wake_up_bit(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING);
+		goto out_free;
 	}
 
 	pnfs_list_write_lseg(inode, &data->lseg_list);
@@ -1475,6 +1489,11 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 
 	status = nfs4_proc_layoutcommit(data, sync);
 out:
+	if (status)
+		mark_inode_dirty_sync(inode);
 	dprintk("<-- %s status %d\n", __func__, status);
 	return status;
+out_free:
+	kfree(data);
+	goto out;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 60a137b..ab2c634 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -229,6 +229,7 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
+#define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
1.7.1.262.g5ef3d

