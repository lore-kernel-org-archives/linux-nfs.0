Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbcG1SlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 14:41:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>
Subject: [PATCH 2/2] pNFS: Actively set attributes as invalid if LAYOUTCOMMIT is outstanding
Date: Thu, 28 Jul 2016 14:41:10 -0400
Message-Id: <ff7fc557ff6953c01aa1e9508e9b0067d30038f7.1469730653.git.bcodding@redhat.com>
In-Reply-To: <cover.1469730653.git.bcodding@redhat.com>
References: <cover.1469730653.git.bcodding@redhat.com>
In-Reply-To: <cover.1469730653.git.bcodding@redhat.com>
References: <cover.1469730653.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A LAYOUTCOMMIT then subsequent GETATTR may both return the same attributes,
and in that case NFS_INO_INVALID_ATTR is never set on the second pass
through nfs_update_inode().  The existing check to skip the clearing of
NFS_INO_INVALID_ATTR if a LAYOUTCOMMIT is outstanding does not help in this
case (see commit 10b7e9ad4488: "pNFS: Don't mark the inode as revalidated
if a LAYOUTCOMMIT is outstanding").  We know that if a LAYOUTCOMMIT is
outstanding then attributes will need upating, so always set
NFS_INO_INVALID_ATTR.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/inode.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f108d58101f8..bf4ec5ecc97e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1665,7 +1665,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
 	bool have_writers = nfs_file_has_buffered_writers(nfsi);
-	bool cache_revalidated;
+	bool cache_revalidated = true;
 
 	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
@@ -1714,8 +1714,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/* Do atomic weak cache consistency updates */
 	invalid |= nfs_wcc_update_inode(inode, fattr);
 
-
-	cache_revalidated = !pnfs_layoutcommit_outstanding(inode);
+	if (pnfs_layoutcommit_outstanding(inode)) {
+		nfsi->cache_validity |= save_cache_validity & NFS_INO_INVALID_ATTR;
+		cache_revalidated = false;
+	}
 
 	/* More cache consistency checks */
 	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
-- 
2.5.5

