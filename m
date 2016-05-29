Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33608 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323AbcE2RPE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:04 -0400
Received: by mail-pf0-f195.google.com with SMTP id b124so19123243pfb.0
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:03 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 4/6] nfs:  Add 'archive' field to nfs inode, along with corresponding bitfields, request, and decode xdr routines.
Date: Sun, 29 May 2016 10:14:50 -0700
Message-Id: <1464542092-19605-5-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add xdr support for NFS attribute 'archive'.

This will permit the surfacing of this attribute for underlying filesystems that support it.

Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>
---
 fs/nfs/inode.c            | 14 ++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +++
 fs/nfs/nfs4xdr.c          | 28 ++++++++++++++++++++++++++++
 include/linux/nfs_fs.h    |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  3 +++
 6 files changed, 50 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e995b0f..7a6ee66 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -442,6 +442,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		memset(&nfsi->timecreate, 0, sizeof(nfsi->timecreate));
 		nfsi->hidden = 0;
 		nfsi->system = 0;
+		nfsi->archive = 0;
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
@@ -478,6 +479,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			nfsi->system = (fattr->hsa_flags & NFS_HSA_SYSTEM) != 0;
 		else if (nfs_server_capable(inode, NFS_CAP_SYSTEM))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+		if (fattr->valid & NFS_ATTR_FATTR_ARCHIVE)
+			nfsi->archive = (fattr->hsa_flags & NFS_HSA_ARCHIVE) !=0;
+		else if (nfs_server_capable(inode, NFS_CAP_ARCHIVE))
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else
@@ -1806,6 +1811,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_ARCHIVE) {
+		nfsi->archive = (fattr->hsa_flags | NFS_HSA_ARCHIVE) != 0;
+	} else if (server->caps & NFS_CAP_ARCHIVE) {
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
index 5ee8084..1d84b5c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -180,6 +180,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD0_SIZE
 	| FATTR4_WORD0_FSID
 	| FATTR4_WORD0_HIDDEN
+	| FATTR4_WORD0_ARCHIVE
 	| FATTR4_WORD0_FILEID,
 	FATTR4_WORD1_MODE
 	| FATTR4_WORD1_NUMLINKS
@@ -3064,6 +3065,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_FILEID;
 		if (res.attr_bitmask[0] & FATTR4_WORD0_HIDDEN)
 			server->caps |= NFS_CAP_HIDDEN;
+		if (res.attr_bitmask[0] & FATTR4_WORD0_ARCHIVE)
+			server->caps |= NFS_CAP_ARCHIVE;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_MODE)
 			server->caps |= NFS_CAP_MODE;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_NUMLINKS)
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5de5950..d8328a5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4193,6 +4193,29 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_archive(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
+{
+	__be32 *p;
+
+	*res = 0;
+	if (unlikely(bitmap[0] & (FATTR4_WORD0_ARCHIVE - 1U)))
+		return -EIO;
+	if (likely(bitmap[0] & FATTR4_WORD0_ARCHIVE)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (be32_to_cpup(p)) {
+			*res |= NFS_HSA_ARCHIVE;
+		}
+		bitmap[0] &= ~FATTR4_WORD0_ARCHIVE;
+	}
+	dprintk("%s: archive file: =%s\n", __func__, (*res & NFS_HSA_ARCHIVE) == 0 ? "false" : "true");
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
 {
 	int status = 0;
@@ -4658,6 +4681,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 	if (status < 0)
 		goto xdr_error;
 
+	status = decode_attr_archive(xdr, bitmap, &fattr->hsa_flags);
+	if (status < 0) 
+		goto xdr_error;
+	fattr->valid |= status;
+
 	status = decode_attr_filehandle(xdr, bitmap, fh);
 	if (status < 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1283505..83c42f6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -137,6 +137,7 @@ struct nfs_inode {
 	struct timespec		timecreate;
 	bool			hidden;
 	bool			system;
+	bool			archive;
 	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
 	 * attrtimeo is for how long the cached information is assumed
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7ce3922..3f972e7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -248,5 +248,6 @@ struct nfs_server {
 #define NFS_CAP_TIME_CREATE	(1U << 26)
 #define NFS_CAP_HIDDEN          (1U << 27)
 #define NFS_CAP_SYSTEM          (1U << 28)
+#define NFS_CAP_ARCHIVE         (1U << 29)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 405b8c4..de90f90 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -17,6 +17,7 @@
 /* HIDDEN, SYSTEM bitfields in hsa_flags in nfs_fattr */
 #define NFS_HSA_HIDDEN		(1U << 0)
 #define NFS_HSA_SYSTEM		(1U << 1)
+#define NFS_HSA_ARCHIVE		(1U << 2)
 
 struct nfs4_string {
 	unsigned int len;
@@ -111,6 +112,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_TIME_CREATE	(1U << 26)
 #define NFS_ATTR_FATTR_HIDDEN           (1U << 27)
 #define NFS_ATTR_FATTR_SYSTEM           (1U << 28)
+#define NFS_ATTR_FATTR_ARCHIVE          (1U << 29)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -127,6 +129,7 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_TIME_CREATE \
 		| NFS_ATTR_FATTR_HIDDEN \
 		| NFS_ATTR_FATTR_SYSTEM \
+		| NFS_ATTR_FATTR_ARCHIVE \
 		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
-- 
2.3.6

