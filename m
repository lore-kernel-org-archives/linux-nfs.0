Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34843 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbbKQLxx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:53 -0500
Received: by qgec40 with SMTP id c40so3396609qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:52 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 34/38] nfs: nfs_fh_to_dentry() make use of inode cache
Date: Tue, 17 Nov 2015 06:52:56 -0500
Message-Id: <1447761180-4250-35-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Embed NFS fileid and i_mode in the file handle returned to nfsd.
So that in nfs_fh_to_dentry(), we can use them to query inode cache
and thus avoid sending GETATTR.

[jlayton: mask off permission bits in i_mode
	  replace hand-rolled routine with DIV_ROUND_UP
	  add FILEID_NFS_REEXPORT ]

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/export.c          | 51 ++++++++++++++++++++++++++++++++++++++----------
 fs/nfs/inode.c           | 22 +++++++++++++++++++++
 include/linux/exportfs.h |  8 ++++++++
 include/linux/nfs_fs.h   |  1 +
 4 files changed, 72 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 374dcc2590a0..a40a9fc31d13 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -16,6 +16,18 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+enum {
+	FILEID_HIGH_OFF = 0,	/* inode fileid high */
+	FILEID_LOW_OFF,		/* inode fileid low */
+	FILE_I_MODE_OFF,	/* type portion of inode->i_mode */
+	EMBED_FH_OFF		/* embeded server fh */
+};
+
+static struct nfs_fh *nfs_exp_embedfh(__u32 *p)
+{
+	return (struct nfs_fh *)(p + EMBED_FH_OFF);
+}
+
 /*
  * Let's break subtree checking for now... otherwise we'll have to embed parent fh
  * but there might not be enough space.
@@ -24,22 +36,28 @@ static int
 nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
 {
 	struct nfs_fh *server_fh = NFS_FH(inode);
-	struct nfs_fh *clnt_fh = (struct nfs_fh *)p;
-	int disconnected_fh_len = server_fh->size / 4 + 1;
+	struct nfs_fh *clnt_fh = nfs_exp_embedfh(p);
+	int len = EMBED_FH_OFF + DIV_ROUND_UP(server_fh->size, 4) + 1;
 
 	dprintk("%s: max fh len %d inode %p parent %p",
 		__func__, *max_len, inode, parent);
 
-	if (*max_len < disconnected_fh_len) {
-		*max_len = disconnected_fh_len;
+	if (*max_len < len) {
+		dprintk("%s: fh len %d too small, required %d\n",
+			__func__, *max_len, len);
+		*max_len = len;
 		return FILEID_INVALID;
 	}
 
+	p[FILEID_HIGH_OFF] = NFS_FILEID(inode) >> 32;
+	p[FILEID_LOW_OFF] = NFS_FILEID(inode);
+	p[FILE_I_MODE_OFF] = inode->i_mode & S_IFMT;
 	nfs_copy_fh(clnt_fh, server_fh);
-	*max_len = disconnected_fh_len;
+	*max_len = len;
 
-	dprintk("%s: result fh size %d\n", __func__, *max_len);
-	return *max_len;
+	dprintk("%s: result fh fileid %llu mode %u size %d\n",
+		__func__, NFS_FILEID(inode), inode->i_mode, *max_len);
+	return FILEID_NFS_REEXPORT;
 }
 
 static struct dentry *
@@ -48,15 +66,16 @@ nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
 {
 	struct nfs4_label *label = NULL;
 	struct nfs_fattr *fattr = NULL;
-	struct nfs_fh *server_fh = (struct nfs_fh *)fid->raw;
+	struct nfs_fh *server_fh = nfs_exp_embedfh(fid->raw);
 	const struct nfs_rpc_ops *rpc_ops;
 	struct dentry *dentry = NULL;
 	struct inode *inode;
-	int len = server_fh->size / 4 + 1;
+	int len = EMBED_FH_OFF + DIV_ROUND_UP(server_fh->size, 4) + 1;
+	u32 *p = fid->raw;
 	int ret;
 
 	/* NULL translates to ESTALE */
-	if (fh_len < len || fh_type != len)
+	if (fh_len < len || fh_type != FILEID_NFS_REEXPORT)
 		return NULL;
 
 	fattr = nfs_alloc_fattr();
@@ -65,6 +84,16 @@ nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
 		goto out;
 	}
 
+	fattr->fileid = ((u64)p[FILEID_HIGH_OFF] << 32) + p[FILEID_LOW_OFF];
+	fattr->mode = p[FILE_I_MODE_OFF];
+	fattr->valid |= NFS_ATTR_FATTR_FILEID | NFS_ATTR_FATTR_MODE;
+
+	dprintk("%s: fileid %llu mode %d\n", __func__, fattr->fileid, fattr->mode);
+
+	inode = nfs_ilookup(sb, fattr, server_fh);
+	if (inode)
+		goto out_found;
+
 	label = nfs4_label_alloc(NFS_SB(sb), GFP_KERNEL);
 	if (IS_ERR(label)) {
 		ret = PTR_ERR(label);
@@ -79,6 +108,8 @@ nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
 	}
 
 	inode = nfs_fhget(sb, server_fh, fattr, label);
+
+out_found:
 	dentry = d_obtain_alias(inode);
 
 out:
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e10d833..bf6dd7a975b6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -342,6 +342,28 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
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
+	    !(fattr->valid & NFS_ATTR_FATTR_MODE))
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
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index e8ba130f0aa5..783cedf2f636 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -97,6 +97,14 @@ enum fid_type {
 	FILEID_FAT_WITH_PARENT = 0x72,
 
 	/*
+	 * High-order 4 bytes of 64-bit fileid
+	 * Low-order 4 bytes of 64-bit fileid
+	 * inode->i_mode & S_IFMT (4 bytes)
+	 * Embedded copy of fh from underlying server
+	 */
+	FILEID_NFS_REEXPORT = 0x81,
+
+	/*
 	 * Filesystems must not use 0xff file ID.
 	 */
 	FILEID_INVALID = 0xff,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c0e961474a52..958092e8b7ca 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -344,6 +344,7 @@ extern void nfs_zap_caches(struct inode *);
 extern void nfs_invalidate_atime(struct inode *);
 extern struct inode *nfs_fhget(struct super_block *, struct nfs_fh *,
 				struct nfs_fattr *, struct nfs4_label *);
+struct inode *nfs_ilookup(struct super_block *sb, struct nfs_fattr *, struct nfs_fh *);
 extern int nfs_refresh_inode(struct inode *, struct nfs_fattr *);
 extern int nfs_post_op_update_inode(struct inode *inode, struct nfs_fattr *fattr);
 extern int nfs_post_op_update_inode_force_wcc(struct inode *inode, struct nfs_fattr *fattr);
-- 
2.4.3

