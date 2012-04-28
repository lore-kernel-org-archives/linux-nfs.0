Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877Ab2D1TbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 15:31:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/10] NFS: Simplify nfs_fhget()
Date: Sat, 28 Apr 2012 15:30:53 -0400
Message-Id: <1335641460-24839-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335641460-24839-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1335641460-24839-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the inode is being initialised, there is no point in
setting flags such as NFS_INO_INVALID_ACCESS,
NFS_INO_INVALID_ACL or NFS_INO_INVALID_DATA since there are
no cached access calls, acls or data caches to invalidate.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 59a12c6..fdbf76a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -285,9 +285,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		inode->i_mode = fattr->mode;
 		if ((fattr->valid & NFS_ATTR_FATTR_MODE) == 0
 				&& nfs_server_capable(inode, NFS_CAP_MODE))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		/* Why so? Because we want revalidate for devices/FIFOs, and
 		 * that's precisely what we have in nfs_file_inode_operations.
 		 */
@@ -337,24 +335,19 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		if (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			inode->i_mtime = fattr->mtime;
 		else if (nfs_server_capable(inode, NFS_CAP_MTIME))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_CTIME)
 			inode->i_ctime = fattr->ctime;
 		else if (nfs_server_capable(inode, NFS_CAP_CTIME))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			inode->i_size = nfs_size_to_loff_t(fattr->size);
 		else
 			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_DATA
 				| NFS_INO_REVAL_PAGECACHE;
 		if (fattr->valid & NFS_ATTR_FATTR_NLINK)
 			set_nlink(inode, fattr->nlink);
@@ -363,15 +356,11 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 		if (fattr->valid & NFS_ATTR_FATTR_OWNER)
 			inode->i_uid = fattr->uid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_GROUP)
 			inode->i_gid = fattr->gid;
 		else if (nfs_server_capable(inode, NFS_CAP_OWNER_GROUP))
-			nfsi->cache_validity |= NFS_INO_INVALID_ATTR
-				| NFS_INO_INVALID_ACCESS
-				| NFS_INO_INVALID_ACL;
+			nfsi->cache_validity |= NFS_INO_INVALID_ATTR;
 		if (fattr->valid & NFS_ATTR_FATTR_BLOCKS_USED)
 			inode->i_blocks = fattr->du.nfs2.blocks;
 		if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
-- 
1.7.7.6

