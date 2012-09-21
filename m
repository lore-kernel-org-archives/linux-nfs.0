Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48605 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757873Ab2IUUvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Sep 2012 16:51:17 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/26] NFSv4.1: Replace get_device_info() with filelayout_get_device_info()
Date: Fri, 21 Sep 2012 16:50:00 -0400
Message-Id: <1348260621-10294-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1348260621-10294-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348260621-10294-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the namespace pollution issue.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c | 2 +-
 fs/nfs/nfs4filelayout.c          | 2 +-
 fs/nfs/nfs4filelayout.h          | 2 +-
 fs/nfs/nfs4filelayoutdev.c       | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index dd392ed..329bfbf 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -874,7 +874,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
 	}
 }
 
-/* This is mostly copied from the filelayout's get_device_info function.
+/* This is mostly copied from the filelayout_get_device_info function.
  * It seems much of this should be at the generic pnfs level.
  */
 static struct pnfs_block_dev *
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 77cd115..af6ee4a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -608,7 +608,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	d = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode)->pnfs_curr_ld,
 				   NFS_SERVER(lo->plh_inode)->nfs_client, id);
 	if (d == NULL) {
-		dsaddr = get_device_info(lo->plh_inode, id, gfp_flags);
+		dsaddr = filelayout_get_device_info(lo->plh_inode, id, gfp_flags);
 		if (dsaddr == NULL)
 			goto out;
 	} else
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 43fe802..11053c4 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -158,7 +158,7 @@ struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
 extern void nfs4_fl_put_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 extern void nfs4_fl_free_deviceid(struct nfs4_file_layout_dsaddr *dsaddr);
 struct nfs4_file_layout_dsaddr *
-get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
+filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags);
 void nfs4_ds_disconnect(struct nfs_client *clp);
 
 #endif /* FS_NFS_NFS4FILELAYOUT_H */
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f81231f..b85a29d 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -690,7 +690,7 @@ decode_and_add_device(struct inode *inode, struct pnfs_device *dev, gfp_t gfp_fl
  * of available devices, and return it.
  */
 struct nfs4_file_layout_dsaddr *
-get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags)
+filelayout_get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_flags)
 {
 	struct pnfs_device *pdev = NULL;
 	u32 max_resp_sz;
-- 
1.7.11.4

