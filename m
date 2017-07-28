Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33720 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752204AbdG1RzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 13:55:00 -0400
From: Catalin Marinas <catalin.marinas@arm.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [RFC PATCH] NFS: Fix the access mask checks in NFSv4
Date: Fri, 28 Jul 2017 18:54:52 +0100
Message-Id: <20170728175452.49057-1-catalin.marinas@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit bd8b2441742b ("NFS: Store the raw NFS access mask in the inode's
access cache") changed the way access mask is stored in struct
nfs_access_entry. However, there a are couple of places NFSv4 code where
it still uses the generic access bits instead of the raw NFS ones (e.g.
MAY_READ instead of NFS_MAY_READ).

Fixes: bd8b2441742b ("NFS: Store the raw NFS access mask in the inode's access cache")
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

Hi Trond,

I noticed with 4.13-rc2 on an arm64 system that I get random EPERM
errors with an NFS root filesystem (only tried v4). The patch below
appears to fix the problem, as is reverting the above commit and the
next one in your series.

Looking at nfs3_proc_access(), it appears it has the same problem. Happy
to fix that as well if you think that's the right way.

Thanks.

 fs/nfs/dir.c           |  3 ++-
 fs/nfs/nfs4proc.c      | 23 ++++-------------------
 include/linux/nfs_fs.h |  1 +
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3522b1249019..828a04924770 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2381,7 +2381,7 @@ EXPORT_SYMBOL_GPL(nfs_access_add_cache);
 #define NFS_DIR_MAY_WRITE NFS_MAY_WRITE
 #define NFS_MAY_LOOKUP (NFS4_ACCESS_LOOKUP)
 #define NFS_MAY_EXECUTE (NFS4_ACCESS_EXECUTE)
-static int
+int
 nfs_access_calc_mask(u32 access_result, umode_t umode)
 {
 	int mask = 0;
@@ -2402,6 +2402,7 @@ nfs_access_calc_mask(u32 access_result, umode_t umode)
 			mask |= MAY_WRITE;
 	return mask;
 }
+EXPORT_SYMBOL_GPL(nfs_access_calc_mask);
 
 void nfs_access_set_mask(struct nfs_access_entry *entry, u32 access_result)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a0b4e1091340..b53b6ec21126 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2236,7 +2236,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 				int openflags)
 {
 	struct nfs_access_entry cache;
-	u32 mask;
+	int mask, cache_mask;
 
 	/* access call failed or for some reason the server doesn't
 	 * support any access modes -- defer access call until later */
@@ -2259,7 +2259,8 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
 
-	if ((mask & ~cache.mask & (MAY_READ | MAY_EXEC)) == 0)
+	cache_mask = nfs_access_calc_mask(cache.mask, state->inode->i_mode);
+	if ((mask & ~cache_mask & (MAY_READ | MAY_EXEC)) == 0)
 		return 0;
 
 	return -EACCES;
@@ -3870,25 +3871,9 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		.rpc_resp = &res,
 		.rpc_cred = entry->cred,
 	};
-	int mode = entry->mask;
 	int status = 0;
 
-	/*
-	 * Determine which access bits we want to ask for...
-	 */
-	if (mode & MAY_READ)
-		args.access |= NFS4_ACCESS_READ;
-	if (S_ISDIR(inode->i_mode)) {
-		if (mode & MAY_WRITE)
-			args.access |= NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND | NFS4_ACCESS_DELETE;
-		if (mode & MAY_EXEC)
-			args.access |= NFS4_ACCESS_LOOKUP;
-	} else {
-		if (mode & MAY_WRITE)
-			args.access |= NFS4_ACCESS_MODIFY | NFS4_ACCESS_EXTEND;
-		if (mode & MAY_EXEC)
-			args.access |= NFS4_ACCESS_EXECUTE;
-	}
+	args.access = entry->mask;
 
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 5cc91d6381a3..792fd5049e91 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -340,6 +340,7 @@ extern int nfs_post_op_update_inode_force_wcc_locked(struct inode *inode, struct
 extern int nfs_getattr(const struct path *, struct kstat *, u32, unsigned int);
 extern void nfs_access_add_cache(struct inode *, struct nfs_access_entry *);
 extern void nfs_access_set_mask(struct nfs_access_entry *, u32);
+extern int nfs_access_calc_mask(u32 access_result, umode_t umode);
 extern int nfs_permission(struct inode *, int);
 extern int nfs_open(struct inode *, struct file *);
 extern int nfs_attribute_cache_expired(struct inode *inode);
