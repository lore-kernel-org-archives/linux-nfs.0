Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49156 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab3JPIEI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 04:04:08 -0400
Date: Wed, 16 Oct 2013 01:04:07 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] exportfs: fix quadratic behavior in filehandle lookup
Message-ID: <20131016080407.GA7390@infradead.org>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
 <1381869574-10662-6-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381869574-10662-6-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 04:39:33PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We shouldn't really have to re-lookup the parents on each pass through.
> This should make behavior linear instead of quadratic as a function of
> directory depth.

This looks valid after going through the nasty cases like a
cross-directory rename.  But I'd really prefer the changelog to be way
more detailed.

Also a few untested fixups below:
	- document that reconnect_one can only be called for directories
	- make sure we always properly drop the parent dentry on
	  reconnect_one failure
	- warn then the tmp dentry is not the same as the one we started
	  with.  Given that we deal with directories this should not
	  happen
	- add/update a few comments.
	- tidy up the reconnect_path loop so the reconnect case shares
	  more logic with the dget_parent case


Index: linux/fs/exportfs/expfs.c
===================================================================
--- linux.orig/fs/exportfs/expfs.c	2013-10-16 09:58:44.544119517 +0200
+++ linux/fs/exportfs/expfs.c	2013-10-16 10:04:19.176127470 +0200
@@ -104,38 +104,30 @@ static void clear_disconnected(struct de
 }
 
 /*
- * Return the parent directory on success.
+ * Reconnect a directory dentry with its parent.
  *
- * If it races with a rename or unlink, assume the other operation
- * connected it, but return NULL to indicate the caller should check
- * this just to make sure the filesystem isn't nuts.
+ * Return the parent directory when successfully reconnecting, NULL if it
+ * raced with another VFS operation, in which case it got connected or
+ * the whole file handle will become stale.
  *
  * Otherwise return an error.
  */
-static struct dentry *reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf)
+static struct dentry *reconnect_one(struct vfsmount *mnt,
+		struct dentry *dentry, char *nbuf)
 {
 	struct dentry *parent;
 	struct dentry *tmp;
 	int err;
-	/*
-	 * Getting the parent can't be supported generically, the
-	 * locking is too icky.
-	 *
-	 * If it can't be done, we just return EACCES.  If you were
-	 * depending on the dcache finding the parent for you, you lose
-	 * if there's a reboot or inodes get flushed.
-	 */
-	parent = ERR_PTR(-EACCES);
 
+	parent = ERR_PTR(-EACCES);
 	mutex_lock(&dentry->d_inode->i_mutex);
 	if (mnt->mnt_sb->s_export_op->get_parent)
 		parent = mnt->mnt_sb->s_export_op->get_parent(dentry);
 	mutex_unlock(&dentry->d_inode->i_mutex);
 
 	if (IS_ERR(parent)) {
-		err = PTR_ERR(parent);
 		dprintk("%s: get_parent of %ld failed, err %d\n",
-			__func__, dentry->d_inode->i_ino, err);
+			__func__, dentry->d_inode->i_ino, PTR_ERR(parent));
 		return parent;
 	}
 
@@ -143,26 +135,45 @@ static struct dentry *reconnect_one(stru
 		dentry->d_inode->i_ino, parent->d_inode->i_ino);
 	err = exportfs_get_name(mnt, parent, nbuf, dentry);
 	if (err) {
+		/*
+		 * Someone must have renamed our entry into another parent,
+		 * in which case it has been reconnected by the rename.
+		 *
+		 * Or someone removed it entirely, in which case the file
+		 * handle has become stale.
+		 */
 		if (err == -ENOENT)
-			 return NULL;
-		dput(parent);
-		return ERR_PTR(err);
+			goto out_reconnected;
+		goto out_err;
 	}
 	dprintk("%s: found name: %s\n", __func__, nbuf);
 	mutex_lock(&parent->d_inode->i_mutex);
 	tmp = lookup_one_len(nbuf, parent, strlen(nbuf));
 	mutex_unlock(&parent->d_inode->i_mutex);
 	if (IS_ERR(tmp)) {
-		err = PTR_ERR(tmp);
-		dprintk("%s: lookup failed: %d\n",
-			__func__, err);
-		return NULL;
+		dprintk("%s: lookup failed: %d\n", __func__, PTR_ERR(tmp));
+		goto out_reconnected;
+	}
+	if (WARN_ON(tmp != dentry)) {
+		dprintk("%s: got different dentry while reconnecting.\n",
+			__func__);
+		dput(tmp);
+		err = -ESTALE;
+		goto out_err;
 	}
-	/* Note tmp != dentry is possible at this point, but that's OK */
 	dput(tmp);
-	if (IS_ROOT(dentry))
-		return ERR_PTR(-ESTALE);
+	if (IS_ROOT(dentry)) {
+		err = -ESTALE;
+		goto out_err;
+	}
 	return parent;
+
+out_err:
+	dput(parent);
+	return ERR_PTR(err);
+out_reconnected:
+	dput(parent);
+	return NULL;
 }
 
 /*
@@ -178,21 +189,18 @@ reconnect_path(struct vfsmount *mnt, str
 	dentry = dget(target_dir);
 
 	while (dentry->d_flags & DCACHE_DISCONNECTED) {
-		if (dentry == mnt->mnt_sb->s_root) {
-			WARN_ON_ONCE(1);
-			break;
-		}
-		if (!IS_ROOT(dentry)) {
+		BUG_ON(dentry == mnt->mnt_sb->s_root);
+
+		if (IS_ROOT(dentry)) {
+			/*
+			 * We have hit the top of a disconnected path, try to
+			 * find parent and connect.
+			 */
+			parent = reconnect_one(mnt, dentry, nbuf);
+		} else {
 			parent = dget_parent(dentry);
-			dput(dentry);
-			dentry = parent;
-			continue;
 		}
-		/*
-		 * We have hit the top of a disconnected path, try to
-		 * find parent and connect.
-		 */
-		parent = reconnect_one(mnt, dentry, nbuf);
+
 		dput(dentry);
 		if (!parent)
 			break;
@@ -200,6 +208,7 @@ reconnect_path(struct vfsmount *mnt, str
 			return PTR_ERR(parent);
 		dentry = parent;
 	}
+
 	/*
 	 * Should be unnecessary, but let's be careful:
 	 */
