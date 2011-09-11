Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:62036 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab1IKPb4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 11:31:56 -0400
Received: by mail-pz0-f42.google.com with SMTP id 37so5445781pzk.1
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2011 08:31:56 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Jim Rees <rees@umich.edu>, Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 2/2] SQUASHME: pnfs: do pnfsiod_start before registering layout drivers
Date: Sun, 11 Sep 2011 08:31:52 -0700
Message-Id: <1315755112-31248-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E6CD076.6050607@tonian.com>
References: <4E6CD076.6050607@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |   16 ++++++++--------
 fs/nfs/objlayout/objio_osd.c     |   12 ++++++------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 51f70f0..77bb3e7 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -977,41 +977,41 @@ static int __init nfs4blocklayout_init(void)
 
 	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);
 
-	ret = pnfs_register_layoutdriver(&blocklayout_type);
+	ret = pnfsiod_start();
 	if (ret)
 		goto out;
 
-	ret = pnfsiod_start();
+	ret = pnfs_register_layoutdriver(&blocklayout_type);
 	if (ret)
-		goto out_remove;
+		goto out_stop;
 
 	init_waitqueue_head(&bl_wq);
 
 	mnt = rpc_get_mount();
 	if (IS_ERR(mnt)) {
 		ret = PTR_ERR(mnt);
-		goto out_stop;
+		goto out_remove;
 	}
 
 	ret = vfs_path_lookup(mnt->mnt_root,
 			      mnt,
 			      NFS_PIPE_DIRNAME, 0, &path);
 	if (ret)
-		goto out_stop;
+		goto out_remove;
 
 	bl_device_pipe = rpc_mkpipe(path.dentry, "blocklayout", NULL,
 				    &bl_upcall_ops, 0);
 	if (IS_ERR(bl_device_pipe)) {
 		ret = PTR_ERR(bl_device_pipe);
-		goto out_stop;
+		goto out_remove;
 	}
 out:
 	return ret;
 
-out_stop:
-	pnfsiod_stop();
 out_remove:
 	pnfs_unregister_layoutdriver(&blocklayout_type);
+out_stop:
+	pnfsiod_stop();
 	return ret;
 }
 
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index f28013f..7e8f0cc 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1041,15 +1041,15 @@ MODULE_LICENSE("GPL");
 static int __init
 objlayout_init(void)
 {
-	int ret = pnfs_register_layoutdriver(&objlayout_type);
-	if (ret)
-		goto out;
+	int ret;
 
 	ret = pnfsiod_start();
-	if (ret)
-		pnfs_unregister_layoutdriver(&objlayout_type);
+	if (!ret) {
+		ret = pnfs_register_layoutdriver(&objlayout_type);
+		if (ret)
+			pnfsiod_stop();
+	}
 
-out:
 	if (ret)
 		printk(KERN_INFO
 			"%s: Registering OSD pNFS Layout Driver failed: error=%d\n",
-- 
1.7.6

