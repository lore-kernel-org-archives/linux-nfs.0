Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:63650 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbBFEpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 23:45:14 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so5404818iga.0
        for <linux-nfs@vger.kernel.org>; Thu, 05 Feb 2015 20:45:13 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH v3 5/5] NFSv4.1: Fix pnfs_put_lseg races
Date: Thu,  5 Feb 2015 23:45:07 -0500
Message-Id: <1423197907-75541-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423197907-75541-4-git-send-email-trond.myklebust@primarydata.com>
References: <1423197907-75541-1-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-2-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-3-git-send-email-trond.myklebust@primarydata.com>
 <1423197907-75541-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_layoutreturn_free_lseg_async() can also race with inode put in
the general case. We can now fix this, and also simplify the code.

Cc: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 53 +++++++++++++++++++----------------------------------
 1 file changed, 19 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a1d8620e8cb7..107b321be7d4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -361,14 +361,9 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
 	return true;
 }
 
-static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
+static void pnfs_layoutreturn_before_put_lseg(struct pnfs_layout_segment *lseg,
+		struct pnfs_layout_hdr *lo, struct inode *inode)
 {
-	struct pnfs_layout_segment *lseg;
-	struct pnfs_layout_hdr *lo;
-	struct inode *inode;
-
-	lseg = container_of(work, struct pnfs_layout_segment, pls_work);
-	WARN_ON(atomic_read(&lseg->pls_refcount));
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
 
@@ -383,24 +378,12 @@ static void pnfs_layoutreturn_free_lseg(struct work_struct *work)
 		lo->plh_block_lgets++;
 		lo->plh_return_iomode = 0;
 		spin_unlock(&inode->i_lock);
+		pnfs_get_layout_hdr(lo);
 
-		pnfs_send_layoutreturn(lo, stateid, iomode, true);
-		spin_lock(&inode->i_lock);
+		/* Send an async layoutreturn so we dont deadlock */
+		pnfs_send_layoutreturn(lo, stateid, iomode, false);
 	} else
-		/* match pnfs_get_layout_hdr #2 in pnfs_put_lseg */
-		pnfs_put_layout_hdr(lo);
-	pnfs_layout_remove_lseg(lo, lseg);
-	spin_unlock(&inode->i_lock);
-	pnfs_free_lseg(lseg);
-	/* match pnfs_get_layout_hdr #1 in pnfs_put_lseg */
-	pnfs_put_layout_hdr(lo);
-}
-
-static void
-pnfs_layoutreturn_free_lseg_async(struct pnfs_layout_segment *lseg)
-{
-	INIT_WORK(&lseg->pls_work, pnfs_layoutreturn_free_lseg);
-	queue_work(nfsiod_workqueue, &lseg->pls_work);
+		spin_unlock(&inode->i_lock);
 }
 
 void
@@ -415,21 +398,23 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->pls_refcount),
 		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+
+	/* Handle the case where refcount != 1 */
+	if (atomic_add_unless(&lseg->pls_refcount, -1, 1))
+		return;
+
 	lo = lseg->pls_layout;
 	inode = lo->plh_inode;
+	/* Do we need a layoutreturn? */
+	if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
+		pnfs_layoutreturn_before_put_lseg(lseg, lo, inode);
+
 	if (atomic_dec_and_lock(&lseg->pls_refcount, &inode->i_lock)) {
 		pnfs_get_layout_hdr(lo);
-		if (pnfs_layout_need_return(lo, lseg)) {
-			spin_unlock(&inode->i_lock);
-			/* hdr reference dropped in nfs4_layoutreturn_release */
-			pnfs_get_layout_hdr(lo);
-			pnfs_layoutreturn_free_lseg_async(lseg);
-		} else {
-			pnfs_layout_remove_lseg(lo, lseg);
-			spin_unlock(&inode->i_lock);
-			pnfs_free_lseg(lseg);
-			pnfs_put_layout_hdr(lo);
-		}
+		pnfs_layout_remove_lseg(lo, lseg);
+		spin_unlock(&inode->i_lock);
+		pnfs_free_lseg(lseg);
+		pnfs_put_layout_hdr(lo);
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg);
-- 
2.1.0

