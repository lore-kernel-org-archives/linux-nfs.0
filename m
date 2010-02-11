From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] NFS: Don't generate a GETATTR when opening an O_DIRECT
	file
Date: Thu, 11 Feb 2010 14:09:18 -0500
Message-ID: <20100211190918.2666.82008.stgit@localhost.localdomain>
References: <20100211185757.2666.90001.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:38383 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674Ab0BKTKX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 14:10:23 -0500
In-Reply-To: <20100211185757.2666.90001.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Close-to-open isn't needed for O_DIRECT files, since their data is
never cached.  So if their attribute cache hasn't expired, skip the
GETATTR.

Note that fattr->time_start is required to be set correctly by the NFS
direct I/O paths in order for this patch to work properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3c7f03b..367302b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -709,6 +709,12 @@ static int nfs_is_exclusive_create(struct inode *dir, struct nameidata *nd)
 	return nd && nfs_lookup_check_intent(nd, LOOKUP_EXCL);
 }
 
+static bool nfs_open_odirect(struct nameidata *nd)
+{
+	struct file *filp = nd->intent.open.file;
+	return filp && (filp->f_flags & O_DIRECT);
+}
+
 /*
  * Inode and filehandle revalidation for lookups.
  *
@@ -716,6 +722,9 @@ static int nfs_is_exclusive_create(struct inode *dir, struct nameidata *nd)
  * or if the intent information indicates that we're about to open this
  * particular file and the "nocto" mount flag is not set.
  *
+ * O_DIRECT files have no locally cached data, so close-to-open checking
+ * isn't necessary.  However, their attributes must be revalidated if the
+ * cache has expired, mainly to catch the case where actimeo is zero.
  */
 static inline
 int nfs_lookup_verify_inode(struct inode *inode, struct nameidata *nd)
@@ -730,12 +739,15 @@ int nfs_lookup_verify_inode(struct inode *inode, struct nameidata *nd)
 			goto out_force;
 		/* This is an open(2) */
 		if (nfs_lookup_check_intent(nd, LOOKUP_OPEN) != 0 &&
-				!(server->flags & NFS_MOUNT_NOCTO) &&
-				(S_ISREG(inode->i_mode) ||
-				 S_ISDIR(inode->i_mode)))
-			goto out_force;
+		    (S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode))) {
+			if (nfs_open_odirect(nd))
+				goto out_conditional;
+			if (!(server->flags & NFS_MOUNT_NOCTO))
+				goto out_force;
+		}
 		return 0;
 	}
+out_conditional:
 	return nfs_revalidate_inode(server, inode);
 out_force:
 	return __nfs_revalidate_inode(server, inode);

