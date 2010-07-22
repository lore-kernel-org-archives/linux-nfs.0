Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756060Ab0GVR7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:59:19 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/6] NFS: Use d_automount() rather than abusing follow_link()
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 22 Jul 2010 18:58:57 +0100
Message-ID: <20100722175857.5552.99050.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
References: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make NFS use the new d_automount() dentry operation rather than abusing
follow_link() on directories.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c           |    4 ++
 fs/nfs/inode.c         |    4 +-
 fs/nfs/internal.h      |    1 +
 fs/nfs/namespace.c     |   87 ++++++++++++++++++++++--------------------------
 include/linux/nfs_fs.h |    1 -
 5 files changed, 46 insertions(+), 51 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e60416d..9ce04af 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -727,7 +727,7 @@ int nfs_lookup_verify_inode(struct inode *inode, struct nameidata *nd)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 
-	if (test_bit(NFS_INO_MOUNTPOINT, &NFS_I(inode)->flags))
+	if (IS_AUTOMOUNT(inode))
 		return 0;
 	if (nd != NULL) {
 		/* VFS wants an on-the-wire revalidation */
@@ -927,6 +927,7 @@ const struct dentry_operations nfs_dentry_operations = {
 	.d_revalidate	= nfs_lookup_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
+	.d_automount	= nfs_d_automount,
 };
 
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *nd)
@@ -1002,6 +1003,7 @@ const struct dentry_operations nfs4_dentry_operations = {
 	.d_revalidate	= nfs_open_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
+	.d_automount	= nfs_d_automount,
 };
 
 /*
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 099b351..848abe8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -295,7 +295,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 				else
 					inode->i_op = &nfs_mountpoint_inode_operations;
 				inode->i_fop = NULL;
-				set_bit(NFS_INO_MOUNTPOINT, &nfsi->flags);
+				inode->i_flags |= S_AUTOMOUNT;
 			}
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op = &nfs_symlink_inode_operations;
@@ -1138,7 +1138,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/* Update the fsid? */
 	if (S_ISDIR(inode->i_mode) && (fattr->valid & NFS_ATTR_FATTR_FSID) &&
 			!nfs_fsid_equal(&server->fsid, &fattr->fsid) &&
-			!test_bit(NFS_INO_MOUNTPOINT, &nfsi->flags))
+			!IS_AUTOMOUNT(inode))
 		server->fsid = fattr->fsid;
 
 	/*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e70f44b..f597aac 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -239,6 +239,7 @@ extern char *nfs_path(const char *base,
 		      const struct dentry *droot,
 		      const struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
+extern struct vfsmount *nfs_d_automount(struct path *path);
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index db6aa36..bf80079 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -88,9 +88,8 @@ Elong:
 }
 
 /*
- * nfs_follow_mountpoint - handle crossing a mountpoint on the server
- * @dentry - dentry of mountpoint
- * @nd - nameidata info
+ * nfs_d_automount - Handle crossing a mountpoint on the server
+ * @path - The mountpoint
  *
  * When we encounter a mountpoint on the server, we want to set up
  * a mountpoint on the client too, to prevent inode numbers from
@@ -100,87 +99,81 @@ Elong:
  * situation, and that different filesystems may want to use
  * different security flavours.
  */
-static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameidata *nd)
+struct vfsmount *nfs_d_automount(struct path *path)
 {
 	struct vfsmount *mnt;
-	struct nfs_server *server = NFS_SERVER(dentry->d_inode);
+	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
 	struct dentry *parent;
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
 	int err;
 
-	dprintk("--> nfs_follow_mountpoint()\n");
+	dprintk("--> nfs_d_automount()\n");
 
-	err = -ESTALE;
-	if (IS_ROOT(dentry))
-		goto out_err;
+	mnt = ERR_PTR(-ESTALE);
+	if (IS_ROOT(path->dentry))
+		goto out_nofree;
 
-	err = -ENOMEM;
+	mnt = ERR_PTR(-ENOMEM);
 	fh = nfs_alloc_fhandle();
 	fattr = nfs_alloc_fattr();
 	if (fh == NULL || fattr == NULL)
-		goto out_err;
+		goto out;
 
 	dprintk("%s: enter\n", __func__);
-	dput(nd->path.dentry);
-	nd->path.dentry = dget(dentry);
 
-	/* Look it up again */
-	parent = dget_parent(nd->path.dentry);
+	/* Look it up again to get its attributes */
+	parent = dget_parent(path->dentry);
 	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
-						  &nd->path.dentry->d_name,
+						  &path->dentry->d_name,
 						  fh, fattr);
 	dput(parent);
-	if (err != 0)
-		goto out_err;
+	if (err != 0) {
+		mnt = ERR_PTR(err);
+		goto out;
+	}
 
 	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
-		mnt = nfs_do_refmount(nd->path.mnt, nd->path.dentry);
+		mnt = nfs_do_refmount(path->mnt, path->dentry);
 	else
-		mnt = nfs_do_submount(nd->path.mnt, nd->path.dentry, fh,
-				      fattr);
-	err = PTR_ERR(mnt);
+		mnt = nfs_do_submount(path->mnt, path->dentry, fh, fattr);
 	if (IS_ERR(mnt))
-		goto out_err;
+		goto out;
 
 	mntget(mnt);
-	err = do_add_mount(mnt, &nd->path, nd->path.mnt->mnt_flags|MNT_SHRINKABLE,
+	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE,
 			   &nfs_automount_list);
-	if (err < 0) {
+	switch (err) {
+	case 0:
+		dprintk("%s: done, success\n", __func__);
+		schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
+		break;
+	case -EBUSY:
+		/* someone else made a mount here whilst we were busy */
 		mntput(mnt);
-		if (err == -EBUSY)
-			goto out_follow;
-		goto out_err;
+		dprintk("%s: done, collision\n", __func__);
+		mnt = NULL;
+		break;
+	default:
+		mntput(mnt);
+		dprintk("%s: done, error %d\n", __func__, err);
+		mnt = ERR_PTR(err);
+		break;
 	}
-	path_put(&nd->path);
-	nd->path.mnt = mnt;
-	nd->path.dentry = dget(mnt->mnt_root);
-	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
+
 out:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fh);
-	dprintk("%s: done, returned %d\n", __func__, err);
-
-	dprintk("<-- nfs_follow_mountpoint() = %d\n", err);
-	return ERR_PTR(err);
-out_err:
-	path_put(&nd->path);
-	goto out;
-out_follow:
-	while (d_mountpoint(nd->path.dentry) &&
-	       follow_down(&nd->path))
-		;
-	err = 0;
-	goto out;
+out_nofree:
+	dprintk("<-- nfs_follow_mountpoint() = %p\n", mnt);
+	return mnt;
 }
 
 const struct inode_operations nfs_mountpoint_inode_operations = {
-	.follow_link	= nfs_follow_mountpoint,
 	.getattr	= nfs_getattr,
 };
 
 const struct inode_operations nfs_referral_inode_operations = {
-	.follow_link	= nfs_follow_mountpoint,
 };
 
 static void nfs_expire_automounts(struct work_struct *work)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 77c2ae5..4511220 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -205,7 +205,6 @@ struct nfs_inode {
 #define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
 #define NFS_INO_STALE		(1)		/* possible stale inode */
 #define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
-#define NFS_INO_MOUNTPOINT	(3)		/* inode is remote mountpoint */
 #define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */

