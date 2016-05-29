Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34417 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbcE2RPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id c84so12122410pfc.1
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:01 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <anne.marie.merritt@gmail.com>,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 1/6] nfs:  Add timecreate to nfs inode, along with corresponding bitfields, request, and decode xdr routines.
Date: Sun, 29 May 2016 10:14:47 -0700
Message-Id: <1464542092-19605-2-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add xdr support for NFS attribute 'timecreate'.

This will permit the surfacing of this attribute for underlying filesystems that support it.

Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>
---
 fs/nfs/inode.c            | 14 ++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +++
 fs/nfs/nfs4xdr.c          | 23 +++++++++++++++++++++++
 include/linux/nfs_fs.h    |  6 ++++++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  3 +++
 6 files changed, 50 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cfdccdc..82528e0 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -439,6 +439,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		memset(&inode->i_atime, 0, sizeof(inode->i_atime));
 		memset(&inode->i_mtime, 0, sizeof(inode->i_mtime));
 		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
+		memset(&nfsi->timecreate, 0, sizeof(nfsi->timecreate));
 		inode->i_version = 0;
 		inode->i_size = 0;
 		clear_nlink(inode);
@@ -463,6 +464,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			inode->i_ctime = fattr->ctime;
 		else if (nfs_server_capable(inode, NFS_CAP_CTIME))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+		if (fattr->valid & NFS_ATTR_FATTR_TIME_CREATE)
+			nfsi->timecreate = fattr->time_create;
+		else if (nfs_server_capable(inode, NFS_CAP_TIME_CREATE))
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else
@@ -1764,6 +1769,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_TIME_CREATE) {
+		memcpy(&nfsi->timecreate, &fattr->time_create, sizeof(nfsi->timecreate));
+	} else if (server->caps & NFS_CAP_TIME_CREATE) {
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
index 122d2ba..2e45c10 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -187,6 +187,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD1_RAWDEV
 	| FATTR4_WORD1_SPACE_USED
 	| FATTR4_WORD1_TIME_ACCESS
+	| FATTR4_WORD1_TIME_CREATE
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
@@ -3073,6 +3074,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_CTIME;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_MODIFY)
 			server->caps |= NFS_CAP_MTIME;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_CREATE)
+			server->caps |= NFS_CAP_TIME_CREATE;
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
 			server->caps |= NFS_CAP_SECURITY_LABEL;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d5a5a32..bc0cfae 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4129,6 +4129,24 @@ static int decode_attr_time_access(struct xdr_stream *xdr, uint32_t *bitmap, str
 	return status;
 }
 
+static int decode_attr_time_create(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
+{
+	int status = 0;
+
+	time->tv_sec = 0;
+	time->tv_nsec = 0;
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_CREATE - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_TIME_CREATE)) {
+		status = decode_attr_time(xdr, time);
+		if (status == 0)
+			status = NFS_ATTR_FATTR_TIME_CREATE;
+		bitmap[1] &= ~FATTR4_WORD1_TIME_CREATE;
+	}
+	dprintk("%s: time_create=%ld\n", __func__, (long)time->tv_sec);
+	return status;
+}
+
 static int decode_attr_time_metadata(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
 {
 	int status = 0;
@@ -4646,6 +4664,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_time_create(xdr, bitmap, &fattr->time_create);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
+
 	status = decode_attr_time_metadata(xdr, bitmap, &fattr->ctime);
 	if (status < 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index eaeaca6..18d9535 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -131,6 +131,12 @@ struct nfs_inode {
 	unsigned long		cache_validity;		/* bit mask */
 
 	/*
+	 * NFS Attributes not included in struct inode
+	 */
+
+	struct timespec		timecreate;
+
+	/*
 	 * read_cache_jiffies is when we started read-caching this inode.
 	 * attrtimeo is for how long the cached information is assumed
 	 * to be valid. A successful attribute revalidation doubles
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 09b0352..7c1713c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -245,5 +245,6 @@ struct nfs_server {
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_ALLOW_ACLS	(1U << 24)
 #define NFS_CAP_DENY_ACLS	(1U << 25)
+#define NFS_CAP_TIME_CREATE	(1U << 26)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 74dbcb8..cc4a3f5 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -64,6 +64,7 @@ struct nfs_fattr {
 	struct timespec		atime;
 	struct timespec		mtime;
 	struct timespec		ctime;
+	struct timespec		time_create;
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	__u64			pre_size;	/* pre_op_attr.size	  */
@@ -102,6 +103,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_OWNER_NAME	(1U << 23)
 #define NFS_ATTR_FATTR_GROUP_NAME	(1U << 24)
 #define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 25)
+#define NFS_ATTR_FATTR_TIME_CREATE	(1U << 26)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -115,6 +117,7 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_ATIME \
 		| NFS_ATTR_FATTR_MTIME \
 		| NFS_ATTR_FATTR_CTIME \
+		| NFS_ATTR_FATTR_TIME_CREATE \
 		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
-- 
2.3.6

