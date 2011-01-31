Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754260Ab1AaWTl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Jan 2011 17:19:41 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: nfs_wcc_update_inode() should set nfsi->attr_gencount
Date: Mon, 31 Jan 2011 17:19:20 -0500
Message-Id: <1296512360-15987-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If the call to nfs_wcc_update_inode() results in an attribute update, we
need to ensure that the inode's attr_gencount gets bumped too, otherwise
we are not protected against races with other GETATTR calls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d851242..1cc600e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -881,9 +881,10 @@ out:
 	return ret;
 }
 
-static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned long ret = 0;
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECHANGE)
 			&& (fattr->valid & NFS_ATTR_FATTR_CHANGE)
@@ -891,25 +892,32 @@ static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		nfsi->change_attr = fattr->change_attr;
 		if (S_ISDIR(inode->i_mode))
 			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+		ret |= NFS_INO_INVALID_ATTR;
 	}
 	/* If we have atomic WCC data, we may update some attributes */
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_CTIME)
-			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime))
-			memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
+			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime)) {
+		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
+		ret |= NFS_INO_INVALID_ATTR;
+	}
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PREMTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_MTIME)
 			&& timespec_equal(&inode->i_mtime, &fattr->pre_mtime)) {
-			memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-			if (S_ISDIR(inode->i_mode))
-				nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
+		if (S_ISDIR(inode->i_mode))
+			nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+		ret |= NFS_INO_INVALID_ATTR;
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
 			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			&& i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size)
-			&& nfsi->npages == 0)
-			i_size_write(inode, nfs_size_to_loff_t(fattr->size));
+			&& nfsi->npages == 0) {
+		i_size_write(inode, nfs_size_to_loff_t(fattr->size));
+		ret |= NFS_INO_INVALID_ATTR;
+	}
+	return ret;
 }
 
 /**
@@ -1223,7 +1231,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			| NFS_INO_REVAL_PAGECACHE);
 
 	/* Do atomic weak cache consistency updates */
-	nfs_wcc_update_inode(inode, fattr);
+	invalid |= nfs_wcc_update_inode(inode, fattr);
 
 	/* More cache consistency checks */
 	if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
-- 
1.7.3.5

