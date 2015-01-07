Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:48142 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbbAGA37 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 19:29:59 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so1068782pde.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 16:29:58 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 45/49] nfs/flexfiles: send layoutreturn before freeing lseg
Date: Tue,  6 Jan 2015 16:28:50 -0800
Message-Id: <1420590534-84063-46-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com>
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
 fs/nfs/pnfs.c | 76 ++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 55 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e80014a..9e7092f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -347,8 +347,7 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 /* Return true if layoutreturn is needed */
 static bool
 pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
-			struct pnfs_layout_segment *lseg,
-			nfs4_stateid *stateid, enum pnfs_iomode *iomode)
+			struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_segment *s;
 
@@ -356,17 +355,55 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
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
+		pnfs_send_layoutreturn(lo, stateid, iomode, 0,
+				       NFS4_MAX_UINT64, true);
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
@@ -382,21 +419,18 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
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
-			pnfs_send_layoutreturn(lo, stateid, iomode, 0,
-					       NFS4_MAX_UINT64, true);
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
-- 
1.9.3

