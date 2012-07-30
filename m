Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50661 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284Ab2G3UFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 02/10] NFS: Remove the NFS v4 xdev mount function
Date: Mon, 30 Jul 2012 16:05:17 -0400
Message-Id: <1343678725-8659-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I can now share this code with the v2 and v3 code by using the NFS
subversion structure.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/namespace.c | 13 -------------
 fs/nfs/nfs4super.c | 25 -------------------------
 fs/nfs/super.c     | 30 ++++++++++--------------------
 3 files changed, 10 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 08b9c93..0f699fe 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -195,20 +195,7 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
 					   const char *devname,
 					   struct nfs_clone_mount *mountdata)
 {
-#ifdef CONFIG_NFS_V4
-	struct vfsmount *mnt = ERR_PTR(-EINVAL);
-	switch (server->nfs_client->rpc_ops->version) {
-		case 2:
-		case 3:
-			mnt = vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
-			break;
-		case 4:
-			mnt = vfs_kern_mount(&nfs4_xdev_fs_type, 0, devname, mountdata);
-	}
-	return mnt;
-#else
 	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
-#endif
 }
 
 /**
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 1f34019..8a50557 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -14,8 +14,6 @@
 
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_xdev_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
@@ -37,14 +35,6 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
 
-struct file_system_type nfs4_xdev_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_xdev_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
-};
-
 static struct file_system_type nfs4_remote_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
@@ -261,21 +251,6 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	return res;
 }
 
-/*
- * Clone an NFS4 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
-		 const char *dev_name, void *raw_data)
-{
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_clone_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned = raw_data,
-	};
-	return nfs_xdev_mount_common(&nfs4_fs_type, flags, dev_name, &mount_info);
-}
-
 static struct dentry *
 nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 			   const char *dev_name, void *raw_data)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 61405a7..4faefa1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2445,10 +2445,15 @@ void nfs_kill_super(struct super_block *s)
  * Clone an NFS2/3/4 server record on xdev traversal (FSID-change)
  */
 struct dentry *
-nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
-		const char *dev_name, struct nfs_mount_info *mount_info)
+nfs_xdev_mount(struct file_system_type *fs_type, int flags,
+		const char *dev_name, void *raw_data)
 {
-	struct nfs_clone_mount *data = mount_info->cloned;
+	struct nfs_clone_mount *data = raw_data;
+	struct nfs_mount_info mount_info = {
+		.fill_super = nfs_clone_super,
+		.set_security = nfs_clone_sb_security,
+		.cloned = data,
+	};
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
@@ -2456,7 +2461,7 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 
 	dprintk("--> nfs_xdev_mount_common()\n");
 
-	mount_info->mntfh = data->fh;
+	mount_info.mntfh = mount_info.cloned->fh;
 
 	/* create a new volume representation */
 	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
@@ -2465,7 +2470,7 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		goto out_err;
 	}
 
-	mntroot = nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
+	mntroot = nfs_fs_mount_common(server, flags, dev_name, &mount_info, nfs_mod);
 	dprintk("<-- nfs_xdev_mount_common() = 0\n");
 out:
 	return mntroot;
@@ -2475,21 +2480,6 @@ out_err:
 	goto out;
 }
 
-/*
- * Clone an NFS2/3 server record on xdev traversal (FSID-change)
- */
-static struct dentry *
-nfs_xdev_mount(struct file_system_type *fs_type, int flags,
-		const char *dev_name, void *raw_data)
-{
-	struct nfs_mount_info mount_info = {
-		.fill_super = nfs_clone_super,
-		.set_security = nfs_clone_sb_security,
-		.cloned   = raw_data,
-	};
-	return nfs_xdev_mount_common(&nfs_fs_type, flags, dev_name, &mount_info);
-}
-
 #ifdef CONFIG_NFS_V4
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
-- 
1.7.11.3

