From: andros@netapp.com
Subject: [PATCH 06/13] SQUASHME pnfs_submit: update uninitialize_mountpoint
Date: Thu, 29 Apr 2010 16:34:44 -0400
Message-ID: <1272573291-8986-7-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757574Ab0D3Qsx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:53 -0400
In-Reply-To: <1272573291-8986-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The device id cache is now shared and moved to struct nfs_client. Change the
uninitialize_mountpoint parameter to be able to put the deviceid cache.

Cleanup unmount_pnfs_layoutdriver.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |   13 ++++++++-----
 fs/nfs/pnfs.c             |   12 +++---------
 fs/nfs/pnfs.h             |    2 +-
 fs/nfs/super.c            |    2 +-
 include/linux/nfs4_pnfs.h |    2 +-
 5 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9e81195..2c6b084 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -112,16 +112,19 @@ error_ret: ;
 /* Uninitialize a mountpoint by destroying its device list.
  */
 int
-filelayout_uninitialize_mountpoint(struct pnfs_mount_type *mountid)
+filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
 {
 	struct filelayout_mount_type *fl_mt = NULL;
 
 	dprintk("--> %s\n", __func__);
-	if (mountid) {
-		fl_mt = (struct filelayout_mount_type *)mountid->mountid;
-		nfs4_put_deviceid_cache(NFS_SB(fl_mt->fl_sb)->nfs_client);
+
+	if (nfss->pnfs_curr_ld && nfss->nfs_client->cl_devid_cache)
+		nfs4_put_deviceid_cache(nfss->nfs_client);
+	if (nfss->pnfs_mountid) {
+		fl_mt = (struct filelayout_mount_type *)
+						nfss->pnfs_mountid->mountid;
 		kfree(fl_mt);
-		kfree(mountid);
+		kfree(nfss->pnfs_mountid);
 	}
 	return 0;
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c80ccd2..859281f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -192,16 +192,10 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 
 /* Unitialize a mountpoint in a layout driver */
 void
-unmount_pnfs_layoutdriver(struct super_block *sb)
+unmount_pnfs_layoutdriver(struct nfs_server *nfss)
 {
-	struct nfs_server *server = NFS_SB(sb);
-	if (server->pnfs_curr_ld &&
-	    server->pnfs_curr_ld->ld_io_ops &&
-	    server->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint) {
-		server->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint(
-			server->pnfs_mountid);
-		server->pnfs_mountid = NULL;
-	    }
+	if (PNFS_EXISTS_LDIO_OP(nfss, uninitialize_mountpoint))
+		nfss->pnfs_curr_ld->ld_io_ops->uninitialize_mountpoint(nfss);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5745ee1..3761f48 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -39,7 +39,7 @@ int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type);
 void set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id);
-void unmount_pnfs_layoutdriver(struct super_block *sb);
+void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_use_read(struct inode *inode, ssize_t count);
 int pnfs_use_ds_io(struct list_head *, struct inode *, int);
 int pnfs_use_write(struct inode *inode, ssize_t count);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6155d69..021683d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2833,7 +2833,7 @@ static void nfs4_kill_super(struct super_block *sb)
 	nfs_super_return_all_delegations(sb);
 	kill_anon_super(sb);
 #ifdef CONFIG_NFS_V4_1
-	unmount_pnfs_layoutdriver(sb);
+	unmount_pnfs_layoutdriver(server);
 #endif
 	nfs_fscache_release_super_cookie(sb);
 	nfs_free_server(server);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index f0eddbd..2e86c66 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -182,7 +182,7 @@ struct layoutdriver_io_operations {
 	/* Registration information for a new mounted file system
 	 */
 	struct pnfs_mount_type * (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
-	int (*uninitialize_mountpoint) (struct pnfs_mount_type *mountid);
+	int (*uninitialize_mountpoint) (struct nfs_server *server);
 };
 
 enum layoutdriver_policy_flags {
-- 
1.6.6

