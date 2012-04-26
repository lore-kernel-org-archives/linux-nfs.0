Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:12976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968Ab2DZVDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 17:03:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/8] NFSv2/v3: Simulate the change attribute
Date: Thu, 26 Apr 2012 17:03:31 -0400
Message-Id: <1335474215-29127-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1335474215-29127-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-2-git-send-email-Trond.Myklebust@netapp.com>
 <1335474215-29127-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the ctime to simulate a change attribute for NFSv2 and NFSv3.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c         |    2 +-
 fs/nfs/nfs2xdr.c        |    2 ++
 fs/nfs/nfs3xdr.c        |    3 +++
 include/linux/nfs_xdr.h |    6 +++---
 4 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index da7b5e4..e258f97 100644
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
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1f56000..ae6b6a1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -313,6 +313,8 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_time(p, &fattr->atime);
 	p = xdr_decode_time(p, &fattr->mtime);
 	xdr_decode_time(p, &fattr->ctime);
+	fattr->change_attr = timespec_to_ns(&fattr->ctime);
+
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a77cc9a..a2ac4b8 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -675,6 +675,7 @@ static int decode_fattr3(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 	p = xdr_decode_nfstime3(p, &fattr->atime);
 	p = xdr_decode_nfstime3(p, &fattr->mtime);
 	xdr_decode_nfstime3(p, &fattr->ctime);
+	fattr->change_attr = timespec_to_ns(&fattr->ctime);
 
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
+	fattr->pre_change_attr = timespec_to_ns(&fattr->pre_ctime);
 
 	return 0;
 out_overflow:
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 536a2b4..1def5fe 100644
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

