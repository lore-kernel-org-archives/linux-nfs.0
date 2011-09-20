Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:34800 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1ITDXz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 23:23:55 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/3] nfs4: serialize layoutcommit
Date: Mon, 19 Sep 2011 23:23:45 -0400
Message-Id: <1316489025-24991-4-git-send-email-rees@umich.edu>
In-Reply-To: <1316489025-24991-1-git-send-email-rees@umich.edu>
References: <1316489025-24991-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
And as Trond suggested , there is no need for client to optimize for
parallel layoutcommit. So add NFS_INO_LAYOUTCOMMITTING flag to mark
inflight layoutcommit and serialize lalyoutcommit with it. Also call
mark_inode_dirty_sync if pnfs_layoutcommit_inode fails to issue
layoutcommit, so that layoutcommit can be retried later.
It also fixes the pls_lc_list corruption that Vitaliy found.

Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/nfs4proc.c      |    6 ++++++
 fs/nfs/pnfs.c          |   24 +++++++++++++++++++++---
 include/linux/nfs_fs.h |    1 +
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8c77039..d9ffe58 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5962,6 +5962,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
 	struct pnfs_layout_segment *lseg, *tmp;
+	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
 
 	pnfs_cleanup_layoutcommit(data);
 	/* Matched by references in pnfs_set_layoutcommit */
@@ -5971,6 +5972,11 @@ static void nfs4_layoutcommit_release(void *calldata)
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
index e5e11b4..fc15aa6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1446,17 +1446,30 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (!data) {
-		mark_inode_dirty_sync(inode);
 		status = -ENOMEM;
 		goto out;
 	}
 
+	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
+		goto out_free;
+	else if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {
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
@@ -1478,8 +1491,13 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 
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
 
 /*
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
1.7.4.1

