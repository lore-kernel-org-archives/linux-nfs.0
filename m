Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:9888 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdHBUvu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Aug 2017 16:51:50 -0400
From: Anna.Schumaker@Netapp.com
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFS: Don't compare apples to elephants to determine access bits
Date: Wed,  2 Aug 2017 16:51:26 -0400
Message-ID: <20170802205126.23239-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170802205126.23239-1-Anna.Schumaker@Netapp.com>
References: <20170802205126.23239-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The NFS_ACCESS_* flags aren't a 1:1 mapping to the MAY_* flags, so
checking for MAY_WHATEVER might have surprising results in
nfs*_proc_access().  Let's simplify this check when determining which
bits to ask for, and do it in a generic place instead of copying code
for each NFS version.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/dir.c      | 11 ++++++++---
 fs/nfs/nfs3proc.c | 17 +----------------
 fs/nfs/nfs4proc.c | 19 +------------------
 3 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 84de36be286d..1a62fde077fe 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2428,9 +2428,14 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
 	if (!may_block)
 		goto out;
 
-	/* Be clever: ask server to check for all possible rights */
-	cache.mask = NFS_MAY_LOOKUP | NFS_MAY_EXECUTE
-		     | NFS_MAY_WRITE | NFS_MAY_READ;
+	/*
+	 * Determine which access bits we want to ask for...
+	 */
+	cache.mask = NFS_ACCESS_READ | NFS_ACCESS_MODIFY | NFS_ACCESS_EXTEND;
+	if (S_ISDIR(inode->i_mode))
+		cache.mask |= NFS_ACCESS_DELETE | NFS_ACCESS_LOOKUP;
+	else
+		cache.mask |= NFS_ACCESS_EXECUTE;
 	cache.cred = cred;
 	cache.jiffies = jiffies;
 	status = NFS_PROTO(inode)->access(inode, &cache);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index d1e87ec0df84..44bf961d5812 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -187,6 +187,7 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs3_accessargs	arg = {
 		.fh		= NFS_FH(inode),
+		.access		= entry->mask,
 	};
 	struct nfs3_accessres	res;
 	struct rpc_message msg = {
@@ -195,25 +196,9 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		.rpc_resp	= &res,
 		.rpc_cred	= entry->cred,
 	};
-	int mode = entry->mask;
 	int status = -ENOMEM;
 
 	dprintk("NFS call  access\n");
-
-	if (mode & MAY_READ)
-		arg.access |= NFS3_ACCESS_READ;
-	if (S_ISDIR(inode->i_mode)) {
-		if (mode & MAY_WRITE)
-			arg.access |= NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND | NFS3_ACCESS_DELETE;
-		if (mode & MAY_EXEC)
-			arg.access |= NFS3_ACCESS_LOOKUP;
-	} else {
-		if (mode & MAY_WRITE)
-			arg.access |= NFS3_ACCESS_MODIFY | NFS3_ACCESS_EXTEND;
-		if (mode & MAY_EXEC)
-			arg.access |= NFS3_ACCESS_EXECUTE;
-	}
-
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
 		goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18ca6879d8de..c7544a9cbcbb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3864,6 +3864,7 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs4_accessargs args = {
 		.fh = NFS_FH(inode),
 		.bitmask = server->cache_consistency_bitmask,
+		.access = entry->mask,
 	};
 	struct nfs4_accessres res = {
 		.server = server,
@@ -3874,26 +3875,8 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
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
-
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
 		return -ENOMEM;
-- 
2.13.3

