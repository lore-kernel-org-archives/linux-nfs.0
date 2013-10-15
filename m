Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933999Ab3JOUkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:01 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] exportfs: move most of reconnect_path to helper function
Date: Tue, 15 Oct 2013 16:39:30 -0400
Message-Id: <1381869574-10662-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Just cleanup, no change in functionality.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |  147 +++++++++++++++++++++++++++------------------------
 1 file changed, 79 insertions(+), 68 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 455b0bb..63996d2 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -107,6 +107,82 @@ static void clear_disconnected(struct dentry *dentry)
 }
 
 /*
+ * Return the parent directory on success.
+ *
+ * Return NULL to keep trying.
+ *
+ * Otherwise return an error.
+ */
+static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, int *noprogress)
+{
+	struct dentry *ppd;
+	struct dentry *npd;
+	int err;
+	/*
+	 * Getting the parent can't be supported generically, the
+	 * locking is too icky.
+	 *
+	 * If it can't be done, we just return EACCES.  If you were
+	 * depending on the dcache finding the parent for you, you lose
+	 * if there's a reboot or inodes get flushed.
+	 */
+	ppd = ERR_PTR(-EACCES);
+
+	mutex_lock(&pd->d_inode->i_mutex);
+	if (mnt->mnt_sb->s_export_op->get_parent)
+		ppd = mnt->mnt_sb->s_export_op->get_parent(pd);
+	mutex_unlock(&pd->d_inode->i_mutex);
+
+	if (IS_ERR(ppd)) {
+		err = PTR_ERR(ppd);
+		dprintk("%s: get_parent of %ld failed, err %d\n",
+			__func__, dentry->d_inode->i_ino, err);
+		return err;
+	}
+
+	dprintk("%s: find name of %lu in %lu\n", __func__,
+		dentry->d_inode->i_ino, parent->d_inode->i_ino);
+	err = exportfs_get_name(mnt, ppd, nbuf, pd);
+	if (err) {
+		dput(ppd);
+		if (err == -ENOENT)
+			/* some race between get_parent and
+			 * get_name?  just try again
+			 */
+			return 0;
+		return err;
+	}
+	dprintk("%s: found name: %s\n", __func__, nbuf);
+	mutex_lock(&ppd->d_inode->i_mutex);
+	npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
+	mutex_unlock(&ppd->d_inode->i_mutex);
+	if (IS_ERR(npd)) {
+		err = PTR_ERR(npd);
+		dprintk("%s: lookup failed: %d\n",
+			__func__, err);
+		dput(ppd);
+		return err;
+	}
+	/* we didn't really want npd, we really wanted
+	 * a side-effect of the lookup.
+	 * hopefully, npd == pd, though it isn't really
+	 * a problem if it isn't
+	 */
+	if (npd == pd)
+		*noprogress = 0;
+	else
+		printk("%s: npd != pd\n", __func__);
+	dput(npd);
+	dput(ppd);
+	if (IS_ROOT(pd)) {
+		/* something went wrong, we have to give up */
+		dput(pd);
+		return -ESTALE;
+	}
+	return 0;
+}
+
+/*
  * Make sure target_dir is fully connected to the dentry tree.
  *
  * It may already be, as the flag isn't always updated when connection happens.
@@ -140,75 +216,10 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
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
-					 * get_name?  just try again
-					 */
-					continue;
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
-			if (npd == pd)
-				noprogress = 0;
-			else
-				printk("%s: npd != pd\n", __func__);
-			dput(npd);
-			dput(ppd);
-			if (IS_ROOT(pd)) {
-				/* something went wrong, we have to give up */
-				dput(pd);
-				break;
-			}
+			err = reconnect_one(mnt, pd, nbuf, &noprogress);
+			if (err)
+				return err;
 		}
 		dput(pd);
 	}
-- 
1.7.9.5

