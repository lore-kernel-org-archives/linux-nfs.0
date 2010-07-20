From: andros@netapp.com
Subject: [PATCH 4/5] SQUASHME pnfs-submit pnfs_release_layout just use inode
Date: Tue, 20 Jul 2010 13:01:22 -0400
Message-ID: <1279645283-9862-5-git-send-email-andros@netapp.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
 <1279645283-9862-2-git-send-email-andros@netapp.com>
 <1279645283-9862-3-git-send-email-andros@netapp.com>
 <1279645283-9862-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761410Ab0GTRCE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:02:04 -0400
In-Reply-To: <1279645283-9862-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 ++--
 fs/nfs/pnfs.c     |   16 +++++++---------
 fs/nfs/pnfs.h     |    3 ++-
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 17b0c31..d0fa4d1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5467,7 +5467,7 @@ static void nfs4_pnfs_layoutget_release(void *calldata)
 	struct nfs4_pnfs_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	pnfs_layout_release(NFS_I(lgp->args.inode)->layout, NULL);
+	pnfs_layout_release(lgp->args.inode, NULL);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	kfree(calldata);
@@ -5687,7 +5687,7 @@ static void nfs4_pnfs_layoutreturn_release(void *calldata)
 	if (lrp->args.return_type == RETURN_FILE) {
 		if (!lrp->res.lrs_present)
 			pnfs_set_layout_stateid(lo, &zero_stateid);
-		pnfs_layout_release(lo, &lrp->args.lseg);
+		pnfs_layout_release(lrp->args.inode, &lrp->args.lseg);
 	}
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cf64f16..aba3478 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -345,19 +345,17 @@ put_layout(struct inode *inode)
 }
 
 void
-pnfs_layout_release(struct pnfs_layout_type *lo,
+pnfs_layout_release(struct inode *inode,
 		    struct nfs4_pnfs_layout_segment *range)
 {
-	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
-
 	if (range)
-		pnfs_free_layout(lo->lo_inode, range);
+		pnfs_free_layout(inode, range);
 	/*
 	 * Matched in _pnfs_update_layout for layoutget
 	 * and by get_layout in _pnfs_return_layout for layoutreturn
 	 */
-	put_layout(lo->lo_inode);
-	wake_up_all(&nfsi->lo_waitq);
+	put_layout(inode);
+	wake_up_all(&NFS_I(inode)->lo_waitq);
 }
 
 void
@@ -490,7 +488,7 @@ send_layoutget(struct inode *ino,
 
 	lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
 	if (lgp == NULL) {
-		pnfs_layout_release(lo, NULL);
+		pnfs_layout_release(ino, NULL);
 		return -ENOMEM;
 	}
 	lgp->args.minlength = NFS4_MAX_UINT64;
@@ -652,7 +650,7 @@ return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (lrp == NULL) {
 		if (lo && (type == RETURN_FILE))
-			pnfs_layout_release(lo, NULL);
+			pnfs_layout_release(ino, NULL);
 		goto out;
 	}
 	lrp->args.reclaim = 0;
@@ -730,7 +728,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		if (!stateid)
 			status = return_layout(ino, &arg, type, lo, wait);
 		else
-			pnfs_layout_release(lo, &arg);
+			pnfs_layout_release(ino, &arg);
 	}
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9498e4e..b3830f5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -60,7 +60,8 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
-void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
+void pnfs_layout_release(struct inode *,
+			 struct nfs4_pnfs_layout_segment *range);
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
-- 
1.6.6

