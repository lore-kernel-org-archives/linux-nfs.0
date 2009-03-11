From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/30] NFS: flush cached directory information slightly
 more readily.
Date: Wed, 11 Mar 2009 14:41:06 -0400
Message-ID: <20090311184106.5578.68185.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: NeilBrown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22328 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbZCKSoJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:09 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.de>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index acaaa7c..268ce3a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1113,8 +1113,16 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
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
@@ -1148,8 +1156,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
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

