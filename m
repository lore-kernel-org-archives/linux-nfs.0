From: akpm@linux-foundation.org
Subject: [patch 4/5] nfs: path_{get,put}() cleanups
Date: Fri, 02 May 2008 13:42:45 -0700
Message-ID: <200805022042.m42KgjCR013881@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, jblunck@suse.de
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60693 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935897AbYEBUnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:43:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jan Blunck <jblunck@suse.de>

Here are some more places where path_{get,put}() can be used instead of
dput()/mntput() pair.

Signed-off-by: Jan Blunck <jblunck@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/inode.c     |    3 +--
 fs/nfs/namespace.c |    3 +--
 fs/nfs/nfs4proc.c  |    6 ++----
 3 files changed, 4 insertions(+), 8 deletions(-)

diff -puN fs/nfs/inode.c~nfs-path_getput-cleanups fs/nfs/inode.c
--- a/fs/nfs/inode.c~nfs-path_getput-cleanups
+++ a/fs/nfs/inode.c
@@ -541,8 +541,7 @@ static void __put_nfs_open_context(struc
 	}
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
-	dput(ctx->path.dentry);
-	mntput(ctx->path.mnt);
+	path_put(&ctx->path);
 	kfree(ctx);
 }
 
diff -puN fs/nfs/namespace.c~nfs-path_getput-cleanups fs/nfs/namespace.c
--- a/fs/nfs/namespace.c~nfs-path_getput-cleanups
+++ a/fs/nfs/namespace.c
@@ -137,8 +137,7 @@ static void * nfs_follow_mountpoint(stru
 			goto out_follow;
 		goto out_err;
 	}
-	mntput(nd->path.mnt);
-	dput(nd->path.dentry);
+	path_put(&nd->path);
 	nd->path.mnt = mnt;
 	nd->path.dentry = dget(mnt->mnt_root);
 	schedule_delayed_work(&nfs_automount_task, nfs_mountpoint_expiry_timeout);
diff -puN fs/nfs/nfs4proc.c~nfs-path_getput-cleanups fs/nfs/nfs4proc.c
--- a/fs/nfs/nfs4proc.c~nfs-path_getput-cleanups
+++ a/fs/nfs/nfs4proc.c
@@ -306,8 +306,7 @@ static void nfs4_opendata_free(struct kr
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
 	dput(p->dir);
-	dput(p->path.dentry);
-	mntput(p->path.mnt);
+	path_put(&p->path);
 	kfree(p);
 }
 
@@ -1210,8 +1209,7 @@ static void nfs4_free_closedata(void *da
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
-	dput(calldata->path.dentry);
-	mntput(calldata->path.mnt);
+	path_put(&calldata->path);
 	kfree(calldata);
 }
 
_
