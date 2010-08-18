Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab0HROo2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:28 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 05/11] SQUASHME pnfs-submit: rename pnfs_layout_type 5
Date: Wed, 18 Aug 2010 10:44:12 -0400
Message-Id: <1282142658-21579-6-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-5-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
 <1282142658-21579-2-git-send-email-andros@netapp.com>
 <1282142658-21579-3-git-send-email-andros@netapp.com>
 <1282142658-21579-4-git-send-email-andros@netapp.com>
 <1282142658-21579-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layout helper functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fdc4028..a10143e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -526,7 +526,7 @@ send_layoutget(struct inode *ino,
 	   struct nfs_open_context *ctx,
 	   struct nfs4_pnfs_layout_segment *range,
 	   struct pnfs_layout_segment **lsegpp,
-	   struct pnfs_layout_type *lo)
+	   struct pnfs_layout_hdr *lo)
 {
 	int status;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -789,7 +789,7 @@ cmp_layout(struct nfs4_pnfs_layout_segment *l1,
 }
 
 static void
-pnfs_insert_layout(struct pnfs_layout_type *lo,
+pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		   struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_segment *lp;
@@ -915,7 +915,7 @@ has_matching_lseg(struct pnfs_layout_segment *lseg,
  * lookup range in layout
  */
 static struct pnfs_layout_segment *
-pnfs_has_layout(struct pnfs_layout_type *lo,
+pnfs_has_layout(struct pnfs_layout_hdr *lo,
 		struct nfs4_pnfs_layout_segment *range)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
@@ -955,14 +955,14 @@ _pnfs_update_layout(struct inode *ino,
 		.length = NFS4_MAX_UINT64,
 	};
 	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_type *lo;
+	struct pnfs_layout_hdr *lo;
 	struct pnfs_layout_segment *lseg = NULL;
 
 	*lsegpp = NULL;
 	spin_lock(&ino->i_lock);
 	lo = pnfs_alloc_layout(ino);
 	if (lo == NULL) {
-		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
+		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
 		goto out_unlock;
 	}
 
@@ -1120,7 +1120,7 @@ out:
 int
 pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 {
-	struct pnfs_layout_type *lo = NFS_I(lgp->args.inode)->layout;
+	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
 	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = PNFS_INODE(lo);
-- 
1.6.2.5

