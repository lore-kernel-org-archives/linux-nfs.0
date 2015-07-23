Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35619 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbGWStH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:49:07 -0400
Received: by obbop1 with SMTP id op1so1359101obb.2
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2015 11:49:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFS: Remove the "NFS_CAP_CHANGE_ATTR" capability
Date: Thu, 23 Jul 2015 14:49:00 -0400
Message-Id: <1437677341-2943-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1437677341-2943-3-git-send-email-trond.myklebust@primarydata.com>
References: <1437677341-2943-1-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-2-git-send-email-trond.myklebust@primarydata.com>
 <1437677341-2943-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Setting the change attribute has been mandatory for all NFS versions, since
commit 3a1556e8662c ("NFSv2/v3: Simulate the change attribute"). We should
therefore not have anything be conditional on it being set/unset.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/client.c           | 2 +-
 fs/nfs/inode.c            | 4 ++--
 fs/nfs/nfs4proc.c         | 3 ---
 include/linux/nfs_fs_sb.h | 2 +-
 4 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ecebb406cc1a..4a90c9bb3135 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -775,7 +775,7 @@ static int nfs_init_server(struct nfs_server *server,
 	server->options = data->options;
 	server->caps |= NFS_CAP_HARDLINKS|NFS_CAP_SYMLINKS|NFS_CAP_FILEID|
 		NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|NFS_CAP_OWNER_GROUP|
-		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME|NFS_CAP_CHANGE_ATTR;
+		NFS_CAP_ATIME|NFS_CAP_CTIME|NFS_CAP_MTIME;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 426e4f8207ef..0adc7d245b3d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -442,7 +442,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR);
 		if (fattr->valid & NFS_ATTR_FATTR_CHANGE)
 			inode->i_version = fattr->change_attr;
-		else if (nfs_server_capable(inode, NFS_CAP_CHANGE_ATTR))
+		else
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_ATTR
 				| NFS_INO_REVAL_PAGECACHE);
 		if (fattr->valid & NFS_ATTR_FATTR_SIZE)
@@ -1692,7 +1692,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 			inode->i_version = fattr->change_attr;
 		}
-	} else if (server->caps & NFS_CAP_CHANGE_ATTR)
+	} else
 		nfsi->cache_validity |= save_cache_validity;
 
 	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9264994ec9d3..c85ffe67b5f3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8591,7 +8591,6 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.minor_version = 0,
 	.init_caps = NFS_CAP_READDIRPLUS
 		| NFS_CAP_ATOMIC_OPEN
-		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK,
 	.init_client = nfs40_init_client,
 	.shutdown_client = nfs40_shutdown_client,
@@ -8617,7 +8616,6 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.minor_version = 1,
 	.init_caps = NFS_CAP_READDIRPLUS
 		| NFS_CAP_ATOMIC_OPEN
-		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
@@ -8640,7 +8638,6 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.minor_version = 2,
 	.init_caps = NFS_CAP_READDIRPLUS
 		| NFS_CAP_ATOMIC_OPEN
-		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a2ea1491d3df..20bc8e51b161 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -220,7 +220,7 @@ struct nfs_server {
 #define NFS_CAP_SYMLINKS	(1U << 2)
 #define NFS_CAP_ACLS		(1U << 3)
 #define NFS_CAP_ATOMIC_OPEN	(1U << 4)
-#define NFS_CAP_CHANGE_ATTR	(1U << 5)
+/* #define NFS_CAP_CHANGE_ATTR	(1U << 5) */
 #define NFS_CAP_FILEID		(1U << 6)
 #define NFS_CAP_MODE		(1U << 7)
 #define NFS_CAP_NLINK		(1U << 8)
-- 
2.4.3

