Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:28800 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760035Ab2EJPUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 11:20:38 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v3 04/14] NFS: Remove NFS4_MOUNT_UNSHARED
Date: Thu, 10 May 2012 11:19:55 -0400
Message-Id: <1336663205-23886-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
References: <1336663205-23886-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This flag is numerically equivalent to NFS_MOUNT_UNSHARED, so I can
remove it to make collapsing functions more straightforward.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

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
-- 
1.7.10.1

