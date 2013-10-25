Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753834Ab3JYUal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/8] exportfs: move most of reconnect_path to helper function
Date: Fri, 25 Oct 2013 16:30:03 -0400
Message-Id: <1382733005-6006-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Also replace 3 easily-confused three-letter acronyms by more helpful
variable names.

Just cleanup, no change in functionality, with one exception: the
dentry_connected() check in the "out_reconnected" case will now only
check the ancestors of the current dentry instead of checking all the
way from target_dir.  Since we've already verified connectivity up to
this dentry, that should be sufficient.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |  164 +++++++++++++++++++++++++++------------------------
 1 file changed, 86 insertions(+), 78 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index d8ba88a..d32ead9 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -126,6 +126,86 @@ static void clear_disconnected(struct dentry *dentry)
 }
 
 /*
+ * Reconnect a directory dentry with its parent.
+ *
+ * This can return a dentry, or NULL, or an error.
+ *
+ * In the first case the returned dentry is the parent of the given
+ * dentry, and may itself need to be reconnected to its parent.
+ *
+ * In the NULL case, a concurrent VFS operation has either renamed or
+ * removed this directory.  The concurrent operation has reconnected our
+ * dentry, so we no longer need to.
+ */
+static struct dentry *reconnect_one(struct vfsmount *mnt,
+		struct dentry *dentry, char *nbuf)
+{
+	struct dentry *parent;
+	struct dentry *tmp;
+	int err;
+
+	parent = ERR_PTR(-EACCES);
+	mutex_lock(&dentry->d_inode->i_mutex);
+	if (mnt->mnt_sb->s_export_op->get_parent)
+		parent = mnt->mnt_sb->s_export_op->get_parent(dentry);
+	mutex_unlock(&dentry->d_inode->i_mutex);
+
+	if (IS_ERR(parent)) {
+		dprintk("%s: get_parent of %ld failed, err %d\n",
+			__func__, dentry->d_inode->i_ino, PTR_ERR(parent));
+		return parent;
+	}
+
+	dprintk("%s: find name of %lu in %lu\n", __func__,
+		dentry->d_inode->i_ino, parent->d_inode->i_ino);
+	err = exportfs_get_name(mnt, parent, nbuf, dentry);
+	if (err == -ENOENT)
+		goto out_reconnected;
+	if (err)
+		goto out_err;
+	dprintk("%s: found name: %s\n", __func__, nbuf);
+	mutex_lock(&parent->d_inode->i_mutex);
+	tmp = lookup_one_len(nbuf, parent, strlen(nbuf));
+	mutex_unlock(&parent->d_inode->i_mutex);
+	if (IS_ERR(tmp)) {
+		dprintk("%s: lookup failed: %d\n", __func__, PTR_ERR(tmp));
+		goto out_err;
+	}
+	if (tmp != dentry) {
+		dput(tmp);
+		goto out_reconnected;
+	}
+	dput(tmp);
+	if (IS_ROOT(dentry)) {
+		err = -ESTALE;
+		goto out_err;
+	}
+	return parent;
+
+out_err:
+	dput(parent);
+	return ERR_PTR(err);
+out_reconnected:
+	dput(parent);
+	/*
+	 * Someone must have renamed our entry into another parent, in
+	 * which case it has been reconnected by the rename.
+	 *
+	 * Or someone removed it entirely, in which case filehandle
+	 * lookup will succeed but the directory is now IS_DEAD and
+	 * subsequent operations on it will fail.
+	 *
+	 * Alternatively, maybe there was no race at all, and the
+	 * filesystem is just corrupt and gave us a parent that doesn't
+	 * actually contain any entry pointing to this inode.  So,
+	 * double check that this worked and return -ESTALE if not:
+	 */
+	if (!dentry_connected(dentry))
+		return ERR_PTR(-ESTALE);
+	return NULL;
+}
+
+/*
  * Make sure target_dir is fully connected to the dentry tree.
  *
  * On successful return, DCACHE_DISCONNECTED will be cleared on
@@ -158,76 +238,19 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			dput(pd);
 			break;
 		} else {
+			struct dentry *parent;
 			/*
 			 * We have hit the top of a disconnected path, try to
 			 * find parent and connect.
-			 *
-			 * Racing with some other process renaming a directory
-			 * isn't much of a problem here.  If someone renames
-			 * the directory, it will end up properly connected,
-			 * which is what we want
-			 *
-			 * Getting the parent can't be supported generically,
-			 * the locking is too icky.
-			 *
-			 * Instead we just return EACCES.  If server reboots
-			 * or inodes get flushed, you lose
-			 */
-			struct dentry *ppd = ERR_PTR(-EACCES);
-			struct dentry *npd;
-
-			mutex_lock(&pd->d_inode->i_mutex);
-			if (mnt->mnt_sb->s_export_op->get_parent)
-				ppd = mnt->mnt_sb->s_export_op->get_parent(pd);
-			mutex_unlock(&pd->d_inode->i_mutex);
-
-			if (IS_ERR(ppd)) {
-				err = PTR_ERR(ppd);
-				dprintk("%s: get_parent of %ld failed, err %d\n",
-					__func__, pd->d_inode->i_ino, err);
-				dput(pd);
-				break;
-			}
-
-			dprintk("%s: find name of %lu in %lu\n", __func__,
-				pd->d_inode->i_ino, ppd->d_inode->i_ino);
-			err = exportfs_get_name(mnt, ppd, nbuf, pd);
-			if (err) {
-				dput(ppd);
-				dput(pd);
-				if (err == -ENOENT)
-					/* some race between get_parent and
-					 * get_name?
-					 */
-					goto out_reconnected;
-				break;
-			}
-			dprintk("%s: found name: %s\n", __func__, nbuf);
-			mutex_lock(&ppd->d_inode->i_mutex);
-			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
-			mutex_unlock(&ppd->d_inode->i_mutex);
-			if (IS_ERR(npd)) {
-				err = PTR_ERR(npd);
-				dprintk("%s: lookup failed: %d\n",
-					__func__, err);
-				dput(ppd);
-				dput(pd);
-				break;
-			}
-			/* we didn't really want npd, we really wanted
-			 * a side-effect of the lookup.
-			 * hopefully, npd == pd, though it isn't really
-			 * a problem if it isn't
 			 */
-			dput(npd);
-			dput(ppd);
-			if (npd != pd)
+			 parent = reconnect_one(mnt, pd, nbuf);
+			 if (!parent)
 				goto out_reconnected;
-			if (IS_ROOT(pd)) {
-				/* something went wrong, we have to give up */
-				dput(pd);
+			if (IS_ERR(parent)) {
+				err = PTR_ERR(parent);
 				break;
 			}
+			dput(parent);
 		}
 		dput(pd);
 	}
@@ -241,21 +264,6 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 
 	return 0;
 out_reconnected:
-	/*
-	 * Someone must have renamed our entry into another parent, in
-	 * which case it has been reconnected by the rename.
-	 *
-	 * Or someone removed it entirely, in which case filehandle
-	 * lookup will succeed but the directory is now IS_DEAD and
-	 * subsequent operations on it will fail.
-	 *
-	 * Alternatively, maybe there was no race at all, and the
-	 * filesystem is just corrupt and gave us a parent that doesn't
-	 * actually contain any entry pointing to this inode.  So,
-	 * double check that this worked and return -ESTALE if not:
-	 */
-	if (!dentry_connected(target_dir))
-		return -ESTALE;
 	clear_disconnected(target_dir);
 	return 0;
 }
-- 
1.7.9.5

