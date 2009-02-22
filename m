From: Neil Brown <neilb@suse.de>
Subject: [PATCH] nfs: flush cached directory information slightly more readily.
Date: Sun, 22 Feb 2009 17:57:03 +1100
Message-ID: <18848.63295.938509.804561@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50654 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbZBVG5N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2009 01:57:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,
 here is the (hopefully) final patch as discussed.
 You can pull it from
       git://neil.brown.name/linux-2.6 nfs-devel

Thanks,
NeilBrown


>From fd81df7ffb8543d9c914e1276ce0ffcbb9267b6a Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Subject: [PATCH] nfs: flush cached directory information slightly more readily.
Date: Sun, 22 Feb 2009 07:03:19 +1100

If cached directory contents becomes incorrect, there is no way to
flush the contents.  This contrasts with files where file locking is
the recommended way to ensure cache consistency between multiple
applications (a read-lock always flushes the cache).

Also while changes to files often change the size of the file (thus
triggering a cache flush), changes to directories often do not change
the apparent size (as the size is often rounded to a block size).

So it is particularly important with directories to avoid the
possibility of an incorrect cache wherever possible.

When the link count on a directory changes it implies a change in the
number of child directories, and so a change in the contents of this
directory.  So use that as a trigger to flush cached contents.

When the ctime changes but the mtime does not, there are two possible
reasons.
 1/ The owner/mode information has been changed.
 2/ utimes has been used to set the mtime backwards.

In the first case, a data-cache flush is not required.
In the second case it is.

So on the basis that correctness trumps performance, flush the
directory contents cache in this case also.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/inode.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0c38168..e3fadf8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1116,8 +1116,16 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 				nfs_force_lookup_revalidate(inode);
 		}
 		/* If ctime has changed we should definitely clear access+acl caches */
-		if (!timespec_equal(&inode->i_ctime, &fattr->ctime))
+		if (!timespec_equal(&inode->i_ctime, &fattr->ctime)) {
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+			/* and probably clear data for a directory too as utimes can cause
+			 * havoc with our cache.
+			 */
+			if (S_ISDIR(inode->i_mode)) {
+				invalid |= NFS_INO_INVALID_DATA;
+				nfs_force_lookup_revalidate(inode);
+			}
+		}
 	} else if (nfsi->change_attr != fattr->change_attr) {
 		dprintk("NFS: change_attr change on server for file %s/%ld\n",
 				inode->i_sb->s_id, inode->i_ino);
@@ -1151,8 +1159,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	    inode->i_gid != fattr->gid)
 		invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 
-	if (inode->i_nlink != fattr->nlink)
+	if (inode->i_nlink != fattr->nlink) {
 		invalid |= NFS_INO_INVALID_ATTR;
+		if (S_ISDIR(inode->i_mode))
+			invalid |= NFS_INO_INVALID_DATA;
+	}
 
 	inode->i_mode = fattr->mode;
 	inode->i_nlink = fattr->nlink;
-- 
1.6.1.3

