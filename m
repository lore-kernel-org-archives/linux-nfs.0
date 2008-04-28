From: Jan Blunck <jblunck@suse.de>
Subject: [PATCH 2/3] NFS: path_{get,put}() cleanups
Date: Mon, 28 Apr 2008 18:37:33 +0200
Message-ID: <20080428163732.072893435@T61.localnet>
References: <20080428163731.774191296@T61.localnet>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Linux-Kernel Mailinglist <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-fsdevel Mailinglist <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are some more places where path_{get,put}() can be used instead of
dput()/mntput() pair.

Signed-off-by: Jan Blunck <jblunck@suse.de>
---
 fs/nfs/inode.c     |    3 +--
 fs/nfs/namespace.c |    3 +--
 fs/nfs/nfs4proc.c  |    6 ++----
 3 files changed, 4 insertions(+), 8 deletions(-)

Index: b/fs/nfs/inode.c
===================================================================
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -541,8 +541,7 @@ static void __put_nfs_open_context(struc
 	}
 	if (ctx->cred != NULL)
 		put_rpccred(ctx->cred);
-	dput(ctx->path.dentry);
-	mntput(ctx->path.mnt);
+	path_put(&ctx->path);
 	kfree(ctx);
 }
 
Index: b/fs/nfs/namespace.c
===================================================================
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
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
Index: b/fs/nfs/nfs4proc.c
===================================================================
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -304,8 +304,7 @@ static void nfs4_opendata_free(struct kr
 		nfs4_put_open_state(p->state);
 	nfs4_put_state_owner(p->owner);
 	dput(p->dir);
-	dput(p->path.dentry);
-	mntput(p->path.mnt);
+	path_put(&p->path);
 	kfree(p);
 }
 
@@ -1213,8 +1212,7 @@ static void nfs4_free_closedata(void *da
 	nfs4_put_open_state(calldata->state);
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_state_owner(sp);
-	dput(calldata->path.dentry);
-	mntput(calldata->path.mnt);
+	path_put(&calldata->path);
 	kfree(calldata);
 }
 


