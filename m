From: andros@netapp.com
Subject: [PATCH 06/13] SQUASHME pnfs_submit: remove uninitialize_mountpoint
Date: Wed, 28 Apr 2010 18:24:18 -0400
Message-ID: <1272493465-3398-7-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
 <1272493465-3398-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14209 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932230Ab0D1VYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:34 -0400
In-Reply-To: <1272493465-3398-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The layoutdriver_io_operations uninitialize_mountpoint function is used
to free a layout driver specific device id cache.
The device id cache is now shared and moved to struct nfs_client and can be
removed in the generic unmount_pnfs_layoutdriver routine.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |   18 ------------------
 fs/nfs/pnfs.c             |   11 +++--------
 include/linux/nfs4_pnfs.h |    1 -
 3 files changed, 3 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9e81195..8d6f685 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -109,23 +109,6 @@ error_ret: ;
 	return NULL;
 }
 
-/* Uninitialize a mountpoint by destroying its device list.
- */
-int
-filelayout_uninitialize_mountpoint(struct pnfs_mount_type *mountid)
-{
-	struct filelayout_mount_type *fl_mt = NULL;
-
-	dprintk("--> %s\n", __func__);
-	if (mountid) {
-		fl_mt = (struct filelayout_mount_type *)mountid->mountid;
-		nfs4_put_deviceid_cache(NFS_SB(fl_mt->fl_sb)->nfs_client);
-		kfree(fl_mt);
-		kfree(mountid);
-	}
-	return 0;
-}
-
 /* This function is used by the layout driver to calculate the
  * offset of the file on the dserver based on whether the
  * layout type is STRIPE_DENSE or STRIPE_SPARSE
@@ -782,7 +765,6 @@ struct layoutdriver_io_operations filelayout_io_operations = {
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
 	.initialize_mountpoint   = filelayout_initialize_mountpoint,
-	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
 };
 
 struct layoutdriver_policy_operations filelayout_policy_operations = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 83e8448..0e03259 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -194,14 +194,9 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 void
 unmount_pnfs_layoutdriver(struct super_block *sb)
 {
-	struct nfs_server *server = NFS_SB(sb);
-	if (server->pnfs_curr_ld &&
-	    server->pnfs_curr_ld->ld_io_ops &&
-	    server->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint) {
-		server->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint(
-			server->pnfs_mountid);
-		server->pnfs_mountid = NULL;
-	    }
+	if (NFS_SB(sb)->pnfs_curr_ld && NFS_SB(sb)->nfs_client->cl_devid_cache)
+		nfs4_put_deviceid_cache(NFS_SB(sb)->nfs_client);
+	NFS_SB(sb)->pnfs_curr_ld = NULL;
 }
 
 /*
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index f0eddbd..4fdf87e 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -182,7 +182,6 @@ struct layoutdriver_io_operations {
 	/* Registration information for a new mounted file system
 	 */
 	struct pnfs_mount_type * (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
-	int (*uninitialize_mountpoint) (struct pnfs_mount_type *mountid);
 };
 
 enum layoutdriver_policy_flags {
-- 
1.6.6

