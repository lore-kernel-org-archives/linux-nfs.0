From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-submit: pass struct nfs_server * to getdeviceinfo
Date: Thu,  6 May 2010 22:23:06 +0300
Message-ID: <1273173786-27677-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:13969 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755077Ab0EFTXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:23:10 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 fs/nfs/nfs4proc.c          |    3 +--
 fs/nfs/pnfs.h              |    2 +-
 include/linux/nfs4_pnfs.h  |    2 +-
 4 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 4b2b8ac..462f6de 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -518,7 +518,7 @@ get_device_info(struct inode *inode, struct pnfs_deviceid *dev_id)
 	/* TODO: Update types when CB_NOTIFY_DEVICEID is available */
 	pdev->dev_notify_types = 0;
 
-	rc = pnfs_callback_ops->nfs_getdeviceinfo(inode->i_sb, pdev);
+	rc = pnfs_callback_ops->nfs_getdeviceinfo(server, pdev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 43dab3c..dd2e6cf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5767,9 +5767,8 @@ out:
 	return status;
 }
 
-int nfs4_pnfs_getdeviceinfo(struct super_block *sb, struct pnfs_device *pdev)
+int nfs4_pnfs_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
-	struct nfs_server *server = NFS_SB(sb);
 	struct nfs4_pnfs_getdeviceinfo_arg args = {
 		.pdev = pdev,
 	};
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c5e042b..b80157b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -22,7 +22,7 @@
 #include "iostat.h"
 
 /* nfs4proc.c */
-extern int nfs4_pnfs_getdeviceinfo(struct super_block *sb,
+extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 extern int pnfs4_proc_layoutget(struct nfs4_pnfs_layoutget *lgp);
 extern int pnfs4_proc_layoutcommit(struct pnfs_layoutcommit_data *data);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 723706c..d9631de 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -293,7 +293,7 @@ extern void nfs4_unset_layout_deviceid(struct pnfs_layout_segment *,
  * E.g., getdeviceinfo, I/O callbacks, etc
  */
 struct pnfs_client_operations {
-	int (*nfs_getdeviceinfo) (struct super_block *sb,
+	int (*nfs_getdeviceinfo) (struct nfs_server *,
 				  struct pnfs_device *dev);
 
 	/* Post read callback. */
-- 
1.6.5.1

