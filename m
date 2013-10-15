Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51262 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934000Ab3JOUkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Oct 2013 16:40:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] exportfs: make variable names more helpful
Date: Tue, 15 Oct 2013 16:39:31 -0400
Message-Id: <1381869574-10662-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The use of 3 easily-confused TLAs is not helpful here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   60 +++++++++++++++++++++++++--------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 63996d2..24fb763 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -113,10 +113,10 @@ static void clear_disconnected(struct dentry *dentry)
  *
  * Otherwise return an error.
  */
-static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, int *noprogress)
+static int reconnect_one(struct vfsmount *mnt, struct dentry *dentry, char *nbuf, int *noprogress)
 {
-	struct dentry *ppd;
-	struct dentry *npd;
+	struct dentry *parent;
+	struct dentry *tmp;
 	int err;
 	/*
 	 * Getting the parent can't be supported generically, the
@@ -126,15 +126,15 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, in
 	 * depending on the dcache finding the parent for you, you lose
 	 * if there's a reboot or inodes get flushed.
 	 */
-	ppd = ERR_PTR(-EACCES);
+	parent = ERR_PTR(-EACCES);
 
-	mutex_lock(&pd->d_inode->i_mutex);
+	mutex_lock(&dentry->d_inode->i_mutex);
 	if (mnt->mnt_sb->s_export_op->get_parent)
-		ppd = mnt->mnt_sb->s_export_op->get_parent(pd);
-	mutex_unlock(&pd->d_inode->i_mutex);
+		parent = mnt->mnt_sb->s_export_op->get_parent(dentry);
+	mutex_unlock(&dentry->d_inode->i_mutex);
 
-	if (IS_ERR(ppd)) {
-		err = PTR_ERR(ppd);
+	if (IS_ERR(parent)) {
+		err = PTR_ERR(parent);
 		dprintk("%s: get_parent of %ld failed, err %d\n",
 			__func__, dentry->d_inode->i_ino, err);
 		return err;
@@ -142,9 +142,9 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, in
 
 	dprintk("%s: find name of %lu in %lu\n", __func__,
 		dentry->d_inode->i_ino, parent->d_inode->i_ino);
-	err = exportfs_get_name(mnt, ppd, nbuf, pd);
+	err = exportfs_get_name(mnt, parent, nbuf, dentry);
 	if (err) {
-		dput(ppd);
+		dput(parent);
 		if (err == -ENOENT)
 			/* some race between get_parent and
 			 * get_name?  just try again
@@ -153,30 +153,30 @@ static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, in
 		return err;
 	}
 	dprintk("%s: found name: %s\n", __func__, nbuf);
-	mutex_lock(&ppd->d_inode->i_mutex);
-	npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
-	mutex_unlock(&ppd->d_inode->i_mutex);
-	if (IS_ERR(npd)) {
-		err = PTR_ERR(npd);
+	mutex_lock(&parent->d_inode->i_mutex);
+	tmp = lookup_one_len(nbuf, parent, strlen(nbuf));
+	mutex_unlock(&parent->d_inode->i_mutex);
+	if (IS_ERR(tmp)) {
+		err = PTR_ERR(tmp);
 		dprintk("%s: lookup failed: %d\n",
 			__func__, err);
-		dput(ppd);
+		dput(parent);
 		return err;
 	}
-	/* we didn't really want npd, we really wanted
+	/* we didn't really want tmp, we really wanted
 	 * a side-effect of the lookup.
-	 * hopefully, npd == pd, though it isn't really
+	 * hopefully, tmp == dentry, though it isn't really
 	 * a problem if it isn't
 	 */
-	if (npd == pd)
+	if (tmp == dentry)
 		*noprogress = 0;
 	else
-		printk("%s: npd != pd\n", __func__);
-	dput(npd);
-	dput(ppd);
-	if (IS_ROOT(pd)) {
+		printk("%s: tmp != dentry\n", __func__);
+	dput(tmp);
+	dput(parent);
+	if (IS_ROOT(dentry)) {
 		/* something went wrong, we have to give up */
-		dput(pd);
+		dput(dentry);
 		return -ESTALE;
 	}
 	return 0;
@@ -202,13 +202,13 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 	 * probably enough) without getting anywhere, we just give up
 	 */
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
-		struct dentry *pd = find_disconnected_root(target_dir);
+		struct dentry *dentry = find_disconnected_root(target_dir);
 
-		if (!IS_ROOT(pd)) {
+		if (!IS_ROOT(dentry)) {
 			/* must have found a connected parent - great */
 			clear_disconnected(target_dir);
 			noprogress = 0;
-		} else if (pd == mnt->mnt_sb->s_root) {
+		} else if (dentry == mnt->mnt_sb->s_root) {
 			printk(KERN_ERR "export: Eeek filesystem root is not connected, impossible\n");
 			clear_disconnected(target_dir);
 			noprogress = 0;
@@ -217,11 +217,11 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			 * We have hit the top of a disconnected path, try to
 			 * find parent and connect.
 			 */
-			err = reconnect_one(mnt, pd, nbuf, &noprogress);
+			err = reconnect_one(mnt, dentry, nbuf, &noprogress);
 			if (err)
 				return err;
 		}
-		dput(pd);
+		dput(dentry);
 	}
 
 	if (target_dir->d_flags & DCACHE_DISCONNECTED) {
-- 
1.7.9.5

