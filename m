Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57129 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754956Ab0E1Kjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 May 2010 06:39:45 -0400
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: Fri, 28 May 2010 20:39:37 +1000
Content-Type: text/plain; charset=us-ascii
Message-ID: <19455.40297.826427.56982@notabene.brown>
Cc: linux-nfs@vger.kernel.org
Cc: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: allow close-to-open cache semantics to apply to root of NFS filesystem
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


To obey NFS cache semantics, the client must verify the cached
attributes when a file is opened.  In most cases this is done by a call to
d_validate as one of the last steps in path_walk.

However for the root of a filesystem, d_validate is only ever called
on the mounted-on filesystem (except when the path ends '.' or '..').
So NFS has no chance to validate the attributes.

So, in nfs_opendir, we revalidate the attributes if the opened
directory is the mountpoint.  This may cause double-validation for "."
and ".." lookups, but that is better than missing regular /path/name
lookups completely.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ee9a179..72062da 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -140,6 +140,13 @@ nfs_opendir(struct inode *inode, struct file *filp)
 
 	/* Call generic open code in order to cache credentials */
 	res = nfs_open(inode, filp);
+	if (filp->f_path.dentry == filp->f_path.mnt->mnt_root) {
+		/* This is a mountpoint, so d_revalidate will never
+		 * have been called, so we need to refresh the
+		 * inode (for close-open consistency) ourselves.
+		 */
+		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	}
 	return res;
 }
 
