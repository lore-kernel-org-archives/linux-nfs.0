Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:48767 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755230Ab1IMQRY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Sep 2011 12:17:24 -0400
Received: by gwb15 with SMTP id 15so667006gwb.19
        for <linux-nfs@vger.kernel.org>; Tue, 13 Sep 2011 09:17:24 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>, Benny Halevy <bhalevy@tonian.com>,
        Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
Date: Tue, 13 Sep 2011 09:16:26 -0700
Message-Id: <1315930586-2793-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Reported-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index cc78e62..66f2f73 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1009,17 +1009,20 @@ static int __init nfs4blocklayout_init(void)
 			      mnt,
 			      NFS_PIPE_DIRNAME, 0, &path);
 	if (ret)
-		goto out_stop;
+		goto out_putrpc;
 
 	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
 				    &bl_upcall_ops, 0);
+	path_put(&path);
 	if (IS_ERR(bl_device_pipe)) {
 		ret = PTR_ERR(bl_device_pipe);
-		goto out_stop;
+		goto out_putrpc;
 	}
 out:
 	return ret;
 
+out_putrpc:
+	rpc_put_mount();
 out_stop:
 	pnfsiod_stop();
 out_remove:
@@ -1035,6 +1038,7 @@ static void __exit nfs4blocklayout_exit(void)
 	pnfs_unregister_layoutdriver(&blocklayout_type);
 	pnfsiod_stop();
 	rpc_unlink(bl_device_pipe);
+	rpc_put_mount();
 }
 
 MODULE_ALIAS("nfs-layouttype4-3");
-- 
1.7.1.262.g5ef3d

