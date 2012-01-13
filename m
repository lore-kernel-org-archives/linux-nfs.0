Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932752Ab2AMULX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:23 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 23/44] NFS: Create a custom try_mount() function for each version
Date: Fri, 13 Jan 2012 15:10:32 -0500
Message-Id: <1326485453-1350-24-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This makes it easier for v2 and 3 to share the same code and for v4 to
do its own thing.

Signed-off-by: Bryan Schumaker <bjschuma@gmail.com>
---
 fs/nfs/client.c      |    1 +
 fs/nfs/nfs.h         |    8 ++++++++
 fs/nfs/nfs2/module.c |    1 +
 fs/nfs/nfs3/module.c |    1 +
 fs/nfs/nfs4/nfs4.h   |    2 ++
 fs/nfs/super.c       |   19 +++++++------------
 6 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d7470fa..60d0f57 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -137,6 +137,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
+	.try_mount = nfs4_try_mount,
 	.shutdown_client = nfs4_shutdown_client,
 	.have_delegation = nfs4_have_delegation,
 	.have_delegated_attributes = nfs4_have_delegated_attributes,
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 987656f..847f593 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -12,6 +12,7 @@
 #include <linux/nfs_xdr.h>
 
 struct nfs_clone_mount;
+struct nfs_parsed_mount_data;
 
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
@@ -22,6 +23,9 @@ struct nfs_subversion {
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
 	void (*init_aclclient)(struct nfs_server *);
+	struct dentry *(*try_mount)(struct file_system_type *, int,
+				    const char *, struct nfs_fh *,
+				    struct nfs_parsed_mount_data *);
 	void (*shutdown_client)(struct nfs_client *);
 	int (*have_delegation)(struct inode *, fmode_t);
 	int (*have_delegated_attributes)(struct inode *);
@@ -88,4 +92,8 @@ struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 struct vfsmount *nfs_do_clone_mount(struct nfs_server *, const char *,
 				    struct nfs_clone_mount *);
 
+/* Exported in super.c */
+struct dentry *generic_nfs_fs_mount(struct file_system_type *, int,
+				    const char *, struct nfs_fh *,
+				    struct nfs_parsed_mount_data *);
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 7c29b04..9bc06ab 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -41,6 +41,7 @@ struct nfs_subversion nfs_v2 = {
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
+	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs2_shutdown_client,
 	.have_delegation = nfs2_no_delegation,
 	.have_delegated_attributes = nfs2_no_delegation2,
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 6293bf7..3ca0066 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -41,6 +41,7 @@ struct nfs_subversion nfs_v3 = {
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
+	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs3_shutdown_client,
 	.have_delegation = nfs3_no_delegation,
 	.have_delegated_attributes = nfs3_no_delegation2,
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 97ff8d8..2428896 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -10,5 +10,7 @@ struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
 struct vfsmount *nfs4_do_clone_mount(struct nfs_server *, const char *,
 				     struct nfs_clone_mount *);
 int nfs4_have_delegated_attributes(struct inode *);
+struct dentry *nfs4_try_mount(struct file_system_type *, int, const char *,
+			      struct nfs_fh *, struct nfs_parsed_mount_data *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 60d065f..861d31e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -57,6 +57,7 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
+#include "nfs4/nfs4.h"
 #include "nfs4/nfs4_fs.h"
 #include "nfs4/callback.h"
 #include "nfs4/delegation.h"
@@ -310,8 +311,6 @@ static const struct super_operations nfs_sops = {
 #ifdef CONFIG_NFS_V4
 static int nfs4_validate_text_mount_data(void *options,
 	struct nfs_parsed_mount_data *args, const char *dev_name);
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-	struct nfs_parsed_mount_data *data);
 static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
@@ -2298,6 +2297,7 @@ error_splat_bdi:
 	goto out;
 
 }
+EXPORT_SYMBOL_GPL(generic_nfs_fs_mount);
 
 static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
@@ -2326,13 +2326,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		goto out;
 	}
 
-#ifdef CONFIG_NFS_V4
-	if (data->version == 4)
-		mntroot = nfs4_try_mount(flags, dev_name, data);
-	else
-#endif	/* CONFIG_NFS_V4 */
-		mntroot = generic_nfs_fs_mount(fs_type, flags, dev_name, mntfh, data);
-
+	mntroot = nfs_mod->try_mount(fs_type, flags, dev_name, mntfh, data);
 	if (!IS_ERR(mntroot))
 		nfs_mod->reference();
 
@@ -2829,8 +2823,9 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 	return dentry;
 }
 
-static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			 struct nfs_parsed_mount_data *data)
+struct dentry *nfs4_try_mount(struct file_system_type *fs_type, int flags,
+			      const char *dev_name, struct nfs_fh *mntfh,
+			      struct nfs_parsed_mount_data *data)
 {
 	char *export_path;
 	struct vfsmount *root_mnt;
@@ -2875,7 +2870,7 @@ static struct dentry *nfs4_mount(struct file_system_type *fs_type,
 		goto out;
 	}
 
-	res = nfs4_try_mount(flags, dev_name, data);
+	res = nfs4_try_mount(fs_type, flags, dev_name, NULL, data);
 	if (IS_ERR(res))
 		error = PTR_ERR(res);
 
-- 
1.7.8.3

