Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:51338 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753158AbdF2Ne7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jun 2017 09:34:59 -0400
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com
Cc: jlayton@poochiereds.net, schumaker.anna@gmail.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/4] nfs: add a nfs_ilookup helper
Date: Thu, 29 Jun 2017 06:34:51 -0700
Message-Id: <20170629133453.19641-3-hch@lst.de>
In-Reply-To: <20170629133453.19641-1-hch@lst.de>
References: <20170629133453.19641-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

This helper will allow to find an existing NFS inode by the file handle
and fattr.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
[hch: split from a larger patch]
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/inode.c         | 22 ++++++++++++++++++++++
 include/linux/nfs_fs.h |  1 +
 2 files changed, 23 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1de93ba78dc9..a84eab1a18a7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -386,6 +386,28 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 #endif
 EXPORT_SYMBOL_GPL(nfs_setsecurity);
 
+/* Search for inode identified by fh, fileid and i_mode in inode cache. */
+struct inode *
+nfs_ilookup(struct super_block *sb, struct nfs_fattr *fattr, struct nfs_fh *fh)
+{
+	struct nfs_find_desc desc = {
+		.fh	= fh,
+		.fattr	= fattr,
+	};
+	struct inode *inode;
+	unsigned long hash;
+
+	if (!(fattr->valid & NFS_ATTR_FATTR_FILEID) ||
+	    !(fattr->valid & NFS_ATTR_FATTR_TYPE))
+		return NULL;
+
+	hash = nfs_fattr_to_ino_t(fattr);
+	inode = ilookup5(sb, hash, nfs_find_actor, &desc);
+
+	dprintk("%s: returning %p\n", __func__, inode);
+	return inode;
+}
+
 /*
  * This is our front-end to iget that looks up inodes by file handle
  * instead of inode number.
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bb0eb2c9acca..e52cc55ac300 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -332,6 +332,7 @@ extern void nfs_zap_caches(struct inode *);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
 				struct nfs_fattr *, struct nfs4_label *);
+struct inode *nfs_ilookup(struct super_block *sb, struct nfs_fattr *, struct nfs_fh *);
 extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
-- 
2.11.0

