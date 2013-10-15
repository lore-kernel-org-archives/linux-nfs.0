Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51263 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934001Ab3JOUkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] exportfs: fix quadratic behavior in filehandle lookup
Date: Tue, 15 Oct 2013 16:39:33 -0400
Message-Id: <1381869574-10662-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We shouldn't really have to re-lookup the parents on each pass through.
This should make behavior linear instead of quadratic as a function of
directory depth.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |  105 +++++++++++++++++++--------------------------------
 1 file changed, 39 insertions(+), 66 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index afa7c9c..08544ae 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -69,11 +69,7 @@ find_acceptable_alias(struct dentry *result,
 	return NULL;
 }
 
-/*
- * Find root of a disconnected subtree and return a reference to it.
- */
-static struct dentry *
-find_disconnected_root(struct dentry *dentry)
+static bool dentry_connected(struct dentry *dentry)
 {
 	dget(dentry);
 	while (!IS_ROOT(dentry)) {
@@ -81,13 +77,14 @@ find_disconnected_root(struct dentry *dentry)
 
 		if (!(parent->d_flags & DCACHE_DISCONNECTED)) {
 			dput(parent);
-			break;
+			dput(dentry);
+			return true;
 		}
 
 		dput(dentry);
 		dentry = parent;
 	}
-	return dentry;
+	return false;
 }
 
 static void clear_disconnected(struct dentry *dentry)
@@ -109,11 +106,13 @@ static void clear_disconnected(struct dentry *dentry)
 /*
  * Return the parent directory on success.
  *
- * Return NULL to keep trying.
+ * If it races with a rename or unlink, assume the other operation
+ * connected it, but return NULL to indicate the caller should check
+ * this just to make sure the filesystem isn't nuts.
  *
  * Otherwise return an error.
  */
-static int reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf, int *noprogress)
+static struct dentry *reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf)
 {
 	struct dentry *parent;
 	struct dentry *tmp;
@@ -137,20 +136,17 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf
 		err = PTR_ERR(parent);
 		dprintk("%s: get_parent of %ld failed, err %d\n",
 			__func__, dentry->d_inode->i_ino, err);
-		return err;
+		return parent;
 	}
 
 	dprintk("%s: find name of %lu in %lu\n", __func__,
 		dentry->d_inode->i_ino, parent->d_inode->i_ino);
 	err = exportfs_get_name(mnt, parent, nbuf, dentry);
 	if (err) {
-		dput(parent);
 		if (err == -ENOENT)
-			/* some race between get_parent and
-			 * get_name?  just try again
-			 */
-			return 0;
-		return err;
+			 return NULL;
+		dput(parent);
+		return ERR_PTR(err);
 	}
 	dprintk("%s: found name: %s\n", __func__, nbuf);
 	mutex_lock(&parent->d_inode->i_mutex);
@@ -160,26 +156,13 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf
 		err = PTR_ERR(tmp);
 		dprintk("%s: lookup failed: %d\n",
 			__func__, err);
-		dput(parent);
-		return err;
+		return NULL;
 	}
-	/* we didn't really want tmp, we really wanted
-	 * a side-effect of the lookup.
-	 * hopefully, tmp == dentry, though it isn't really
-	 * a problem if it isn't
-	 */
-	if (tmp == dentry)
-		*noprogress = 0;
-	else
-		printk("%s: tmp != dentry\n", __func__);
+	/* Note tmp != dentry is possible at this point, but that's OK */
 	dput(tmp);
-	dput(parent);
-	if (IS_ROOT(dentry)) {
-		/* something went wrong, we have to give up */
-		dput(dentry);
-		return -ESTALE;
-	}
-	return 0;
+	if (IS_ROOT(dentry))
+		return ERR_PTR(-ESTALE);
+	return parent;
 }
 
 /*
@@ -190,51 +173,41 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf
 static int
 reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 {
-	int noprogress = 0;
-	int err = -ESTALE;
+	struct dentry *dentry, *parent;
 
-	/*
-	 * It is possible that a confused file system might not let us complete
-	 * the path to the root.  For example, if get_parent returns a directory
-	 * in which we cannot find a name for the child.  While this implies a
-	 * very sick filesystem we don't want it to cause knfsd to spin.  Hence
-	 * the noprogress counter.  If we go through the loop 10 times (2 is
-	 * probably enough) without getting anywhere, we just give up
-	 */
-	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
-		struct dentry *dentry = find_disconnected_root(target_dir);
+	dentry = dget(target_dir);
 
-		if (!IS_ROOT(dentry)) {
-			/* must have found a connected parent - great */
-			clear_disconnected(target_dir);
-			noprogress = 0;
-			dput(dentry);
-			continue;
-		}
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
 		if (dentry == mnt->mnt_sb->s_root) {
-			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
-			clear_disconnected(target_dir);
-			noprogress = 0;
+			WARN_ON_ONCE(1);
+			break;
+		}
+		if (!IS_ROOT(dentry)) {
+			parent = dget_parent(dentry);
 			dput(dentry);
+			dentry = parent;
 			continue;
 		}
 		/*
 		 * We have hit the top of a disconnected path, try to
 		 * find parent and connect.
 		 */
-		err = reconnect_one(mnt, dentry, nbuf, &noprogress);
-		if (err)
-			return err;
+		parent = reconnect_one(mnt, dentry, nbuf);
 		dput(dentry);
+		if (!parent)
+			break;
+		if (IS_ERR(parent))
+			return PTR_ERR(parent);
+		dentry = parent;
 	}
-
-	if (target_dir->d_flags & DCACHE_DISCONNECTED) {
-		/* something went wrong - oh-well */
-		if (!err)
-			err = -ESTALE;
-		return err;
+	/*
+	 * Should be unnecessary, but let's be careful:
+	 */
+	if (!dentry_connected(target_dir)) {
+		WARN_ON_ONCE(1);
+		return -ESTALE;
 	}
-
+	clear_disconnected(target_dir);
 	return 0;
 }
 
-- 
1.7.9.5

