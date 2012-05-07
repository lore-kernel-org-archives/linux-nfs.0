Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37427 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757373Ab2EGSmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 May 2012 14:42:53 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2 4/8] NFS: Remove NFS4_MOUNT_UNSHARED
Date: Mon,  7 May 2012 14:42:42 -0400
Message-Id: <1336416166-20533-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336416166-20533-1-git-send-email-bjschuma@netapp.com>
References: <1336416166-20533-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This flag is numerically equivalent to NFS_MOUNT_UNSHARED, so I can
remove it to make collapsing functions more straightforward.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c             |    6 +++---
 include/linux/nfs4_mount.h |    1 -
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f56fb35..40d43e0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2719,7 +2719,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	}
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS4_MOUNT_UNSHARED)
+	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
@@ -2983,7 +2983,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	}
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS4_MOUNT_UNSHARED)
+	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
@@ -3074,7 +3074,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 	}
 	sb_mntdata.server = server;
 
-	if (server->flags & NFS4_MOUNT_UNSHARED)
+	if (server->flags & NFS_MOUNT_UNSHARED)
 		compare_super = NULL;
 
 	/* -o noac implies -o sync */
diff --git a/include/linux/nfs4_mount.h b/include/linux/nfs4_mount.h
index a0dcf66..a89ad72 100644
--- a/include/linux/nfs4_mount.h
+++ b/include/linux/nfs4_mount.h
@@ -65,7 +65,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
 #define NFS4_MOUNT_NOAC		0x0020	/* 1 */
 #define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
-#define NFS4_MOUNT_UNSHARED	0x8000	/* 1 */
 #define NFS4_MOUNT_FLAGMASK	0x9033
 
 #endif
-- 
1.7.10.1

