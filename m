Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752336AbaE2UlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 16:41:24 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Apply NFS_MOUNT_CMP_FLAGMASK to nfs_compare_remount_data()
Date: Thu, 29 May 2014 16:41:22 -0400
Message-Id: <1401396082-11862-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Those flags are obsolete and checking them can incorrectly cause
remount operations to fail.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2cb5694..1a6d7ac 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2180,11 +2180,23 @@ out_no_address:
 	return -EINVAL;
 }
 
+#define NFS_MOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
+		| NFS_MOUNT_SECURE \
+		| NFS_MOUNT_TCP \
+		| NFS_MOUNT_VER3 \
+		| NFS_MOUNT_KERBEROS \
+		| NFS_MOUNT_NONLM \
+		| NFS_MOUNT_BROKEN_SUID \
+		| NFS_MOUNT_STRICTLOCK \
+		| NFS_MOUNT_UNSHARED \
+		| NFS_MOUNT_NORESVPORT \
+		| NFS_MOUNT_LEGACY_INTERFACE)
+
 static int
 nfs_compare_remount_data(struct nfs_server *nfss,
 			 struct nfs_parsed_mount_data *data)
 {
-	if (data->flags != nfss->flags ||
+	if ((data->flags ^ nfss->flags) & NFS_MOUNT_CMP_FLAGMASK ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
 	    data->version != nfss->nfs_client->rpc_ops->version ||
@@ -2347,18 +2359,6 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
  	nfs_initialise_sb(sb);
 }
 
-#define NFS_MOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
-		| NFS_MOUNT_SECURE \
-		| NFS_MOUNT_TCP \
-		| NFS_MOUNT_VER3 \
-		| NFS_MOUNT_KERBEROS \
-		| NFS_MOUNT_NONLM \
-		| NFS_MOUNT_BROKEN_SUID \
-		| NFS_MOUNT_STRICTLOCK \
-		| NFS_MOUNT_UNSHARED \
-		| NFS_MOUNT_NORESVPORT \
-		| NFS_MOUNT_LEGACY_INTERFACE)
-
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
 {
 	const struct nfs_server *a = s->s_fs_info;
-- 
1.9.0

