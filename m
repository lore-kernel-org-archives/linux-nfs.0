Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53423 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443AbaGNBbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:31:24 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 4/7] NFS: support RCU_WALK in nfs_permission()
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714012820.12562.43671.stgit@notabene.brown>
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_permission makes two calls which are not always safe in RCU_WALK,
rpc_lookup_cred and nfs_do_access.

The second can easily be made rcu-safe by aborting with -ECHILD before
making the RPC call.

The former can be made rcu-safe by calling rpc_lookup_cred_nonblock()
instead.
As this will almost always succeed, we use it even when RCU_WALK
isn't being used as it still saves some spinlocks in a common case.
We only fall back to rpc_lookup_cred() if rpc_lookup_cred_nonblock()
fails and MAY_NOT_BLOCK isn't set.

This optimisation (always trying rpc_lookup_cred_nonblock()) is
particularly important when a security module is active.
In that case inode_permission() may return -ECHILD from
security_inode_permission() even though ->permission() succeeded in
RCU_WALK mode.
This leads to may_lookup() retrying inode_permission after performing
unlazy_walk().  The spinlock that rpc_lookup_cred() takes is often
more expensive than anything security_inode_permission() does, so that
spinlock becomes the main bottleneck.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |   28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3c2b36acf291..ac958f29e558 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2288,6 +2288,10 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	if (status == 0)
 		goto out_cached;
 
+	status = -ECHILD;
+	if (mask & MAY_NOT_BLOCK)
+		goto out;
+
 	/* Be clever: ask server to check for all possible rights */
 	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
 	cache.cred = cred;
@@ -2364,15 +2368,23 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
-	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
-
-	cred = rpc_lookup_cred();
-	if (!IS_ERR(cred)) {
-		res = nfs_do_access(inode, cred, mask);
-		put_rpccred(cred);
-	} else
+	/* Always try fast lookups first */
+	rcu_read_lock();
+	cred = rpc_lookup_cred_nonblock();
+	if (!IS_ERR(cred))
+		res = nfs_do_access(inode, cred, mask|MAY_NOT_BLOCK);
+	else
 		res = PTR_ERR(cred);
+	rcu_read_unlock();
+	if (res == -ECHILD && !(mask & MAY_NOT_BLOCK)) {
+		/* Fast lookup failed, try the slow way */
+		cred = rpc_lookup_cred();
+		if (!IS_ERR(cred)) {
+			res = nfs_do_access(inode, cred, mask);
+			put_rpccred(cred);
+		} else
+			res = PTR_ERR(cred);
+	}
 out:
 	if (!res && (mask & MAY_EXEC) && !execute_ok(inode))
 		res = -EACCES;


