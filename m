Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34425 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932315AbcE2RPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id c84so12122449pfc.1
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:02 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 3/6] nfs:  Add 'system' field to nfs inode, along with corresponding bitfields, request, and decode xdr routines.
Date: Sun, 29 May 2016 10:14:49 -0700
Message-Id: <1464542092-19605-4-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add xdr support for NFS attribute 'system'.

This will permit the surfacing of this attribute for underlying filesystems that support it.

Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>
---
 fs/nfs/inode.c            | 14 ++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +++
 fs/nfs/nfs4xdr.c          | 28 ++++++++++++++++++++++++++++
 include/linux/nfs_fs.h    |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  5 ++++-
 6 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0cd1d95..e995b0f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -441,6 +441,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
 		memset(&nfsi->timecreate, 0, sizeof(nfsi->timecreate));
 		nfsi->hidden = 0;
+		nfsi->system = 0;
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
@@ -473,6 +474,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			nfsi->hidden = (fattr->hsa_flags & NFS_HSA_HIDDEN) != 0;
 		else if (nfs_server_capable(inode, NFS_CAP_HIDDEN))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+		if (fattr->valid & NFS_ATTR_FATTR_SYSTEM)
+			nfsi->system = (fattr->hsa_flags & NFS_HSA_SYSTEM) != 0;
+		else if (nfs_server_capable(inode, NFS_CAP_SYSTEM))
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else
@@ -1792,6 +1797,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_SYSTEM) {
+		nfsi->system = (fattr->hsa_flags | NFS_HSA_SYSTEM) != 0;
+	} else if (server->caps & NFS_CAP_SYSTEM) {
+		nfsi->cache_validity |= save_cache_validity &
+				(NFS_INO_INVALID_ATTR
+				| NFS_INO_REVAL_FORCED);
+		cache_revalidated = false;
+	}
+
 	/* Check if our cached file size is stale */
 	if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
 		new_isize = nfs_size_to_loff_t(fattr->size);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cec7d19..5ee8084 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -189,6 +189,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD1_SPACE_USED
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_CREATE
+	| FATTR4_WORD1_SYSTEM
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
@@ -3079,6 +3080,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_MTIME;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_CREATE)
 			server->caps |= NFS_CAP_TIME_CREATE;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_SYSTEM)
+			server->caps |= NFS_CAP_SYSTEM;
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
 			server->caps |= NFS_CAP_SECURITY_LABEL;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e870385..5de5950 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4170,6 +4170,29 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_system(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
+{
+	__be32 *p;
+
+	*res = 0;
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_SYSTEM - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_SYSTEM)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (be32_to_cpup(p)) {
+			*res |= NFS_HSA_SYSTEM;
+		}
+		bitmap[1] &= ~FATTR4_WORD1_SYSTEM;
+	}
+	dprintk("%s: system file: =%s\n", __func__, (*res & NFS_HSA_HIDDEN) == 0 ? "false" : "true");
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
 {
 	int status = 0;
@@ -4687,6 +4710,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_system(xdr, bitmap, &fattr->hsa_flags);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
+
 	status = decode_attr_time_access(xdr, bitmap, &fattr->atime);
 	if (status < 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 75e7a2c..1283505 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -136,6 +136,7 @@ struct nfs_inode {
 
 	struct timespec		timecreate;
 	bool			hidden;
+	bool			system;
 	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
 	 * attrtimeo is for how long the cached information is assumed
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index fe2ade7..7ce3922 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -247,5 +247,6 @@ struct nfs_server {
 #define NFS_CAP_DENY_ACLS	(1U << 25)
 #define NFS_CAP_TIME_CREATE	(1U << 26)
 #define NFS_CAP_HIDDEN          (1U << 27)
+#define NFS_CAP_SYSTEM          (1U << 28)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 204e031..405b8c4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -14,8 +14,9 @@
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
 
-/* HIDDEN bitfield in hsa_flags in nfs_fattr */
+/* HIDDEN, SYSTEM bitfields in hsa_flags in nfs_fattr */
 #define NFS_HSA_HIDDEN		(1U << 0)
+#define NFS_HSA_SYSTEM		(1U << 1)
 
 struct nfs4_string {
 	unsigned int len;
@@ -109,6 +110,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 25)
 #define NFS_ATTR_FATTR_TIME_CREATE	(1U << 26)
 #define NFS_ATTR_FATTR_HIDDEN           (1U << 27)
+#define NFS_ATTR_FATTR_SYSTEM           (1U << 28)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -124,6 +126,7 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_CTIME \
 		| NFS_ATTR_FATTR_TIME_CREATE \
 		| NFS_ATTR_FATTR_HIDDEN \
+		| NFS_ATTR_FATTR_SYSTEM \
 		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
-- 
2.3.6

