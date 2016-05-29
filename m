Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35757 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282AbcE2RPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:02 -0400
Received: by mail-pf0-f195.google.com with SMTP id f144so12675495pfa.2
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:02 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 2/6] nfs:  Add 'hidden' field to nfs inode, along with corresponding bitfields, request, and decode xdr routines.
Date: Sun, 29 May 2016 10:14:48 -0700
Message-Id: <1464542092-19605-3-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add xdr support for NFS attribute 'hidden'.

This will permit the surfacing of this attribute for underlying filesystems that support it.

Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>
---
 fs/nfs/inode.c            | 14 ++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +++
 fs/nfs/nfs4xdr.c          | 28 ++++++++++++++++++++++++++++
 include/linux/nfs_fs.h    |  2 +-
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  6 ++++++
 6 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 82528e0..0cd1d95 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -440,6 +440,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		memset(&inode->i_mtime, 0, sizeof(inode->i_mtime));
 		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
 		memset(&nfsi->timecreate, 0, sizeof(nfsi->timecreate));
+		nfsi->hidden = 0;
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
@@ -468,6 +469,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			nfsi->timecreate = fattr->time_create;
 		else if (nfs_server_capable(inode, NFS_CAP_TIME_CREATE))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+		if (fattr->valid & NFS_ATTR_FATTR_HIDDEN)
+			nfsi->hidden = (fattr->hsa_flags & NFS_HSA_HIDDEN) != 0;
+		else if (nfs_server_capable(inode, NFS_CAP_HIDDEN))
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else
@@ -1778,6 +1783,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_HIDDEN) {
+		nfsi->hidden = (fattr->hsa_flags | NFS_HSA_HIDDEN) != 0;
+	} else if (server->caps & NFS_CAP_HIDDEN) {
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
index 2e45c10..cec7d19 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -179,6 +179,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_SIZE
 	| FATTR4_WORD0_FSID
+	| FATTR4_WORD0_HIDDEN
 	| FATTR4_WORD0_FILEID,
 	FATTR4_WORD1_MODE
 	| FATTR4_WORD1_NUMLINKS
@@ -3060,6 +3061,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_SYMLINKS;
 		if (res.attr_bitmask[0] & FATTR4_WORD0_FILEID)
 			server->caps |= NFS_CAP_FILEID;
+		if (res.attr_bitmask[0] & FATTR4_WORD0_HIDDEN)
+			server->caps |= NFS_CAP_HIDDEN;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_MODE)
 			server->caps |= NFS_CAP_MODE;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_NUMLINKS)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bc0cfae..e870385 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4147,6 +4147,29 @@ static int decode_attr_time_create(struct xdr_stream *xdr, uint32_t *bitmap, str
 	return status;
 }
 
+static int decode_attr_hidden(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
+{
+	__be32 *p;
+
+	*res = 0;
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_HIDDEN - 1U)))
+		return -EIO;
+	if (likely(bitmap[0] & FATTR4_WORD0_HIDDEN)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (be32_to_cpup(p)) {
+			*res |= NFS_HSA_HIDDEN;
+		}
+		bitmap[0] &= ~FATTR4_WORD0_HIDDEN;
+	}
+	dprintk("%s: hidden file: =%s\n", __func__, (*res & NFS_HSA_HIDDEN) == 0 ? "false" : "true");
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
 {
 	int status = 0;
@@ -4621,6 +4644,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_hidden(xdr, bitmap, &fattr->hsa_flags);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
+
 	status = decode_attr_fs_locations(xdr, bitmap, fs_loc);
 	if (status < 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 18d9535..75e7a2c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -135,7 +135,7 @@ struct nfs_inode {
 	 */
 
 	struct timespec		timecreate;
-
+	bool			hidden;
 	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
 	 * attrtimeo is for how long the cached information is assumed
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7c1713c..fe2ade7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -246,5 +246,6 @@ struct nfs_server {
 #define NFS_CAP_ALLOW_ACLS	(1U << 24)
 #define NFS_CAP_DENY_ACLS	(1U << 25)
 #define NFS_CAP_TIME_CREATE	(1U << 26)
+#define NFS_CAP_HIDDEN          (1U << 27)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index cc4a3f5..204e031 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -14,6 +14,9 @@
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
 
+/* HIDDEN bitfield in hsa_flags in nfs_fattr */
+#define NFS_HSA_HIDDEN		(1U << 0)
+
 struct nfs4_string {
 	unsigned int len;
 	char *data;
@@ -65,6 +68,7 @@ struct nfs_fattr {
 	struct timespec		mtime;
 	struct timespec		ctime;
 	struct timespec		time_create;
+	__u32			hsa_flags;	/* hidden, system, archive flags bitfield */
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	__u64			pre_size;	/* pre_op_attr.size	  */
@@ -104,6 +108,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_GROUP_NAME	(1U << 24)
 #define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 25)
 #define NFS_ATTR_FATTR_TIME_CREATE	(1U << 26)
+#define NFS_ATTR_FATTR_HIDDEN           (1U << 27)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -118,6 +123,7 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_MTIME \
 		| NFS_ATTR_FATTR_CTIME \
 		| NFS_ATTR_FATTR_TIME_CREATE \
+		| NFS_ATTR_FATTR_HIDDEN \
 		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
-- 
2.3.6

