Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932432AbaE2RZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 13:25:54 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] nfs: Ensure NFS_MOUNT_TCP is correctly set for v4 mounts
Date: Thu, 29 May 2014 13:25:51 -0400
Message-Id: <1401384351-21993-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1401384351-21993-1-git-send-email-smayhew@redhat.com>
References: <1401384351-21993-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS_MOUNT_TCP flag needs to be correctly set in the nfs_server->flags
field, otherwise remount operations are likely to run afoul of the flags
check in nfs_compare_remount_data() on systems where /etc/mtab is
symlinked to /proc/mounts.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2cb5694..0ae4e73 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2726,6 +2726,9 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
 	args->flags &= ~(NFS_MOUNT_NONLM|NFS_MOUNT_NOACL|NFS_MOUNT_VER3|
 			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
+
+	if (args->nfs_server.protocol == XPRT_TRANSPORT_TCP)
+		args->flags |= NFS_MOUNT_TCP;
 }
 
 /*
-- 
1.9.0

