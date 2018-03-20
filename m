Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34728 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751551AbeCTUx7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:53:59 -0400
Received: by mail-it0-f68.google.com with SMTP id z7-v6so13983822iti.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:53:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] NFS: Don't redirty the attribute cache in nfs_wcc_update_inode()
Date: Tue, 20 Mar 2018 16:53:29 -0400
Message-Id: <20180320205332.94132-4-trond.myklebust@primarydata.com>
In-Reply-To: <20180320205332.94132-3-trond.myklebust@primarydata.com>
References: <20180320205332.94132-1-trond.myklebust@primarydata.com>
 <20180320205332.94132-2-trond.myklebust@primarydata.com>
 <20180320205332.94132-3-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we received weak cache consistency data from the server, then those
attributes are up to date, and there is no reason to mark them as
dirty in the attribute cache.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5a721c3f4eb0..d8e8bf9da211 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1303,24 +1303,20 @@ static bool nfs_file_has_buffered_writers(struct nfs_inode *nfsi)
 	return nfs_file_has_writers(nfsi) && nfs_file_io_is_buffered(nfsi);
 }
 
-static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+static void nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
-	unsigned long ret = 0;
-
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECHANGE)
 			&& (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			&& inode_eq_iversion_raw(inode, fattr->pre_change_attr)) {
 		inode_set_iversion_raw(inode, fattr->change_attr);
 		if (S_ISDIR(inode->i_mode))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
-		ret |= NFS_INO_INVALID_ATTR;
 	}
 	/* If we have atomic WCC data, we may update some attributes */
 	if ((fattr->valid & NFS_ATTR_FATTR_PRECTIME)
 			&& (fattr->valid & NFS_ATTR_FATTR_CTIME)
 			&& timespec_equal(&inode->i_ctime, &fattr->pre_ctime)) {
 		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
-		ret |= NFS_INO_INVALID_ATTR;
 	}
 
 	if ((fattr->valid & NFS_ATTR_FATTR_PREMTIME)
@@ -1329,17 +1325,13 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
 		if (S_ISDIR(inode->i_mode))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_DATA);
-		ret |= NFS_INO_INVALID_ATTR;
 	}
 	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
 			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
 			&& i_size_read(inode) == nfs_size_to_loff_t(fattr->pre_size)
 			&& !nfs_have_writebacks(inode)) {
 		i_size_write(inode, nfs_size_to_loff_t(fattr->size));
-		ret |= NFS_INO_INVALID_ATTR;
 	}
-
-	return ret;
 }
 
 /**
@@ -1789,7 +1781,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			| NFS_INO_REVAL_PAGECACHE);
 
 	/* Do atomic weak cache consistency updates */
-	invalid |= nfs_wcc_update_inode(inode, fattr);
+	nfs_wcc_update_inode(inode, fattr);
 
 	if (pnfs_layoutcommit_outstanding(inode)) {
 		nfsi->cache_validity |= save_cache_validity & NFS_INO_INVALID_ATTR;
-- 
2.14.3

