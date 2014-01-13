Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:65319 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbaAMSp5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 13:45:57 -0500
Received: by mail-ie0-f181.google.com with SMTP id at1so807591iec.12
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jan 2014 10:45:56 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Fix a race in nfs4_write_inode
Date: Mon, 13 Jan 2014 13:45:51 -0500
Message-Id: <1389638751-16173-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1389638751-16173-1-git-send-email-trond.myklebust@primarydata.com>
References: <1389638751-16173-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
References: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_write_inode() must not be allowed to exit until the layoutcommit
is done. That means that both NFS_INO_LAYOUTCOMMIT and
NFS_INO_LAYOUTCOMMITTING have to be cleared.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4super.c | 14 +++---------
 fs/nfs/pnfs.c      | 67 ++++++++++++++++++++++++++++--------------------------
 2 files changed, 38 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 65ab0a0ca1c4..808f29574412 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -77,17 +77,9 @@ static int nfs4_write_inode(struct inode *inode, struct writeback_control *wbc)
 {
 	int ret = nfs_write_inode(inode, wbc);
 
-	if (ret >= 0 && test_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(inode)->flags)) {
-		int status;
-		bool sync = true;
-
-		if (wbc->sync_mode == WB_SYNC_NONE)
-			sync = false;
-
-		status = pnfs_layoutcommit_inode(inode, sync);
-		if (status < 0)
-			return status;
-	}
+	if (ret == 0)
+		ret = pnfs_layoutcommit_inode(inode,
+				wbc->sync_mode == WB_SYNC_ALL);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d75d938d36cb..4755858e37a0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1790,6 +1790,15 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
 
+static void pnfs_clear_layoutcommitting(struct inode *inode)
+{
+	unsigned long *bitlock = &NFS_I(inode)->flags;
+
+	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
+	smp_mb__after_clear_bit();
+	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
+}
+
 /*
  * There can be multiple RW segments.
  */
@@ -1807,7 +1816,6 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *listp)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
-	unsigned long *bitlock = &NFS_I(inode)->flags;
 
 	/* Matched by references in pnfs_set_layoutcommit */
 	list_for_each_entry_safe(lseg, tmp, listp, pls_lc_list) {
@@ -1815,9 +1823,7 @@ static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *lis
 		pnfs_put_lseg(lseg);
 	}
 
-	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
-	smp_mb__after_clear_bit();
-	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
+	pnfs_clear_layoutcommitting(inode);
 }
 
 void pnfs_set_lo_fail(struct pnfs_layout_segment *lseg)
@@ -1881,43 +1887,37 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	loff_t end_pos;
-	int status = 0;
+	int status;
 
-	dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
-
-	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
+	if (!pnfs_layoutcommit_outstanding(inode))
 		return 0;
 
-	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
-	data = kzalloc(sizeof(*data), GFP_NOFS);
-	if (!data) {
-		status = -ENOMEM;
-		goto out;
-	}
-
-	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
-		goto out_free;
+	dprintk("--> %s inode %lu\n", __func__, inode->i_ino);
 
+	status = -EAGAIN;
 	if (test_and_set_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) {
-		if (!sync) {
-			status = -EAGAIN;
-			goto out_free;
-		}
-		status = wait_on_bit_lock(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING,
-					nfs_wait_bit_killable, TASK_KILLABLE);
+		if (!sync)
+			goto out;
+		status = wait_on_bit_lock(&nfsi->flags,
+				NFS_INO_LAYOUTCOMMITTING,
+				nfs_wait_bit_killable,
+				TASK_KILLABLE);
 		if (status)
-			goto out_free;
+			goto out;
 	}
 
-	INIT_LIST_HEAD(&data->lseg_list);
+	status = -ENOMEM;
+	/* Note kzalloc ensures data->res.seq_res.sr_slot == NULL */
+	data = kzalloc(sizeof(*data), GFP_NOFS);
+	if (!data)
+		goto clear_layoutcommitting;
+
+	status = 0;
 	spin_lock(&inode->i_lock);
-	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		clear_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags);
-		spin_unlock(&inode->i_lock);
-		wake_up_bit(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING);
-		goto out_free;
-	}
+	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags))
+		goto out_unlock;
 
+	INIT_LIST_HEAD(&data->lseg_list);
 	pnfs_list_write_lseg(inode, &data->lseg_list);
 
 	end_pos = nfsi->layout->plh_lwb;
@@ -1940,8 +1940,11 @@ out:
 		mark_inode_dirty_sync(inode);
 	dprintk("<-- %s status %d\n", __func__, status);
 	return status;
-out_free:
+out_unlock:
+	spin_unlock(&inode->i_lock);
 	kfree(data);
+clear_layoutcommitting:
+	pnfs_clear_layoutcommitting(inode);
 	goto out;
 }
 
-- 
1.8.4.2

