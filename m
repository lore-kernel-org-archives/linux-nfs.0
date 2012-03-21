Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53728 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758826Ab2CUPVU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:20 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 16/23] NFS: Move the v4 getroot code to nfs4getroot.c
Date: Wed, 21 Mar 2012 11:20:46 -0400
Message-Id: <1332343253-24970-17-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile      |    3 +-
 fs/nfs/getroot.c     |  135 +-------------------------------------------------
 fs/nfs/nfs.h         |    3 ++
 fs/nfs/nfs4getroot.c |  135 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 141 insertions(+), 135 deletions(-)
 create mode 100644 fs/nfs/nfs4getroot.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index cf8b669..8028e09 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,7 +12,8 @@ nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
-			   nfs4namespace.o nfs4sysctl.o nfs4client.o
+			   nfs4namespace.o nfs4sysctl.o nfs4client.o \
+			   nfs4getroot.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index dcb6154..f6a14a6 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -23,11 +23,9 @@
 #include <linux/sunrpc/stats.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
-#include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
-#include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/namei.h>
 #include <linux/security.h>
@@ -35,17 +33,13 @@
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-#include "nfs4_fs.h"
-#include "delegation.h"
-#include "internal.h"
-
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
  * Set the superblock root dentry.
  * Note that this function frees the inode in case of error.
  */
-static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
+int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
 {
 	/* The mntroot acts as the dummy root dentry for this superblock */
 	if (sb->s_root == NULL) {
@@ -138,130 +132,3 @@ out:
 	nfs_free_fattr(fsinfo.fattr);
 	return ret;
 }
-
-#ifdef CONFIG_NFS_V4
-
-int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
-{
-	struct nfs_fsinfo fsinfo;
-	int ret = -ENOMEM;
-
-	dprintk("--> nfs4_get_rootfh()\n");
-
-	fsinfo.fattr = nfs_alloc_fattr();
-	if (fsinfo.fattr == NULL)
-		goto out;
-
-	/* Start by getting the root filehandle from the server */
-	ret = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
-	if (ret < 0) {
-		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
-		goto out;
-	}
-
-	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
-			|| !S_ISDIR(fsinfo.fattr->mode)) {
-		printk(KERN_ERR "nfs4_get_rootfh:"
-		       " getroot encountered non-directory\n");
-		ret = -ENOTDIR;
-		goto out;
-	}
-
-	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
-		printk(KERN_ERR "nfs4_get_rootfh:"
-		       " getroot obtained referral\n");
-		ret = -EREMOTE;
-		goto out;
-	}
-
-	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
-out:
-	nfs_free_fattr(fsinfo.fattr);
-	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
-	return ret;
-}
-
-/*
- * get an NFS4 root dentry from the root filehandle
- */
-struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
-			     const char *devname)
-{
-	struct nfs_server *server = NFS_SB(sb);
-	struct nfs_fattr *fattr = NULL;
-	struct dentry *ret;
-	struct inode *inode;
-	void *name = kstrdup(devname, GFP_KERNEL);
-	int error;
-
-	dprintk("--> nfs4_get_root()\n");
-
-	if (!name)
-		return ERR_PTR(-ENOMEM);
-
-	/* get the info about the server and filesystem */
-	error = nfs4_server_capabilities(server, mntfh);
-	if (error < 0) {
-		dprintk("nfs_get_root: getcaps error = %d\n",
-			-error);
-		kfree(name);
-		return ERR_PTR(error);
-	}
-
-	fattr = nfs_alloc_fattr();
-	if (fattr == NULL) {
-		kfree(name);
-		return ERR_PTR(-ENOMEM);
-	}
-
-	/* get the actual root for this mount */
-	error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
-	if (error < 0) {
-		dprintk("nfs_get_root: getattr error = %d\n", -error);
-		ret = ERR_PTR(error);
-		goto out;
-	}
-
-	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
-	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
-		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
-
-	inode = nfs_fhget(sb, mntfh, fattr);
-	if (IS_ERR(inode)) {
-		dprintk("nfs_get_root: get root inode failed\n");
-		ret = ERR_CAST(inode);
-		goto out;
-	}
-
-	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0) {
-		ret = ERR_PTR(error);
-		goto out;
-	}
-
-	/* root dentries normally start off anonymous and get spliced in later
-	 * if the dentry tree reaches them; however if the dentry already
-	 * exists, we'll pick it up at this point and use it as the root
-	 */
-	ret = d_obtain_alias(inode);
-	if (IS_ERR(ret)) {
-		dprintk("nfs_get_root: get root dentry failed\n");
-		goto out;
-	}
-
-	security_d_instantiate(ret, inode);
-	spin_lock(&ret->d_lock);
-	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
-		ret->d_fsdata = name;
-		name = NULL;
-	}
-	spin_unlock(&ret->d_lock);
-out:
-	if (name)
-		kfree(name);
-	nfs_free_fattr(fattr);
-	dprintk("<-- nfs4_get_root()\n");
-	return ret;
-}
-
-#endif /* CONFIG_NFS_V4 */
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index d53f350..877ca24 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -83,6 +83,9 @@ int nfs_link(struct dentry *, struct inode *, struct dentry *);
 int nfs_mknod(struct inode *, struct dentry *, umode_t, dev_t);
 int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
 
