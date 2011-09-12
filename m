Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56476 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934211Ab1IORiD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2011 13:38:03 -0400
Received: by gyg10 with SMTP id 10so2338625gyg.19
        for <linux-nfs@vger.kernel.org>; Thu, 15 Sep 2011 10:38:03 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: bhalevy@tonian.com
Cc: Vitaliy Gusev <gusev.vitaliy@nexenta.com>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com, Peng Tao <peng_tao@emc.com>
Subject: [PATCH] nfs4: serialize layoutcommit
Date: Sun, 11 Sep 2011 21:48:20 -0700
Message-Id: <1315802900-1548-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
As Trond suggested, there is no need for client to optimize for
parallel layoutcommit. The patch add NFS_INO_LAYOUTCOMMITTING flag to
mark inflight layoutcommit and serialize lalyoutcommit with it.
It also fixes the pls_lc_list corruption that Vitaliy found.

Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4proc.c      |    6 ++++++
 fs/nfs/pnfs.c          |    9 +++++++++
 include/linux/nfs_fs.h |    1 +
 3 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..a7ce210 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5970,6 +5970,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct pnfs_layout_segment *lseg, *tmp;
+	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
 
 	pnfs_cleanup_layoutcommit(data);
 	/* Matched by references in pnfs_set_layoutcommit */
@@ -5979,6 +5980,11 @@ static void nfs4_layoutcommit_release(void *calldata)
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
index b483bbc..fb71def 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1451,10 +1451,19 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		goto out;
 	}
 
+	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags) ||
+	    (status = wait_on_bit_lock(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING,
+				nfs_wait_bit_killable, TASK_KILLABLE))) {
+		kfree(data);
+		goto out;
+	}
+
 	INIT_LIST_HEAD(&data->lseg_list);
 	spin_lock(&inode->i_lock);
 	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
+		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
 		spin_unlock(&inode->i_lock);
+		wake_up_bit(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING);
 		kfree(data);
 		goto out;
 	}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index eaac770..c5b2b30 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -230,6 +230,7 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_PNFS_COMMIT	(8)		/* use pnfs code for commit */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
+#define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {
-- 
1.7.1.262.g5ef3d

