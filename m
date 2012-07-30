Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623Ab2G3UFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 03/10] NFS: Create a try_mount rpc op
Date: Mon, 30 Jul 2012 16:05:18 -0400
Message-Id: <1343678725-8659-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I'm already looking up the nfs subversion in nfs_fs_mount(), so I have
easy access to rpc_ops that used to be difficult to reach.  This allows
me to set up a different mount path for NFS v2/3 and NFS v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |  2 ++
 fs/nfs/nfs3proc.c       |  1 +
 fs/nfs/nfs4_fs.h        |  2 +-
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/nfs4super.c      |  3 ++-
 fs/nfs/proc.c           |  1 +
 fs/nfs/super.c          | 14 ++++----------
 include/linux/nfs_xdr.h |  4 ++++
 8 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ac93647..3364ecc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -328,6 +328,8 @@ extern struct file_system_type nfs_xdev_fs_type;
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
+struct dentry *nfs_try_mount(int, const char *, struct nfs_mount_info *,
+			struct nfs_subversion *);
 void nfs_initialise_sb(struct super_block *);
 int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
 int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 65d23eb..4f4cb8e 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -925,6 +925,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs3_proc_get_root,
 	.submount	= nfs_submount,
+	.try_mount	= nfs_try_mount,
 	.getattr	= nfs3_proc_getattr,
 	.setattr	= nfs3_proc_setattr,
 	.lookup		= nfs3_proc_lookup,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 005558a..290762f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -367,7 +367,7 @@ extern const nfs4_stateid zero_stateid;
 /* nfs4super.c */
 struct nfs_mount_info;
 extern struct nfs_subversion nfs_v4;
-struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *);
+struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *, struct nfs_subversion *);
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5e373c3..ac78df9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6870,6 +6870,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.file_ops	= &nfs4_file_operations,
 	.getroot	= nfs4_proc_get_root,
 	.submount	= nfs4_submount,
+	.try_mount	= nfs4_try_mount,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
 	.lookup		= nfs4_proc_lookup,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 8a50557..9384f66 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -226,7 +226,8 @@ static struct dentry *nfs_follow_remote_path(struct vfsmount *root_mnt,
 }
 
 struct dentry *nfs4_try_mount(int flags, const char *dev_name,
-			 struct nfs_mount_info *mount_info)
+			      struct nfs_mount_info *mount_info,
+			      struct nfs_subversion *nfs_mod)
 {
 	char *export_path;
 	struct vfsmount *root_mnt;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4d3356af..ebb3d9c 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -774,6 +774,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_ops	= &nfs_file_operations,
 	.getroot	= nfs_proc_get_root,
 	.submount	= nfs_submount,
+	.try_mount	= nfs_try_mount,
 	.getattr	= nfs_proc_getattr,
 	.setattr	= nfs_proc_setattr,
 	.lookup		= nfs_proc_lookup,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4faefa1..5fca59d7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1650,9 +1650,9 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 	return nfs_walk_authlist(args, &request);
 }
 
-static struct dentry *nfs_try_mount(int flags, const char *dev_name,
-				    struct nfs_mount_info *mount_info,
-				    struct nfs_subversion *nfs_mod)
+struct dentry *nfs_try_mount(int flags, const char *dev_name,
+			     struct nfs_mount_info *mount_info,
+			     struct nfs_subversion *nfs_mod)
 {
 	int status;
 	struct nfs_server *server;
@@ -2403,15 +2403,9 @@ struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		goto out;
 	}
 
-#ifdef CONFIG_NFS_V4
-	if (mount_info.parsed->version == 4)
-		mntroot = nfs4_try_mount(flags, dev_name, &mount_info);
-	else
-#endif	/* CONFIG_NFS_V4 */
-		mntroot = nfs_try_mount(flags, dev_name, &mount_info, nfs_mod);
+	mntroot = nfs_mod->rpc_ops->try_mount(flags, dev_name, &mount_info, nfs_mod);
 
 	put_nfs_version(nfs_mod);
-
 out:
 	nfs_free_parsed_mount_data(mount_info.parsed);
 	nfs_free_fhandle(mount_info.mntfh);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0e181c2..bc7415b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1353,6 +1353,8 @@ struct nfs_renamedata {
 struct nfs_access_entry;
 struct nfs_client;
 struct rpc_timeout;
+struct nfs_subversion;
+struct nfs_mount_info;
 struct nfs_client_initdata;
 struct nfs_pageio_descriptor;
 
@@ -1370,6 +1372,8 @@ struct nfs_rpc_ops {
 			    struct nfs_fsinfo *);
 	struct vfsmount *(*submount) (struct nfs_server *, struct dentry *,
 				      struct nfs_fh *, struct nfs_fattr *);
+	struct dentry *(*try_mount) (int, const char *, struct nfs_mount_info *,
+				     struct nfs_subversion *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fattr *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
-- 
1.7.11.3

