Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56719 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaLPTDi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:03:38 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so13943682pab.5
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:03:37 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 46/50] nfs/flexfiles: defer sending layoutreturn in pnfs_put_lseg
Date: Tue, 16 Dec 2014 11:01:49 -0800
Message-Id: <1418756513-95187-47-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

pnfs_put_lseg may be called from rpc callbacks. So we should not
call pnfs_send_layoutreturn directly because it can deadlock in
the rpc layer.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pnfs.c | 67 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 47 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a3a5e22..9e7092f 100644
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
 
@@ -359,14 +358,52 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
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
@@ -382,22 +419,12 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
-		bool need_return;
-		nfs4_stateid stateid;
-		enum pnfs_iomode iomode;
-
 		pnfs_get_layout_hdr(lo);
-		need_return = pnfs_layout_need_return(lo, lseg,
-						      &stateid, &iomode);
-		if (need_return) {
+		if (pnfs_layout_need_return(lo, lseg)) {
 			spin_unlock(&inode->i_lock);
 			/* hdr reference dropped in nfs4_layoutreturn_release */
-			pnfs_send_layoutreturn(lo, stateid, iomode, 0,
-					       NFS4_MAX_UINT64, true);
-			spin_lock(&inode->i_lock);
-			pnfs_layout_remove_lseg(lo, lseg);
-			spin_unlock(&inode->i_lock);
-			pnfs_free_lseg(lseg);
+			pnfs_get_layout_hdr(lo);
+			pnfs_layoutreturn_free_lseg_async(lseg);
 		} else {
 			pnfs_layout_remove_lseg(lo, lseg);
 			spin_unlock(&inode->i_lock);
-- 
1.9.3

