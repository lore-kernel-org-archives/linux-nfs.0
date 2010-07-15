From: David Howells <dhowells@redhat.com>
Subject: [PATCH 14/18] xstat: NFS: Use d_automount() rather than abusing
	follow_link() [ver #6]
Date: Thu, 15 Jul 2010 03:17:26 +0100
Message-ID: <20100715021726.5544.59242.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
List-ID: <linux-nfs.vger.kernel.org>

Make NFS use the new d_automount() dentry operation rather than abusing
follow_link() on directories.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/dir.c       |    2 +
 fs/nfs/inode.c     |    1 +
 fs/nfs/internal.h  |    1 +
 fs/nfs/namespace.c |   87 ++++++++++++++++++++++++----------------------------
 4 files changed, 44 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 782b431..d7e5810 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
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
index 8c6de96..f9737bd 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -296,6 +296,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 					inode->i_op = &nfs_mountpoint_inode_operations;
 				inode->i_fop = NULL;
 				set_bit(NFS_INO_MOUNTPOINT, &nfsi->flags);
+				inode->i_flags |= S_AUTOMOUNT;
 			}
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op = &nfs_symlink_inode_operations;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d8bd619..48de6f8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -238,6 +238,7 @@ extern char *nfs_path(const char *base,
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
