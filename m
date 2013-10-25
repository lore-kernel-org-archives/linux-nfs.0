Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50200 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753520Ab3JYUak (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 16:30:40 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] exportfs: stop retrying once we race with rename/remove
Date: Fri, 25 Oct 2013 16:30:01 -0400
Message-Id: <1382733005-6006-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1382733005-6006-1-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There are two places here where we could race with a rename or remove:

	- We could find the parent, but then be removed or renamed away
	  from that parent directory before finding our name in that
	  directory.
	- We could find the parent, and find our name in that parent,
	  but then be renamed or removed before we look ourselves up by
	  that name in that parent.

In both cases the concurrent rename or remove will take care of
reconnecting the directory that we're currently examining.  Our target
directory should then also be connected.  Check this and clear
DISCONNECTED in these cases instead of looping around again.

Note: we *do* need to check that this actually happened if we want to be
robust in the face of corrupted filesystems: a corrupted filesystem
could just return a completely wrong parent, and we want to fail with an
error in that case before starting to clear DISCONNECTED on
non-DISCONNECTED filesystems.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/exportfs/expfs.c |   45 ++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 40 insertions(+), 5 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index c65b748..6b5ddd5 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -90,6 +90,23 @@ find_disconnected_root(struct dentry *dentry)
 	return dentry;
 }
 
+static bool dentry_connected(struct dentry *dentry)
+{
+	dget(dentry);
+	while (dentry->d_flags & DCACHE_DISCONNECTED) {
+		struct dentry *parent = dget_parent(dentry);
+
+		dput(dentry);
+		if (IS_ROOT(dentry)) {
+			dput(parent);
+			return false;
+		}
+		dentry = parent;
+	}
+	dput(dentry);
+	return true;
+}
+
 static void clear_disconnected(struct dentry *dentry)
 {
 	dget(dentry);
@@ -189,9 +206,9 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 				dput(pd);
 				if (err == -ENOENT)
 					/* some race between get_parent and
-					 * get_name?  just try again
+					 * get_name?
 					 */
-					continue;
+					goto out_reconnected;
 				break;
 			}
 			dprintk("%s: found name: %s\n", __func__, nbuf);
@@ -211,12 +228,12 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 			 * hopefully, npd == pd, though it isn't really
 			 * a problem if it isn't
 			 */
+			dput(npd);
+			dput(ppd);
 			if (npd == pd)
 				noprogress = 0;
 			else
-				printk("%s: npd != pd\n", __func__);
-			dput(npd);
-			dput(ppd);
+				goto out_reconnected;
 			if (IS_ROOT(pd)) {
 				/* something went wrong, we have to give up */
 				dput(pd);
@@ -234,6 +251,24 @@ reconnect_path(struct vfsmount *mnt, struct dentry *target_dir, char *nbuf)
 	}
 
 	return 0;
+out_reconnected:
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
+	if (!dentry_connected(target_dir))
+		return -ESTALE;
+	clear_disconnected(target_dir);
+	return 0;
 }
 
 struct getdents_callback {
-- 
1.7.9.5

