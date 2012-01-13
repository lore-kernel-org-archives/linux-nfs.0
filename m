Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932746Ab2AMULU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:20 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 17/44] NFS: Added in a custom do_clone_mount() function
Date: Fri, 13 Jan 2012 15:10:26 -0500
Message-Id: <1326485453-1350-18-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows v4 to use its own xdev type when doing clone mounts.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c         |    1 +
 fs/nfs/namespace.c      |   30 +++++++++++++-----------------
 fs/nfs/nfs.h            |    6 ++++++
 fs/nfs/nfs2/module.c    |    1 +
 fs/nfs/nfs3/module.c    |    1 +
 fs/nfs/nfs4/namespace.c |    7 +++++++
 fs/nfs/nfs4/nfs4.h      |    4 ++++
 7 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b4e13be..6091414 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -138,6 +138,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
 	.do_submount = nfs4_do_submount,
+	.do_clone_mount = nfs4_do_clone_mount,
 };
 #endif /* CONFIG_NFS_V4 */
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 5fedb66..721d882 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -305,27 +305,23 @@ void nfs_release_automount_timer(void)
 		cancel_delayed_work(&nfs_automount_task);
 }
 
+struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
+				    const char *devname,
+				    struct nfs_clone_mount *mountdata)
+{
+	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
+}
+EXPORT_SYMBOL_GPL(nfs_do_clone_mount);
+
 /*
  * Clone a mountpoint of the appropriate type
  */
-static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
-					   const char *devname,
-					   struct nfs_clone_mount *mountdata)
+struct vfsmount *nfs_version_clone_mount(struct nfs_server *server,
+					 const char *devname,
+					 struct nfs_clone_mount *mountdata)
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
-	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
-#endif
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+	return nfs_mod->do_clone_mount(server, devname, mountdata);
 }
 
 /**
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 181b3b3..0f119ab 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -11,6 +11,8 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_xdr.h>
 
+struct nfs_clone_mount;
+
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
 	struct rpc_version *rpc_vers;	/* NFS version information */
@@ -22,6 +24,8 @@ struct nfs_subversion {
 	void (*init_aclclient)(struct nfs_server *);
 	struct vfsmount *(*do_submount)(struct dentry *, struct nfs_fh *,
 					struct nfs_fattr *, rpc_authflavor_t);
+	struct vfsmount *(*do_clone_mount)(struct nfs_server *, const char *,
+					   struct nfs_clone_mount *);
 };
 
 void nfs_register_versions(void);
@@ -74,5 +78,7 @@ int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 struct vfsmount *nfs_d_automount(struct path *);
 struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
 				 struct nfs_fattr *, rpc_authflavor_t);
+struct vfsmount *nfs_do_clone_mount(struct nfs_server *, const char *,
+				    struct nfs_clone_mount *);
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index ffdee2b..768c375 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -28,6 +28,7 @@ struct nfs_subversion nfs_v2 = {
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
 	.do_submount = nfs_do_submount,
+	.do_clone_mount = nfs_do_clone_mount,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 0eb8124..0898339 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -28,6 +28,7 @@ struct nfs_subversion nfs_v3 = {
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
 	.do_submount = nfs_do_submount,
+	.do_clone_mount = nfs_do_clone_mount,
 };
 
 static int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4/namespace.c b/fs/nfs/nfs4/namespace.c
index 0ec675e..11bda77 100644
--- a/fs/nfs/nfs4/namespace.c
+++ b/fs/nfs/nfs4/namespace.c
@@ -274,3 +274,10 @@ struct vfsmount *nfs4_do_submount(struct dentry *dentry,
 		return nfs_do_refmount(dentry);
 	return nfs_do_submount(dentry, fh, fattr, authflavor);
 }
+
+struct vfsmount *nfs4_do_clone_mount(struct nfs_server *server,
+				     const char *devname,
+				     struct nfs_clone_mount *mountdata)
+{
+	return vfs_kern_mount(&nfs4_xdev_fs_type, 0, devname, mountdata);
+}
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 4640a95..f6694b9 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -1,8 +1,12 @@
 #ifndef __LINUX_FS_NFS_NFS4_H
 #define __LINUX_FS_NFS_NFS4_H
 
+#include "../nfs.h"
+
 void nfs4_init_aclclient(struct nfs_server *);
 struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
 				  struct nfs_fattr *, rpc_authflavor_t);
+struct vfsmount *nfs4_do_clone_mount(struct nfs_server *, const char *,
+				     struct nfs_clone_mount *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
-- 
1.7.8.3

