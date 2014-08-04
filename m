Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbaHDVhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 17:37:32 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: reject changes to resvport and sharecache during remount
Date: Mon,  4 Aug 2014 17:37:27 -0400
Message-Id: <1407188247-3050-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c8e47028 made it possible to change resvport/noresvport and
sharecache/nosharecache via a remount operation, neither of which should be
allowed.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 084af10..3fd8332 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2180,7 +2180,7 @@ out_no_address:
 	return -EINVAL;
 }
 
-#define NFS_MOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
+#define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
 		| NFS_MOUNT_SECURE \
 		| NFS_MOUNT_TCP \
 		| NFS_MOUNT_VER3 \
@@ -2188,15 +2188,16 @@ out_no_address:
 		| NFS_MOUNT_NONLM \
 		| NFS_MOUNT_BROKEN_SUID \
 		| NFS_MOUNT_STRICTLOCK \
-		| NFS_MOUNT_UNSHARED \
-		| NFS_MOUNT_NORESVPORT \
 		| NFS_MOUNT_LEGACY_INTERFACE)
 
+#define NFS_MOUNT_CMP_FLAGMASK (NFS_REMOUNT_CMP_FLAGMASK & \
+		~(NFS_MOUNT_UNSHARED | NFS_MOUNT_NORESVPORT))
+
 static int
 nfs_compare_remount_data(struct nfs_server *nfss,
 			 struct nfs_parsed_mount_data *data)
 {
-	if ((data->flags ^ nfss->flags) & NFS_MOUNT_CMP_FLAGMASK ||
+	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
 	    data->version != nfss->nfs_client->rpc_ops->version ||
-- 
1.9.3

