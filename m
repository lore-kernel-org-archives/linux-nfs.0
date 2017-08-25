Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47491 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754456AbdHYHgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 03:36:31 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 25 Aug 2017 17:34:41 +1000
Subject: [PATCH 2/2] NFS: remove special-case revalidate in nfs_opendir()
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Message-ID: <150364648187.31291.1370014127010920792.stgit@noble>
In-Reply-To: <150364635600.31291.11905399689488751395.stgit@noble>
References: <150364635600.31291.11905399689488751395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit f5a73672d181 ("NFS: allow close-to-open cache semantics to
apply to root of NFS filesystem") added a call to
__nfs_revalidate_inode() to nfs_opendir to as the lookup
process wouldn't reliable do this.

Subsequent commit a3fbbde70a0c ("VFS: we need to set LOOKUP_JUMPED
on mountpoint crossing") make this unnecessary.  So remove the
unnecessary code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1458e0a8969d..ca3c6c5d6256 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -118,13 +118,6 @@ nfs_opendir(struct inode *inode, struct file *filp)
 		goto out;
 	}
 	filp->private_data = ctx;
-	if (filp->f_path.dentry == filp->f_path.mnt->mnt_root) {
-		/* This is a mountpoint, so d_revalidate will never
-		 * have been called, so we need to refresh the
-		 * inode (for close-open consistency) ourselves.
-		 */
-		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	}
 out:
 	put_rpccred(cred);
 	return res;