+/* Exported in getroot.c */
+int nfs_superblock_set_dummy_root(struct super_block *, struct inode *);
+
 /* Exported in namespace.c */
 struct vfsmount *_nfs_do_submount(struct file_system_type *, struct dentry *,
 				  struct nfs_fh *, struct nfs_fattr *, rpc_authflavor_t);
diff --git a/fs/nfs/nfs4getroot.c b/fs/nfs/nfs4getroot.c
new file mode 100644
index 0000000..14eea8d
--- /dev/null
+++ b/fs/nfs/nfs4getroot.c
@@ -0,0 +1,135 @@
+/*
+ * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+#include <linux/sunrpc/sched.h>
+#include <linux/dcache.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+
+#include "nfs4_fs.h"
+
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
+int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
+{
+	struct nfs_fsinfo fsinfo;
+	int ret = -ENOMEM;
+
+	dprintk("--> nfs4_get_rootfh()\n");
+
+	fsinfo.fattr = nfs_alloc_fattr();
+	if (fsinfo.fattr == NULL)
+		goto out;
+
+	/* Start by getting the root filehandle from the server */
+	ret = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
+	if (ret < 0) {
+		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
+		goto out;
+	}
+
+	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
+			|| !S_ISDIR(fsinfo.fattr->mode)) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
+		       " getroot encountered non-directory\n");
+		ret = -ENOTDIR;
+		goto out;
+	}
+
+	if (fsinfo.fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
+		printk(KERN_ERR "nfs4_get_rootfh:"
+		       " getroot obtained referral\n");
+		ret = -EREMOTE;
+		goto out;
+	}
+
+	memcpy(&server->fsid, &fsinfo.fattr->fsid, sizeof(server->fsid));
+out:
+	nfs_free_fattr(fsinfo.fattr);
+	dprintk("<-- nfs4_get_rootfh() = %d\n", ret);
+	return ret;
+}
+
+/*
+ * get an NFS4 root dentry from the root filehandle
+ */
+struct dentry *nfs4_get_root(struct super_block *sb, struct nfs_fh *mntfh,
+			     const char *devname)
+{
+	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_fattr *fattr = NULL;
+	struct dentry *ret;
+	struct inode *inode;
+	void *name = kstrdup(devname, GFP_KERNEL);
+	int error;
+
+	dprintk("--> nfs4_get_root()\n");
+
+	if (!name)
+		return ERR_PTR(-ENOMEM);
+
+	/* get the info about the server and filesystem */
+	error = nfs4_server_capabilities(server, mntfh);
+	if (error < 0) {
+		dprintk("nfs_get_root: getcaps error = %d\n",
+			-error);
+		kfree(name);
+		return ERR_PTR(error);
+	}
+
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL) {
+		kfree(name);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	/* get the actual root for this mount */
+	error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
+	if (error < 0) {
+		dprintk("nfs_get_root: getattr error = %d\n", -error);
+		ret = ERR_PTR(error);
+		goto out;
+	}
+
+	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
+	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
+
+	inode = nfs_fhget(sb, mntfh, fattr);
+	if (IS_ERR(inode)) {
+		dprintk("nfs_get_root: get root inode failed\n");
+		ret = ERR_CAST(inode);
+		goto out;
+	}
+
+	error = nfs_superblock_set_dummy_root(sb, inode);
+	if (error != 0) {
+		ret = ERR_PTR(error);
+		goto out;
+	}
+
+	/* root dentries normally start off anonymous and get spliced in later
+	 * if the dentry tree reaches them; however if the dentry already
+	 * exists, we'll pick it up at this point and use it as the root
+	 */
+	ret = d_obtain_alias(inode);
+	if (IS_ERR(ret)) {
+		dprintk("nfs_get_root: get root dentry failed\n");
+		goto out;
+	}
+
+	security_d_instantiate(ret, inode);
+	spin_lock(&ret->d_lock);
+	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
+		ret->d_fsdata = name;
+		name = NULL;
+	}
+	spin_unlock(&ret->d_lock);
+out:
+	if (name)
+		kfree(name);
+	nfs_free_fattr(fattr);
+	dprintk("<-- nfs4_get_root()\n");
+	return ret;
+}
-- 
1.7.9.4

