Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932762Ab2AMULb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:31 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 31/44] NFS: Move v4 getroot code to the v4 directory
Date: Fri, 13 Jan 2012 15:10:40 -0500
Message-Id: <1326485453-1350-32-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The future module uses these functions, so I am moving them into the v4
directory rather than export v4-only functions to the v4 module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile       |    3 +-
 fs/nfs/getroot.c      |  130 +---------------------------------------------
 fs/nfs/nfs.h          |    3 +
 fs/nfs/nfs4/getroot.c |  137 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 144 insertions(+), 129 deletions(-)
 create mode 100644 fs/nfs/nfs4/getroot.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 87213a8..5335ce2 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -13,7 +13,8 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4/proc.o nfs4/xdr.o nfs4/state.o nfs4/renewd.o \
 			   nfs4/delegation.o nfs4/idmap.o \
 			   nfs4/callback.o nfs4/callback_xdr.o \
 			   nfs4/callback_proc.o nfs4/namespace.o \
-			   nfs4/client.o nfs4/module.o nfs4/sysctl.o
+			   nfs4/client.o nfs4/module.o nfs4/sysctl.o \
+			   nfs4/getroot.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 64e086e..8847d5b 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -45,7 +45,7 @@
  * Set the superblock root dentry.
  * Note that this function frees the inode in case of error.
  */
-static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
+int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *inode)
 {
 	/* The mntroot acts as the dummy root dentry for this superblock */
 	if (sb->s_root == NULL) {
@@ -71,6 +71,7 @@ static int nfs_superblock_set_dummy_root(struct super_block *sb, struct inode *i
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_superblock_set_dummy_root);
 
 /*
  * get an NFS2/NFS3 root dentry from the root filehandle
@@ -138,130 +139,3 @@ out:
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
index 7b40e24..5fee8ec 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -91,6 +91,9 @@ int nfs_lock(struct file *, int, struct file_lock *);
 int nfs_flock(struct file *, int, struct file_lock *);
 int nfs_setlease(struct file *, long, struct file_lock **);
 
+/* Exported in getroot.c */
+int nfs_superblock_set_dummy_root(struct super_block *, struct inode *);
+
 /* Exported in inode.c */
 int nfs_setattr(struct dentry *, struct iattr *);
 int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
diff --git a/fs/nfs/nfs4/getroot.c b/fs/nfs/nfs4/getroot.c
new file mode 100644
index 0000000..9e7841c
--- /dev/null
+++ b/fs/nfs/nfs4/getroot.c
@@ -0,0 +1,137 @@
+/*
+ * Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+#include <linux/dcache.h>
+#include <linux/nfs.h>
+#include <linux/nfs_fs.h>
+#include <linux/security.h>
+
+#include "nfs4_fs.h"
+#include "../nfs.h"
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
1.7.8.3

