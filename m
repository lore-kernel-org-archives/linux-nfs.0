Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50192 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137Ab3JYUah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 8/8] exportfs: fix quadratic behavior in filehandle lookup
Date: Fri, 25 Oct 2013 16:30:05 -0400
Message-Id: <1382733005-6006-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Suppose we're given the filehandle for a directory whose closest
ancestor in the dcache is its Nth ancestor.

The main loop in reconnect_path searches for an IS_ROOT ancestor of
target_dir, reconnects that ancestor to its parent, then recommences the
search for an IS_ROOT ancestor from target_dir.

This behavior is quadratic in N.  And there's really no need to restart
the search from target_dir each time: once a directory has been looked
up, it won't become IS_ROOT again.  So instead of starting from
target_dir each time, we can continue where we left off.

This simplifies the code and improves performance on very deep directory
heirachies.  (I can't think of any reason anyone should need heirarchies
a hundred or more deep, but the performance improvement may be valuable
if only to limit damage in case of abuse.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   66 ++++++++++-----------------------------------------
 1 file changed, 13 insertions(+), 53 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index b33b9c4..48a359d 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -69,27 +69,6 @@ find_acceptable_alias(struct dentry *result,
 	return NULL;
 }
 
-/*
- * Find root of a disconnected subtree and return a reference to it.
- */
-static struct dentry *
-find_disconnected_root(struct dentry *dentry)
-{
-	dget(dentry);
-	while (!IS_ROOT(dentry)) {
-		struct dentry *parent = dget_parent(dentry);
-
-		if (!(parent->d_flags & DCACHE_DISCONNECTED)) {
-			dput(parent);
-			break;
-		}
-
-		dput(dentry);
-		dentry = parent;
-	}
-	return dentry;
-}
-
 static bool dentry_connected(struct dentry *dentry)
 {
 	dget(dentry);
@@ -225,45 +204,26 @@ out_reconnected:
 static int
 reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 {
-	int err = -ESTALE;
+	struct dentry *dentry, *parent;
 
-	while (target_dir->d_flags & DCACHE_DISCONNECTED) {
-		struct dentry *dentry = find_disconnected_root(target_dir);
+	dentry = dget(target_dir);
 
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
 		BUG_ON(dentry == mnt->mnt_sb->s_root);
 
-		if (!IS_ROOT(dentry)) {
-			/* must have found a connected parent - great */
-			clear_disconnected(target_dir);
-			dput(dentry);
+		if (IS_ROOT(dentry))
+			parent = reconnect_one(mnt, dentry, nbuf);
+		else
+			parent = dget_parent(dentry);
+
+		if (!parent)
 			break;
-		} else {
-			struct dentry *parent;
-			/*
-			 * We have hit the top of a disconnected path, try to
-			 * find parent and connect.
-			 */
-			 parent = reconnect_one(mnt, dentry, nbuf);
-			 if (!parent)
-				goto out_reconnected;
-			if (IS_ERR(parent)) {
-				err = PTR_ERR(parent);
-				break;
-			}
-			dput(parent);
-		}
 		dput(dentry);
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
-	}
-
-	return 0;
-out_reconnected:
+	dput(dentry);
 	clear_disconnected(target_dir);
 	return 0;
 }
-- 
1.7.9.5

