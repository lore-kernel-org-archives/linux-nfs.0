Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950Ab2D1TbJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 15:31:09 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/10] NFSv2/v3: Simulate the change attribute
Date: Sat, 28 Apr 2012 15:30:55 -0400
Message-Id: <1335641460-24839-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335641460-24839-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1335641460-24839-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-3-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-4-git-send-email-Trond.Myklebust@netapp.com>
 <1335641460-24839-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the ctime to simulate a change attribute for NFSv2 and NFSv3.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c         |    2 +-
 fs/nfs/internal.h       |   12 ++++++++++++
 fs/nfs/nfs2xdr.c        |    2 ++
 fs/nfs/nfs3xdr.c        |    3 +++
 include/linux/nfs_xdr.h |    6 +++---
 5 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60f7e4e..a8f8de6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -880,7 +880,7 @@ static int nfs_init_server(struct nfs_server *server,
 	server->options = data->options;
 	server->caps |= NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
 		NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|NFS_CAP_OWNER_GROUP|
-		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME;
+		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME|NFS_CAP_CHANGE_ATTR;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0fd1efa..1855e8f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -493,3 +493,15 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
+/*
+ * Convert a struct timespec into a 64-bit change attribute
+ *
+ * This does approximately the same thing as timespec_to_ns(),
+ * but for calculation efficiency, we multiply the seconds by
+ * 1024*1024*1024.
+ */
+static inline
+u64 nfs_timespec_to_change_attr(const struct timespec *ts)
+{
+	return ((u64)ts->tv_sec << 30) + ts->tv_nsec;
+}
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f56000..c99008e 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -313,6 +313,8 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
 	xdr_decode_time(p, &fattr->ctime);
+	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
+
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 01e53e9..ee284c2 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -675,6 +675,7 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_nfstime3(p, &fattr->atime);
 	p = xdr_decode_nfstime3(p, &fattr->mtime);
 	xdr_decode_nfstime3(p, &fattr->ctime);
+	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
 
 	fattr->valid |= NFS_ATTR_FATTR_V3;
 	return 0;
@@ -725,12 +726,14 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 		goto out_overflow;
 
 	fattr->valid |= NFS_ATTR_FATTR_PRESIZE
+		| NFS_ATTR_FATTR_PRECHANGE
 		| NFS_ATTR_FATTR_PREMTIME
 		| NFS_ATTR_FATTR_PRECTIME;
 
 	p = xdr_decode_size3(p, &fattr->pre_size);
 	p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
 	xdr_decode_nfstime3(p, &fattr->pre_ctime);
+	fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);
 
 	return 0;
 out_overflow:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c940d46..cd160ab 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -106,14 +106,14 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_FILEID \
 		| NFS_ATTR_FATTR_ATIME \
 		| NFS_ATTR_FATTR_MTIME \
-		| NFS_ATTR_FATTR_CTIME)
+		| NFS_ATTR_FATTR_CTIME \
+		| NFS_ATTR_FATTR_CHANGE)
 #define NFS_ATTR_FATTR_V2 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_BLOCKS_USED)
 #define NFS_ATTR_FATTR_V3 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_SPACE_USED)
 #define NFS_ATTR_FATTR_V4 (NFS_ATTR_FATTR \
-		| NFS_ATTR_FATTR_SPACE_USED \
-		| NFS_ATTR_FATTR_CHANGE)
+		| NFS_ATTR_FATTR_SPACE_USED)
 
 /*
  * Info on the file system
-- 
1.7.7.6

