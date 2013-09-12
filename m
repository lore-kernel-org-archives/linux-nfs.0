Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51511 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099Ab3ILQD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Sep 2013 12:03:26 -0400
Date: Thu, 12 Sep 2013 12:03:24 -0400
To: linux-fsdevel@vger.kernel.org
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: why is i_ino unsigned long, anyway?
Message-ID: <20130912160324.GE1462@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Somebody noticed an "ls -l" over nfs failing on entries with inode
numbers greater than 2^32 on a 32-bit NFS server.  The cause is some
code that tries to compare i_ino to the full 64-bit inode number.

I think the following will fix it, but I'm curious: why is i_ino
"unsigned long", anyway?  Is there something know that depends on that,
or is it just that the sheer number of users makes it too scary to
change?

--b.

commit 0cc784eb430285535ae7a79dd5133ab66e9ce839
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Sep 10 11:41:12 2013 -0400

    exportfs: fix 32-bit nfsd handling of 64-bit inode numbers
    
    Symptoms were spurious -ENOENTs on stat of an NFS filesystem from a
    32-bit NFS server exporting a very large XFS filesystem, when the
    server's cache is cold (so the inodes in question are not in cache).
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 293bc2e..6a79bb8 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -215,7 +215,7 @@ struct getdents_callback {
 	struct dir_context ctx;
 	char *name;		/* name that was found. It already points to a
 				   buffer NAME_MAX+1 is size */
-	unsigned long ino;	/* the inum we are looking for */
+	u64 ino;		/* the inum we are looking for */
 	int found;		/* inode matched? */
 	int sequence;		/* sequence counter */
 };
@@ -255,10 +255,10 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	struct inode *dir = path->dentry->d_inode;
 	int error;
 	struct file *file;
+	struct kstat stat;
 	struct getdents_callback buffer = {
 		.ctx.actor = filldir_one,
 		.name = name,
-		.ino = child->d_inode->i_ino
 	};
 
 	error = -ENOTDIR;
@@ -268,6 +268,16 @@ static int get_name(const struct path *path, char *name, struct dentry *child)
 	if (!dir->i_fop)
 		goto out;
 	/*
+	 * inode->i_ino is unsigned long, kstat->ino is u64, so the
+	 * former would be insufficient on 32-bit hosts when the
+	 * filesystem supports 64-bit inode numbers.  So we need to
+	 * actually call ->getattr, not just read i_ino:
+	 */
+	error = vfs_getattr(path, &stat);
+	if (error)
+		return error;
+	buffer.ino = stat.ino;
+	/*
 	 * Open the directory ...
 	 */
 	file = dentry_open(path, O_RDONLY, cred);
