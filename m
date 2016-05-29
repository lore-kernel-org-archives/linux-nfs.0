Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36343 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbcE2RPE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:04 -0400
Received: by mail-pf0-f194.google.com with SMTP id 62so7050702pfd.3
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:04 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 5/6] nfs:  Add timebackup to nfs inode, along with corresponding bitfields, request, and decode xdr routines.
Date: Sun, 29 May 2016 10:14:51 -0700
Message-Id: <1464542092-19605-6-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add xdr support for NFS attribute 'timebackup'.

This will permit the surfacing of this attribute for underlying filesystems that support it.

Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>
---
 fs/nfs/inode.c            | 14 ++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +++
 fs/nfs/nfs4xdr.c          | 23 +++++++++++++++++++++++
 include/linux/nfs_fs.h    |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  3 +++
 6 files changed, 45 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7a6ee66..e2e347f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -440,6 +440,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		memset(&inode->i_mtime, 0, sizeof(inode->i_mtime));
 		memset(&inode->i_ctime, 0, sizeof(inode->i_ctime));
 		memset(&nfsi->timecreate, 0, sizeof(nfsi->timecreate));
+		memset(&nfsi->timebackup, 0, sizeof(nfsi->timebackup));
 		nfsi->hidden = 0;
 		nfsi->system = 0;
 		nfsi->archive = 0;
@@ -483,6 +484,10 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			nfsi->archive = (fattr->hsa_flags & NFS_HSA_ARCHIVE) !=0;
 		else if (nfs_server_capable(inode, NFS_CAP_ARCHIVE))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
+		if (fattr->valid & NFS_ATTR_FATTR_TIME_BACKUP)
+			nfsi->timebackup = fattr->time_backup;
+		else if (nfs_server_capable(inode, NFS_CAP_TIME_BACKUP))
+			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
 		else
@@ -1820,6 +1825,15 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		cache_revalidated = false;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_TIME_BACKUP) {
+		memcpy(&nfsi->timebackup, &fattr->time_backup, sizeof(nfsi->timebackup));
+	} else if (server->caps & NFS_CAP_TIME_BACKUP) {
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
index 1d84b5c..2e148f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -191,6 +191,7 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_CREATE
 	| FATTR4_WORD1_SYSTEM
+	| FATTR4_WORD1_TIME_BACKUP
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
@@ -3085,6 +3086,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_TIME_CREATE;
 		if (res.attr_bitmask[1] & FATTR4_WORD1_SYSTEM)
 			server->caps |= NFS_CAP_SYSTEM;
+		if (res.attr_bitmask[1] & FATTR4_WORD1_TIME_BACKUP)
+			server->caps |= NFS_CAP_TIME_BACKUP;
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
 			server->caps |= NFS_CAP_SECURITY_LABEL;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d8328a5..d3ecb7e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4193,6 +4193,24 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_attr_time_backup(struct xdr_stream *xdr, uint32_t *bitmap, struct timespec *time)
+{
+	int status = 0;
+
+	time->tv_sec = 0;
+	time->tv_nsec = 0;
+	if (unlikely(bitmap[1] & (FATTR4_WORD1_TIME_BACKUP - 1U)))
+		return -EIO;
+	if (likely(bitmap[1] & FATTR4_WORD1_TIME_BACKUP)) {
+		status = decode_attr_time(xdr, time);
+		if (status == 0)
+			status = NFS_ATTR_FATTR_TIME_BACKUP;
+		bitmap[1] &= ~FATTR4_WORD1_TIME_BACKUP;
+	}
+	dprintk("%s: time_backup=%ld\n", __func__, (long)time->tv_sec);
+	return status;
+}
+
 static int decode_attr_archive(struct xdr_stream *xdr, uint32_t *bitmap, uint32_t *res)
 {
 	__be32 *p;
@@ -4748,6 +4766,11 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_time_backup(xdr, bitmap, &fattr->time_backup);
+	if (status < 0)
+		goto xdr_error;
+	fattr->valid |= status;
+
 	status = decode_attr_time_create(xdr, bitmap, &fattr->time_create);
 	if (status < 0)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 83c42f6..82eae20 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -135,6 +135,7 @@ struct nfs_inode {
 	 */
 
 	struct timespec		timecreate;
+	struct timespec		timebackup;
 	bool			hidden;
 	bool			system;
 	bool			archive;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3f972e7..256d37f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -249,5 +249,6 @@ struct nfs_server {
 #define NFS_CAP_HIDDEN          (1U << 27)
 #define NFS_CAP_SYSTEM          (1U << 28)
 #define NFS_CAP_ARCHIVE         (1U << 29)
+#define NFS_CAP_TIME_BACKUP     (1U << 30)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index de90f90..0fe5bdb 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -71,6 +71,7 @@ struct nfs_fattr {
 	struct timespec		ctime;
 	struct timespec		time_create;
 	__u32			hsa_flags;	/* hidden, system, archive flags bitfield */
+	struct timespec		time_backup;
 	__u64			change_attr;	/* NFSv4 change attribute */
 	__u64			pre_change_attr;/* pre-op NFSv4 change attribute */
 	__u64			pre_size;	/* pre_op_attr.size	  */
@@ -113,6 +114,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_HIDDEN           (1U << 27)
 #define NFS_ATTR_FATTR_SYSTEM           (1U << 28)
 #define NFS_ATTR_FATTR_ARCHIVE          (1U << 29)
+#define NFS_ATTR_FATTR_TIME_BACKUP      (1U << 30)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -130,6 +132,7 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_HIDDEN \
 		| NFS_ATTR_FATTR_SYSTEM \
 		| NFS_ATTR_FATTR_ARCHIVE \
+		| NFS_ATTR_FATTR_TIME_BACKUP \
 		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
-- 
2.3.6

