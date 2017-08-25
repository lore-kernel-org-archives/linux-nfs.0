Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47467 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754272AbdHYHgY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 03:36:24 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 25 Aug 2017 17:34:41 +1000
Subject: [PATCH 1/2] NFS: revalidate "." etc correctly on "open".
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Message-ID: <150364648184.31291.7718153434142507012.stgit@noble>
In-Reply-To: <150364635600.31291.11905399689488751395.stgit@noble>
References: <150364635600.31291.11905399689488751395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For correct close-to-open semantics, NFS must validate
the change attribute of a directory (or file) on open.

Since commit ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
d_weak_revalidate dentry op"), open() of "." or a path ending ".." is
not revalidated reliably (except when that direct is a mount point).

Prior to that commit, "." was revalidated using nfs_lookup_revalidate()
which checks the LOOKUP_OPEN flag and forces revalidation if the flag is
set.
Since that commit, nfs_weak_revalidate() is used for NFSv3 (which
ignores the flags) and nothing is used for NFSv4.

This is fixed by using nfs_lookup_verify_inode() in
nfs_weak_revalidate().  This does the revalidation exactly when needed.
Also, add a definition of .d_weak_revalidate for NFSv4.

The incorrect behavior is easily demonstrated by running "echo *" in
some non-mountpoint NFS directory while watching network traffic.
Without this patch, "echo *" sometimes doesn't produce any traffic.
With the patch it always does.

Fixes: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a d_weak_revalidate dentry op")
cc: stable@vger.kernel.org (3.9+)
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/dir.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3522b1249019..1458e0a8969d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1241,8 +1241,7 @@ static int nfs_weak_revalidate(struct dentry *dentry, unsigned int flags)
 		return 0;
 	}
 
-	if (nfs_mapping_need_revalidate_inode(inode))
-		error = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	error = nfs_lookup_verify_inode(inode, flags);
 	dfprintk(LOOKUPCACHE, "NFS: %s: inode %lu is %s\n",
 			__func__, inode->i_ino, error ? "invalid" : "valid");
 	return !error;
@@ -1393,6 +1392,7 @@ static int nfs4_lookup_revalidate(struct dentry *, unsigned int);
 
 const struct dentry_operations nfs4_dentry_operations = {
 	.d_revalidate	= nfs4_lookup_revalidate,
+	.d_weak_revalidate	= nfs_weak_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
 	.d_automount	= nfs_d_automount,


