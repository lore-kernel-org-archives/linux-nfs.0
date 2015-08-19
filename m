Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35831 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbbHSUZw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 16:25:52 -0400
Received: by pacdd16 with SMTP id dd16so1959266pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2015 13:25:51 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH] NFSv4/pnfs: Ensure we don't miss a file extension
Date: Thu, 20 Aug 2015 04:24:50 +0800
Message-Id: <1440015890-28211-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

pNFS writes don't return attributes, however that doesn't mean that we
should ignore the fact that they may be extending the file. This patch
ensures that if a write is seen to extend the file, then we always set
an attribute barrier, and update the cached file size.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
Please apply this to 4.0+ stable releases. It is upstream commit
2b83d3de4c18af49800e0b26ae013db4fcf43a4a. It fixes
a08a8cd375db9769588257e7782f6b6b68561b88(NFS: Add attribute update barriers to NFS writebacks)
and makes sure we pass fstest read_write/mctime.t test with delegation and inband IO.
Without it, users might see mtime not updated after write.

Cheers,
Tao

 fs/nfs/write.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 359e9ad..0e6a2b8 100644
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
1.8.3.1

