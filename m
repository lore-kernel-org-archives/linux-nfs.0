Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36404 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbGWStF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:49:05 -0400
Received: by oibn4 with SMTP id n4so1405481oib.3
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2015 11:49:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4/pnfs: Ensure we don't miss a file extension
Date: Thu, 23 Jul 2015 14:48:57 -0400
Message-Id: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pNFS writes don't return attributes, however that doesn't mean that we
should ignore the fact that they may be extending the file. This patch
ensures that if a write is seen to extend the file, then we always set
an attribute barrier, and update the cached file size.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 359e9ad596c9..0e6a2b8786b4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1378,24 +1378,27 @@ static void nfs_writeback_check_extend(struct nfs_pgio_header *hdr,
 {
 	struct nfs_pgio_args *argp = &hdr->args;
 	struct nfs_pgio_res *resp = &hdr->res;
+	u64 size = argp->offset + resp->count;
 
 	if (!(fattr->valid & NFS_ATTR_FATTR_SIZE))
+		fattr->size = size;
+	if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode)) {
+		fattr->valid &= ~NFS_ATTR_FATTR_SIZE;
 		return;
-	if (argp->offset + resp->count != fattr->size)
-		return;
-	if (nfs_size_to_loff_t(fattr->size) < i_size_read(hdr->inode))
+	}
+	if (size != fattr->size)
 		return;
 	/* Set attribute barrier */
 	nfs_fattr_set_barrier(fattr);
+	/* ...and update size */
+	fattr->valid |= NFS_ATTR_FATTR_SIZE;
 }
 
 void nfs_writeback_update_inode(struct nfs_pgio_header *hdr)
 {
-	struct nfs_fattr *fattr = hdr->res.fattr;
+	struct nfs_fattr *fattr = &hdr->fattr;
 	struct inode *inode = hdr->inode;
 
-	if (fattr == NULL)
-		return;
 	spin_lock(&inode->i_lock);
 	nfs_writeback_check_extend(hdr, fattr);
 	nfs_post_op_update_inode_force_wcc_locked(inode, fattr);
-- 
2.4.3

