Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:59280 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471Ab1IMUYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 16:24:14 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
Date: Tue, 13 Sep 2011 16:24:12 -0400
Message-Id: <1315945452-1575-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Reported-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/blocklayout/blocklayout.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9675ef9..8f97578 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1009,17 +1009,20 @@ static int __init nfs4blocklayout_init(void)
 			      mnt,
 			      NFS_PIPE_DIRNAME, 0, &path);
 	if (ret)
-		goto out_remove;
+		goto out_putrpc;
 
 	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
 				    &bl_upcall_ops, 0);
+	path_put(&path);
 	if (IS_ERR(bl_device_pipe)) {
 		ret = PTR_ERR(bl_device_pipe);
-		goto out_remove;
+		goto out_putrpc;
 	}
 out:
 	return ret;
 
+out_putrpc:
+	rpc_put_mount();
 out_remove:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 out_stop:
@@ -1035,6 +1038,7 @@ static void __exit nfs4blocklayout_exit(void)
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 	pnfsiod_stop();
 	rpc_unlink(bl_device_pipe);
+	rpc_put_mount();
 }
 
 MODULE_ALIAS("nfs-layouttype4-3");
-- 
1.7.4.1

