Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760263Ab2BJWCX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:23 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 12/21] NFS: module-specific submount function
Date: Fri, 10 Feb 2012 17:01:56 -0500
Message-Id: <1328911325-1566-12-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 the chance to check for referrals and allows each version
to pass their own xdev_fs_type structure.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/namespace.c     |   54 ++++++++++++++++++-----------------------------
 fs/nfs/nfs.h           |    5 ++++
 fs/nfs/nfs2super.c     |    9 ++++++++
 fs/nfs/nfs3super.c     |    9 ++++++++
 fs/nfs/nfs4_fs.h       |    3 ++
 fs/nfs/nfs4namespace.c |   11 +++++++++
 fs/nfs/nfs4super.c     |    1 +
 fs/nfs/super.c         |    1 +
 8 files changed, 60 insertions(+), 33 deletions(-)

diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 8102391..31c3fcb 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -7,6 +7,7 @@
  * NFS namespace
  */
 
+#include <linux/module.h>
 #include <linux/dcache.h>
 #include <linux/gfp.h>
 #include <linux/mount.h>
@@ -26,7 +27,8 @@ static LIST_HEAD(nfs_automount_list);
 static DECLARE_DELAYED_WORK(nfs_automount_task, nfs_expire_automounts);
 int nfs_mountpoint_expiry_timeout = 500 * HZ;
 
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
+static struct vfsmount *nfs_do_submount(struct nfs_server *server,
+					struct dentry *dentry,
 					struct nfs_fh *fh,
 					struct nfs_fattr *fattr,
 					rpc_authflavor_t authflavor);
@@ -260,10 +262,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 		goto out;
 	}
 
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(path->dentry);
-	else
-		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
+	mnt = nfs_do_submount(server, path->dentry, fh, fattr, flavor);
 	if (IS_ERR(mnt))
 		goto out;
 
@@ -302,29 +301,6 @@ void nfs_release_automount_timer(void)
 		cancel_delayed_work(&nfs_automount_task);
 }
 
