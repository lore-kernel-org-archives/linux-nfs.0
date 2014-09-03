Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17054 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbaICQTQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 12:19:16 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] NFS: Remove v3 not compiled check from validate_mount_data()
Date: Wed, 3 Sep 2014 12:19:09 -0400
Message-ID: <1409761150-30257-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409761150-30257-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This check is already performed by the module loading code - if the
module can't be found then -EPROTONOSUPPORT will be returned.  Let's
handle v3 this way, too.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/super.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e4499d5..31a11b0 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2065,11 +2065,6 @@ static int nfs23_validate_mount_data(void *options,
 		return NFS_TEXT_DATA;
 	}
 
-#if !IS_ENABLED(CONFIG_NFS_V3)
-	if (args->version == 3)
-		goto out_v3_not_compiled;
-#endif /* !CONFIG_NFS_V3 */
-
 	return 0;
 
 out_no_data:
@@ -2085,12 +2080,6 @@ out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
 	return -EINVAL;
 
-#if !IS_ENABLED(CONFIG_NFS_V3)
-out_v3_not_compiled:
-	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
-	return -EPROTONOSUPPORT;
-#endif /* !CONFIG_NFS_V3 */
-
 out_nomem:
 	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
 	return -ENOMEM;
-- 
2.1.0

