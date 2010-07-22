Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734Ab0GVR67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 13:58:59 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/6] AFS: Use d_automount() rather than abusing follow_link()
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>
Date: Thu, 22 Jul 2010 18:58:52 +0100
Message-ID: <20100722175852.5552.85642.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
References: <20100722175847.5552.11520.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Make AFS use the new d_automount() dentry operation rather than abusing
follow_link() on directories.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/dir.c      |    1 +
 fs/afs/internal.h |    1 +
 fs/afs/mntpt.c    |   46 +++++++++++++++-------------------------------
 3 files changed, 17 insertions(+), 31 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index b42d5cc..5366f9b 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -65,6 +65,7 @@ static const struct dentry_operations afs_fs_dentry_operations = {
 	.d_revalidate	= afs_d_revalidate,
 	.d_delete	= afs_d_delete,
 	.d_release	= afs_d_release,
+	.d_automount	= afs_d_automount,
 };
 
 #define AFS_DIR_HASHTBL_SIZE	128
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 5f679b7..2c700dc 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -583,6 +583,7 @@ extern int afs_abort_to_error(u32);
 extern const struct inode_operations afs_mntpt_inode_operations;
 extern const struct file_operations afs_mntpt_file_operations;
 
+extern struct vfsmount *afs_d_automount(struct path *);
 extern int afs_mntpt_check_symlink(struct afs_vnode *, struct key *);
 extern void afs_mntpt_kill_timer(void);
 
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index a9e2303..ea9cfee 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -24,7 +24,6 @@ static struct dentry *afs_mntpt_lookup(struct inode *dir,
 				       struct dentry *dentry,
 				       struct nameidata *nd);
 static int afs_mntpt_open(struct inode *inode, struct file *file);
-static void *afs_mntpt_follow_link(struct dentry *dentry, struct nameidata *nd);
 static void afs_mntpt_expiry_timed_out(struct work_struct *work);
 
 const struct file_operations afs_mntpt_file_operations = {
@@ -33,7 +32,6 @@ const struct file_operations afs_mntpt_file_operations = {
 
 const struct inode_operations afs_mntpt_inode_operations = {
 	.lookup		= afs_mntpt_lookup,
-	.follow_link	= afs_mntpt_follow_link,
 	.readlink	= page_readlink,
 	.getattr	= afs_getattr,
 };
@@ -82,6 +80,7 @@ int afs_mntpt_check_symlink(struct afs_vnode *vnode, struct key *key)
 		_debug("symlink is a mountpoint");
 		spin_lock(&vnode->lock);
 		set_bit(AFS_VNODE_MOUNTPOINT, &vnode->flags);
+		vnode->vfs_inode.i_flags |= S_AUTOMOUNT;
 		spin_unlock(&vnode->lock);
 	}
 
@@ -205,52 +204,37 @@ error_no_devname:
 }
 
 /*
- * follow a link from a mountpoint directory, thus causing it to be mounted
+ * handle an automount point
  */
-static void *afs_mntpt_follow_link(struct dentry *dentry, struct nameidata *nd)
+struct vfsmount *afs_d_automount(struct path *path)
 {
 	struct vfsmount *newmnt;
 	int err;
 
-	_enter("%p{%s},{%s:%p{%s},}",
-	       dentry,
-	       dentry->d_name.name,
-	       nd->path.mnt->mnt_devname,
-	       dentry,
-	       nd->path.dentry->d_name.name);
-
-	dput(nd->path.dentry);
-	nd->path.dentry = dget(dentry);
+	_enter("{%s,%s}", path->mnt->mnt_devname, path->dentry->d_name.name);
 
-	newmnt = afs_mntpt_do_automount(nd->path.dentry);
-	if (IS_ERR(newmnt)) {
-		path_put(&nd->path);
-		return (void *)newmnt;
-	}
+	newmnt = afs_mntpt_do_automount(path->dentry);
+	if (IS_ERR(newmnt))
+		return newmnt;
 
 	mntget(newmnt);
-	err = do_add_mount(newmnt, &nd->path, MNT_SHRINKABLE, &afs_vfsmounts);
+	err = do_add_mount(newmnt, path, MNT_SHRINKABLE, &afs_vfsmounts);
 	switch (err) {
 	case 0:
-		path_put(&nd->path);
-		nd->path.mnt = newmnt;
-		nd->path.dentry = dget(newmnt->mnt_root);
 		schedule_delayed_work(&afs_mntpt_expiry_timer,
 				      afs_mntpt_expiry_timeout * HZ);
-		break;
+		_leave(" = %p {%s}", newmnt, newmnt->mnt_devname);
+		return newmnt;
 	case -EBUSY:
 		/* someone else made a mount here whilst we were busy */
-		while (d_mountpoint(nd->path.dentry) &&
-		       follow_down(&nd->path))
-			;
-		err = 0;
+		mntput(newmnt);
+		_leave(" = NULL [EBUSY]");
+		return NULL;
 	default:
 		mntput(newmnt);
-		break;
+		_leave(" = %d", err);
+		return ERR_PTR(err);
 	}
-
-	_leave(" = %d", err);
-	return ERR_PTR(err);
 }
 
 /*

