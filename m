Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:49971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756391Ab2GQTSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jul 2012 15:18:33 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, fengguang.wu@intel.com
Subject: [PATCH] NFS: exit_nfs_v4() shouldn't be an __exit function
Date: Tue, 17 Jul 2012 15:18:30 -0400
Message-Id: <1342552710-9752-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

... yet.  Right now, init_nfs() is calling this function if an error is
encountered when loading the nfs module.  An __exit function can't be
called from one declared as __init.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 2af2691..59264fb 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -352,7 +352,7 @@ out:
 	return err;
 }
 
-void __exit exit_nfs_v4(void)
+void exit_nfs_v4(void)
 {
 	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
-- 
1.7.11.2

