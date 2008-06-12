From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/15] NFS: Remove BKL usage from open()
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.18587.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754021AbYFLTtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:23 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnMHU008552
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:22 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All the NFSv4 stateful operations are already protected by other locks (in
particular by the rpc_sequence locks.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c      |    6 ------
 fs/nfs/file.c     |    2 --
 fs/nfs/nfs4proc.c |    2 --
 3 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a42ed8f..4ba889b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -139,10 +139,8 @@ nfs_opendir(struct inode *inode, struct file *filp)
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
 
-	lock_kernel();
 	/* Call generic open code in order to cache credentials */
 	res = nfs_open(inode, filp);
-	unlock_kernel();
 	return res;
 }
 
@@ -1019,9 +1017,7 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 	}
 
 	/* Open the file on the server */
-	lock_kernel();
 	res = nfs4_atomic_open(dir, dentry, nd);
-	unlock_kernel();
 	if (IS_ERR(res)) {
 		error = PTR_ERR(res);
 		switch (error) {
@@ -1083,9 +1079,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	 * operations that change the directory. We therefore save the
 	 * change attribute *before* we do the RPC call.
 	 */
-	lock_kernel();
 	ret = nfs4_open_revalidate(dir, dentry, openflags, nd);
-	unlock_kernel();
 out:
 	dput(parent);
 	if (!ret)
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f919d9a..9f1bed9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -128,9 +128,7 @@ nfs_file_open(struct inode *inode, struct file *filp)
 		return res;
 
 	nfs_inc_stats(inode, NFSIOS_VFSOPEN);
-	lock_kernel();
 	res = nfs_open(inode, filp);
-	unlock_kernel();
 	return res;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 66f13dc..affdbb9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -451,9 +451,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		/* Save the delegation */
 		memcpy(stateid.data, delegation->stateid.data, sizeof(stateid.data));
 		rcu_read_unlock();
-		lock_kernel();
 		ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
-		unlock_kernel();
 		if (ret != 0)
 			goto out;
 		ret = -EAGAIN;

