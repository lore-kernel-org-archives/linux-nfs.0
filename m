Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932745Ab2AMULT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:19 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 16/44] NFS: Create a version-specific do_submount() function
Date: Fri, 13 Jan 2012 15:10:25 -0500
Message-Id: <1326485453-1350-17-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 a chance to check if we are doing a normal submount or a
referral.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c         |    1 +
 fs/nfs/namespace.c      |   32 +++++++++++++++++---------------
 fs/nfs/nfs.h            |    4 ++++
 fs/nfs/nfs2/module.c    |    1 +
 fs/nfs/nfs3/module.c    |    1 +
 fs/nfs/nfs4/namespace.c |   11 +++++++++++
 fs/nfs/nfs4/nfs4.h      |    2 ++
 7 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6c19290..b4e13be 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -137,6 +137,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
 	.init_aclclient = nfs4_init_aclclient,
+	.do_submount = nfs4_do_submount,
 };
 #endif /* CONFIG_NFS_V4 */
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 18c5e4f..5fedb66 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -18,6 +18,7 @@
 #include <linux/vfs.h>
 #include <linux/sunrpc/gss_api.h>
 #include "internal.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -27,11 +28,6 @@ static LIST_HEAD(nfs_automount_list);
 static DECLARE_DELAYED_WORK(nfs_automount_task, nfs_expire_automounts);
 int nfs_mountpoint_expiry_timeout = 500 * HZ;
 
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor);
-
 /*
  * nfs_path - reconstruct the path given an arbitrary dentry
  * @base - used to return pointer to the end of devname part of path
@@ -212,6 +208,16 @@ static inline int nfs_lookup_with_sec(struct nfs_server *server,
 }
 #endif /* CONFIG_NFS_V4 */
 
+static struct vfsmount *nfs_version_submount(struct nfs_server *server,
+					     struct dentry *dentry,
+					     struct nfs_fh *fh,
+					     struct nfs_fattr *fattr,
+					     rpc_authflavor_t authflavor)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+	return nfs_mod->do_submount(dentry, fh, fattr, authflavor);
+}
+
 /*
  * nfs_d_automount - Handle crossing a mountpoint on the server
  * @path - The mountpoint
@@ -261,12 +267,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 		goto out;
 	}
 
-	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(path->dentry);
-	else
-		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
-	if (IS_ERR(mnt))
-		goto out;
+	mnt = nfs_version_submount(server, path->dentry, fh, fattr, flavor);
 
 	dprintk("%s: done, success\n", __func__);
 	mntget(mnt); /* prevent immediate expiration */
@@ -335,10 +336,10 @@ static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
  * @authflavor - security flavor to use when performing the mount
  *
  */
-static struct vfsmount *nfs_do_submount(struct dentry *dentry,
-					struct nfs_fh *fh,
-					struct nfs_fattr *fattr,
-					rpc_authflavor_t authflavor)
+struct vfsmount *nfs_do_submount(struct dentry *dentry,
+				 struct nfs_fh *fh,
+				 struct nfs_fattr *fattr,
+				 rpc_authflavor_t authflavor)
 {
 	struct nfs_clone_mount mountdata = {
 		.sb = dentry->d_sb,
@@ -371,3 +372,4 @@ out:
 	dprintk("<-- nfs_do_submount() = %p\n", mnt);
 	return mnt;
 }
+EXPORT_SYMBOL_GPL(nfs_do_submount);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 6b746d7..181b3b3 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -20,6 +20,8 @@ struct nfs_subversion {
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
 	void (*init_aclclient)(struct nfs_server *);
+	struct vfsmount *(*do_submount)(struct dentry *, struct nfs_fh *,
+					struct nfs_fattr *, rpc_authflavor_t);
 };
 
 void nfs_register_versions(void);
@@ -70,5 +72,7 @@ int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 
 /* Exported in namespace.c */
 struct vfsmount *nfs_d_automount(struct path *);
+struct vfsmount *nfs_do_submount(struct dentry *, struct nfs_fh *,
+				 struct nfs_fattr *, rpc_authflavor_t);
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 60302c7..ffdee2b 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -27,6 +27,7 @@ struct nfs_subversion nfs_v2 = {
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
 	.init_aclclient = nfs2_init_aclclient,
+	.do_submount = nfs_do_submount,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index 4c097a5..0eb8124 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -27,6 +27,7 @@ struct nfs_subversion nfs_v3 = {
 	.reference = nfs3_reference,
 	.unreference = nfs3_unreference,
 	.init_aclclient = nfs3_init_aclclient,
+	.do_submount = nfs_do_submount,
 };
 
 static int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4/namespace.c b/fs/nfs/nfs4/namespace.c
index 6a21d95..0ec675e 100644
--- a/fs/nfs/nfs4/namespace.c
+++ b/fs/nfs/nfs4/namespace.c
@@ -19,6 +19,7 @@
 #include "../internal.h"
 #include "nfs4_fs.h"
 #include "../dns_resolve.h"
+#include "../nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -263,3 +264,13 @@ out:
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
+	return nfs_do_submount(dentry, fh, fattr, authflavor);
+}
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 8ed9951..4640a95 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -2,5 +2,7 @@
 #define __LINUX_FS_NFS_NFS4_H
 
 void nfs4_init_aclclient(struct nfs_server *);
+struct vfsmount *nfs4_do_submount(struct dentry *, struct nfs_fh *,
+				  struct nfs_fattr *, rpc_authflavor_t);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
-- 
1.7.8.3

