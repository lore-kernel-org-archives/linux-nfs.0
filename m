Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:56994 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbbAVXi1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:38:27 -0500
Received: by mail-pd0-f179.google.com with SMTP id v10so4589349pde.10
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:38:26 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 45/51] nfs/flexfiles: send layoutreturn before freeing lseg
Date: Thu, 22 Jan 2015 15:36:17 -0800
Message-Id: <1421969783-92997-46-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Otherwise we'll lose error tracking information when
encoding layoutreturn.

pnfs_put_lseg may be called from rpc callbacks. So we should not
call pnfs_send_layoutreturn directly because it can deadlock in
the rpc layer.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/pnfs.c | 81 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 56 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d3c2ca7..108a619 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -346,8 +346,7 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 /* Return true if layoutreturn is needed */
 static bool
 pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
-			struct pnfs_layout_segment *lseg,
-			nfs4_stateid *stateid, enum pnfs_iomode *iomode)
+			struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_segment *s;
 
@@ -355,17 +354,54 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 		return false;
 
 	list_for_each_entry(s, &lo->plh_segs, pls_list)
-		if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
 			return false;
 
-	*stateid = lo->plh_stateid;
-	*iomode = lo->plh_return_iomode;
-	/* decreased in pnfs_send_layoutreturn() */
-	lo->plh_block_lgets++;
-	lo->plh_return_iomode = 0;
 	return true;
 }
 
+static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
+{
+	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_hdr *lo;
+	struct inode *inode;
+
+	lseg = container_of(work, struct pnfs_layout_segment, pls_work);
+	WARN_ON(atomic_read(&lseg->pls_refcount));
+	lo = lseg->pls_layout;
+	inode = lo->plh_inode;
+
+	spin_lock(&inode->i_lock);
+	if (pnfs_layout_need_return(lo, lseg)) {
+		nfs4_stateid stateid;
+		enum pnfs_iomode iomode;
+
+		stateid = lo->plh_stateid;
+		iomode = lo->plh_return_iomode;
+		/* decreased in pnfs_send_layoutreturn() */
+		lo->plh_block_lgets++;
+		lo->plh_return_iomode = 0;
+		spin_unlock(&inode->i_lock);
+
+		pnfs_send_layoutreturn(lo, stateid, iomode, true);
+		spin_lock(&inode->i_lock);
+	} else
+		/* match pnfs_get_layout_hdr #2 in pnfs_put_lseg */
+		pnfs_put_layout_hdr(lo);
+	pnfs_layout_remove_lseg(lo, lseg);
+	spin_unlock(&inode->i_lock);
+	pnfs_free_lseg(lseg);
+	/* match pnfs_get_layout_hdr #1 in pnfs_put_lseg */
+	pnfs_put_layout_hdr(lo);
+}
+
+static void
+pnfs_layoutreturn_free_lseg_async(struct pnfs_layout_segment *lseg)
+{
+	INIT_WORK(&lseg->pls_work, pnfs_layoutreturn_free_lseg);
+	queue_work(nfsiod_workqueue, &lseg->pls_work);
+}
+
 void
 pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -381,21 +417,18 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
-		bool need_return;
-		nfs4_stateid stateid;
-		enum pnfs_iomode iomode;
-
 		pnfs_get_layout_hdr(lo);
-		pnfs_layout_remove_lseg(lo, lseg);
-		need_return = pnfs_layout_need_return(lo, lseg,
-						      &stateid, &iomode);
-		spin_unlock(&inode->i_lock);
-		pnfs_free_lseg(lseg);
-		if (need_return)
-			pnfs_send_layoutreturn(lo, stateid, iomode,
-					       true);
-		else
+		if (pnfs_layout_need_return(lo, lseg)) {
+			spin_unlock(&inode->i_lock);
+			/* hdr reference dropped in nfs4_layoutreturn_release */
+			pnfs_get_layout_hdr(lo);
+			pnfs_layoutreturn_free_lseg_async(lseg);
+		} else {
+			pnfs_layout_remove_lseg(lo, lseg);
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg(lseg);
 			pnfs_put_layout_hdr(lo);
+		}
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
@@ -1059,8 +1092,7 @@ out_nolayout:
 	}
 	spin_unlock(&ino->i_lock);
 	if (layoutreturn)
-		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
-				       NFS4_MAX_UINT64, true);
+		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, true);
 	return false;
 }
 
@@ -1127,8 +1159,7 @@ out:
 	spin_unlock(&ino->i_lock);
 	if (layoutreturn) {
 		rpc_sleep_on(&NFS_SERVER(ino)->roc_rpcwaitq, task, NULL);
-		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, 0,
-				       NFS4_MAX_UINT64, false);
+		pnfs_send_layoutreturn(lo, stateid, IOMODE_ANY, false);
 	}
 	return found;
 }
-- 
1.9.3

