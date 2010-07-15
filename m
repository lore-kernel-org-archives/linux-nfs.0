From: andros@netapp.com
Subject: [PATCH 4/4] SQUASHME pnfs-submit remove unnecessary layoutget field
Date: Thu, 15 Jul 2010 16:58:54 -0400
Message-ID: <1279227534-3226-5-git-send-email-andros@netapp.com>
References: <1279227534-3226-1-git-send-email-andros@netapp.com>
 <1279227534-3226-2-git-send-email-andros@netapp.com>
 <1279227534-3226-3-git-send-email-andros@netapp.com>
 <1279227534-3226-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934723Ab0GOU6c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jul 2010 16:58:32 -0400
In-Reply-To: <1279227534-3226-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Don't need both an inode and a pnfs_layout_type field.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c        |    2 +-
 fs/nfs/pnfs.c            |    5 ++---
 include/linux/pnfs_xdr.h |    1 -
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ebe1b49..4aa4fc1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5448,7 +5448,7 @@ static void nfs4_pnfs_layoutget_release(void *calldata)
 	struct nfs4_pnfs_layoutget *lgp = calldata;
 
 	dprintk("--> %s\n", __func__);
-	pnfs_layout_release(lgp->lo, NULL);
+	pnfs_layout_release(NFS_I(lgp->args.inode)->layout, NULL);
 	if (lgp->res.layout.buf != NULL)
 		free_page((unsigned long) lgp->res.layout.buf);
 	kfree(calldata);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index edcbe46..7a30eb0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -524,7 +524,6 @@ send_layoutget(struct inode *ino,
 		pnfs_layout_release(lo, NULL);
 		return -ENOMEM;
 	}
-	lgp->lo = lo;
 	lgp->args.minlength = NFS4_MAX_UINT64;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.lseg.iomode = range->iomode;
@@ -1003,7 +1002,7 @@ void
 pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 {
 	struct pnfs_layout_segment *lseg = NULL;
-	struct nfs_inode *nfsi = PNFS_NFS_INODE(lgp->lo);
+	struct nfs_inode *nfsi = NFS_I(lgp->args.inode);
 	time_t suspend = 0;
 
 	dprintk("-->%s\n", __func__);
@@ -1106,7 +1105,7 @@ out:
 int
 pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 {
-	struct pnfs_layout_type *lo = lgp->lo;
+	struct pnfs_layout_type *lo = NFS_I(lgp->args.inode)->layout;
 	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = PNFS_INODE(lo);
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index f9c9950..c9a01b3 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -49,7 +49,6 @@ struct nfs4_pnfs_layoutget_res {
 };
 
 struct nfs4_pnfs_layoutget {
-	struct pnfs_layout_type *lo;
 	struct nfs4_pnfs_layoutget_arg args;
 	struct nfs4_pnfs_layoutget_res res;
 	struct pnfs_layout_segment **lsegpp;
-- 
1.6.6