-/*
- * Clone a mountpoint of the appropriate type
- */
-static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
-					   const char *devname,
-					   struct nfs_clone_mount *mountdata)
-{
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
-	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
-#endif
-}
-
 /**
  * nfs_do_submount - set up mountpoint when crossing a filesystem boundary
  * @dentry - parent directory
@@ -333,10 +309,11 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
  * @authflavor - security flavor to use when performing the mount
  *
  */
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor)
+struct vfsmount *_nfs_do_submount(struct file_system_type *xdev,
+				  struct dentry *dentry,
+				  struct nfs_fh *fh,
+				  struct nfs_fattr *fattr,
+				  rpc_authflavor_t authflavor)
 {
 	struct nfs_clone_mount mountdata = {
 		.sb = dentry->d_sb,
@@ -360,7 +337,7 @@ static struct vfsmount *nfs_do_submount(struct dentry *dentry,
 	mnt = (struct vfsmount *)devname;
 	if (IS_ERR(devname))
 		goto free_page;
-	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
+	mnt = vfs_kern_mount(xdev, 0, devname, &mountdata);
 free_page:
 	free_page((unsigned long)page);
 out:
@@ -369,3 +346,14 @@ out:
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
 }
+EXPORT_SYMBOL_GPL(_nfs_do_submount);
+
+static struct vfsmount *nfs_do_submount(struct nfs_server *server,
+					struct dentry *dentry,
+					struct nfs_fh *fh,
+					struct nfs_fattr *fattr,
+					rpc_authflavor_t authflavor)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+	return nfs_mod->submount(dentry, fh, fattr, authflavor);
+}
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index dc1854c..dd3496a 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -27,6 +27,7 @@ struct nfs_subversion {
 	struct dentry *(*fs_mount)(struct file_system_type *, int, const char *,
 				   struct nfs_fh *, struct nfs_parsed_mount_data *);
 	struct dentry *(*xdev_mount)(int, const char *, struct nfs_clone_mount *);
+	struct vfsmount *(*submount)(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
 };
 
 struct nfs_sb_mountdata {
@@ -57,6 +58,10 @@ int nfs_link(struct dentry *, struct inode *, struct dentry *);
 int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
+/* Exported in namespace.c */
+struct vfsmount *_nfs_do_submount(struct file_system_type *, struct dentry *,
+				  struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
+
 /* Exported in super.c */
 extern struct file_system_type nfs_fs_type;
 struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index ddcc4d1..6d2a1fd 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -39,6 +39,14 @@ static struct dentry *nfs2_xdev_mount(int flags, const char *dev_name,
 	return _nfs_xdev_mount(&nfs_fs_type, server, flags, dev_name, data, NFS_MOUNT_UNSHARED);
 }
 
+static struct vfsmount *nfs2_do_submount(struct dentry *dentry,
+					 struct nfs_fh *fh,
+					 struct nfs_fattr *fattr,
+					 rpc_authflavor_t authflavor)
+{
+	return _nfs_do_submount(&nfs_xdev_fs_type, dentry, fh, fattr, authflavor);
+}
+
 static struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -48,6 +56,7 @@ static struct nfs_subversion nfs_v2 = {
 	.unreference = nfs2_unreference,
 	.fs_mount = nfs2_fs_mount,
 	.xdev_mount = nfs2_xdev_mount,
+	.submount = nfs2_do_submount,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 474840f..c8ca918 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -41,6 +41,14 @@ static struct dentry *nfs3_xdev_mount(int flags, const char *dev_name,
 	return _nfs_xdev_mount(&nfs_fs_type, server, flags, dev_name, data, NFS_MOUNT_UNSHARED);
 }
 
+static struct vfsmount *nfs3_do_submount(struct dentry *dentry,
+					 struct nfs_fh *fh,
+					 struct nfs_fattr *fattr,
+					 rpc_authflavor_t authflavor)
+{
+	return _nfs_do_submount(&nfs_xdev_fs_type, dentry, fh, fattr, authflavor);
+}
+
 const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
@@ -79,6 +87,7 @@ static struct nfs_subversion nfs_v3 = {
 	.unreference = nfs3_unreference,
 	.fs_mount = nfs3_fs_mount,
 	.xdev_mount = nfs3_xdev_mount,
+	.submount = nfs3_do_submount,
 };
 
 int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1147640..2328d68 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -210,6 +210,9 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 extern struct file_system_type nfs4_fs_type;
 struct dentry *nfs4_try_mount(int flags, const char *dev_name, struct nfs_parsed_mount_data *);
 
+/* nfs4namespace.c */
+struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
+
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 48a9acd..92a5b9a 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -19,6 +19,7 @@
 #include "internal.h"
 #include "nfs4_fs.h"
 #include "dns_resolve.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -265,3 +266,13 @@ out:
 	dprintk("%s: done\n", __func__);
 	return mnt;
 }
+
+struct vfsmount *nfs4_do_submount(struct dentry *dentry,
+				  struct nfs_fh *fh,
+				  struct nfs_fattr *fattr,
+				  rpc_authflavor_t authflavor)
+{
+	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
+		return nfs_do_refmount(dentry);
+	return _nfs_do_submount(&nfs4_xdev_fs_type, dentry, fh, fattr, authflavor);
+}
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index b35840e..d9bd619 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -619,6 +619,7 @@ static struct nfs_subversion nfs_v4 = {
 	.unreference = nfs4_unreference,
 	.fs_mount = nfs4_fs_mount,
 	.xdev_mount = nfs4_xdev_mount,
+	.submount = nfs4_do_submount,
 };
 
 int __init init_nfs_v4(void)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 30e903c..c8fcec5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -284,6 +284,7 @@ struct file_system_type nfs_xdev_fs_type = {
 	.kill_sb	= nfs_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
+EXPORT_SYMBOL_GPL(nfs_xdev_fs_type);
 
 static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
-- 
1.7.9

