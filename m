Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754Ab2AMULY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:24 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 25/44] NFS: Create a custom validate_mount_data() function
Date: Fri, 13 Jan 2012 15:10:34 -0500
Message-Id: <1326485453-1350-26-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 the opportunity to validate its own options while v2 and
v3 share the same validation function.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |    1 +
 fs/nfs/nfs.h         |    7 +++++++
 fs/nfs/nfs2/module.c |    1 +
 fs/nfs/nfs3/module.c |    1 +
 fs/nfs/nfs4/nfs4.h   |    2 ++
 fs/nfs/super.c       |   28 +++++++++++-----------------
 6 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 60d0f57..998c3be 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -136,6 +136,7 @@ static struct nfs_subversion nfs_v4_mod = {
 
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
+	.validate_mount_data = nfs4_validate_text_mount_data,
 	.init_aclclient = nfs4_init_aclclient,
 	.try_mount = nfs4_try_mount,
 	.shutdown_client = nfs4_shutdown_client,
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 847f593..3aa900d 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -22,6 +22,10 @@ struct nfs_subversion {
 
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
+	int (*validate_mount_data)(void *,
+				   struct nfs_parsed_mount_data *,
+				   struct nfs_fh *,
+				   const char *);
 	void (*init_aclclient)(struct nfs_server *);
 	struct dentry *(*try_mount)(struct file_system_type *, int,
 				    const char *, struct nfs_fh *,
@@ -96,4 +100,7 @@ struct vfsmount *nfs_do_clone_mount(struct nfs_server *, const char *,
 struct dentry *generic_nfs_fs_mount(struct file_system_type *, int,
 				    const char *, struct nfs_fh *,
 				    struct nfs_parsed_mount_data *);
+int nfs_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
+				 struct nfs_fh *, const char *);
+
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 9bc06ab..5efe3d8 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -40,6 +40,7 @@ struct nfs_subversion nfs_v2 = {
 
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
+	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs2_init_aclclient,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs2_shutdown_client,
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 3ca0066..f9c979f 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -40,6 +40,7 @@ struct nfs_subversion nfs_v3 = {
 
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
+	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs3_init_aclclient,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs3_shutdown_client,
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 2428896..6ff094f 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -12,5 +12,7 @@ struct vfsmount *nfs4_do_clone_mount(struct nfs_server *, const char *,
 int nfs4_have_delegated_attributes(struct inode *);
 struct dentry *nfs4_try_mount(struct file_system_type *, int, const char *,
 			      struct nfs_fh *, struct nfs_parsed_mount_data *);
+int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
+				  struct nfs_fh *, const char *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b5ffc6a..e1ea351 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -309,8 +309,6 @@ static const struct super_operations nfs_sops = {
 };
 
 #ifdef CONFIG_NFS_V4
-static int nfs4_validate_text_mount_data(void *options,
-	struct nfs_parsed_mount_data *args, const char *dev_name);
 static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
@@ -1767,6 +1765,7 @@ int nfs_validate_text_mount_data(void *options,
 
 	return status;
 }
+EXPORT_SYMBOL_GPL(nfs_validate_text_mount_data);
 
 /*
  * Validate the NFS2/NFS3 mount data
@@ -1791,6 +1790,7 @@ static int nfs_validate_mount_data(void *options,
 {
 	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+	struct nfs_subversion *nfs_mod;
 
 	if (data == NULL)
 		goto out_no_data;
@@ -1899,17 +1899,10 @@ static int nfs_validate_mount_data(void *options,
 		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
-		if (args->version == 4)
-#ifdef CONFIG_NFS_V4
-			return nfs4_validate_text_mount_data(options,
-							     args, dev_name);
-#else
-			goto out_v4_not_compiled;
-#endif
-		else
-			return nfs_validate_text_mount_data(options, args, mntfh, dev_name);
-
-		break;
+		nfs_mod = get_nfs_version(args->version);
+		if (IS_ERR(nfs_mod))
+			return PTR_ERR(nfs_mod);
+		return nfs_mod->validate_mount_data(options, args, mntfh, dev_name);
 		}
 	}
 
@@ -2504,9 +2497,10 @@ static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 			 NFS_MOUNT_LOCAL_FLOCK|NFS_MOUNT_LOCAL_FCNTL);
 }
 
-static int nfs4_validate_text_mount_data(void *options,
-					 struct nfs_parsed_mount_data *args,
-					 const char *dev_name)
+int nfs4_validate_text_mount_data(void *options,
+				  struct nfs_parsed_mount_data *args,
+				  struct nfs_fh *mntfh,
+				  const char *dev_name)
 {
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 
@@ -2617,7 +2611,7 @@ static int nfs4_validate_mount_data(void *options,
 		if (!nfs_verify_server_address(sap))
 			return -EINVAL;
 
-		return nfs4_validate_text_mount_data(options, args, dev_name);
+		return nfs4_validate_text_mount_data(options, args, NULL, dev_name);
 	}
 
 	return 0;
-- 
1.7.8.3

