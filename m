Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49958 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751362AbdCPJdq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Mar 2017 05:33:46 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix old dentry rehash after move
Date: Wed, 15 Mar 2017 21:50:09 -0400
Message-Id: <af7206d9f9cadb44b2030ea46cc1507315df1dbd.1489628865.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that nfs_rename()'s d_move has moved within the RPC task's rpc_call_done
callback, rehashing new_dentry will actually rehash the old dentry's name
in nfs_rename().  d_move() is going to rehash the new dentry for us anyway,
so doing it again here is unnecessary.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: 920b4530fb80 ("NFS: nfs_rename() handle -ERESTARTSYS dentry left behind")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Tested-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/dir.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index fb499a3f21b5..f92ba8d6c556 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2055,7 +2055,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 {
 	struct inode *old_inode = d_inode(old_dentry);
 	struct inode *new_inode = d_inode(new_dentry);
-	struct dentry *dentry = NULL, *rehash = NULL;
+	struct dentry *dentry = NULL;
 	struct rpc_task *task;
 	int error = -EBUSY;
 
@@ -2078,10 +2078,8 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		 * To prevent any new references to the target during the
 		 * rename, we unhash the dentry in advance.
 		 */
-		if (!d_unhashed(new_dentry)) {
+		if (!d_unhashed(new_dentry))
 			d_drop(new_dentry);
-			rehash = new_dentry;
-		}
 
 		if (d_count(new_dentry) > 2) {
 			int err;
@@ -2098,7 +2096,6 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 				goto out;
 
 			new_dentry = dentry;
-			rehash = NULL;
 			new_inode = NULL;
 		}
 	}
@@ -2119,8 +2116,6 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		error = task->tk_status;
 	rpc_put_task(task);
 out:
-	if (rehash)
-		d_rehash(rehash);
 	trace_nfs_rename_exit(old_dir, old_dentry,
 			new_dir, new_dentry, error);
 	/* new dentry created? */
-- 
2.9.3

