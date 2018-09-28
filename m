Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt1-f194.google.com ([209.85.160.194]:34908 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726405AbeI2C2q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2018 22:28:46 -0400
Received: by mail-qt1-f194.google.com with SMTP id z14-v6so8043058qtn.2
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 13:03:26 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Stan Hu <stanhu@gmail.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Fix lookup revalidate of regular files
Date: Fri, 28 Sep 2018 16:02:58 -0400
Message-Id: <20180928200258.68552-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180928200258.68552-3-trond.myklebust@hammerspace.com>
References: <20180928200258.68552-1-trond.myklebust@hammerspace.com>
 <20180928200258.68552-2-trond.myklebust@hammerspace.com>
 <20180928200258.68552-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're revalidating an existing dentry in order to open a file, we need
to ensure that we check the directory has not changed before we optimise
away the lookup.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 79 ++++++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2e6a253e4104..71b2e390becf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1231,7 +1231,8 @@ nfs_do_lookup_revalidate(struct inode *dir, struct dentry *dentry,
 }
 
 static int
-nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+__nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags,
+			int (*reval)(struct inode *, struct dentry *, unsigned int))
 {
 	struct dentry *parent;
 	struct inode *dir;
@@ -1242,17 +1243,22 @@ nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		dir = d_inode_rcu(parent);
 		if (!dir)
 			return -ECHILD;
-		ret = nfs_do_lookup_revalidate(dir, dentry, flags);
+		ret = reval(dir, dentry, flags);
 		if (parent != READ_ONCE(dentry->d_parent))
 			return -ECHILD;
 	} else {
 		parent = dget_parent(dentry);
-		ret = nfs_do_lookup_revalidate(d_inode(parent), dentry, flags);
+		ret = reval(d_inode(parent), dentry, flags);
 		dput(parent);
 	}
 	return ret;
 }
 
+static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+{
+	return __nfs_lookup_revalidate(dentry, flags, nfs_do_lookup_revalidate);
+}
+
 /*
  * A weaker form of d_revalidate for revalidating just the d_inode(dentry)
  * when we don't really care about the dentry name. This is called when a
@@ -1609,62 +1615,55 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 }
 EXPORT_SYMBOL_GPL(nfs_atomic_open);
 
-static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+static int
+nfs4_do_lookup_revalidate(struct inode *dir, struct dentry *dentry,
+			  unsigned int flags)
 {
 	struct inode *inode;
-	int ret = 0;
 
 	if (!(flags & LOOKUP_OPEN) || (flags & LOOKUP_DIRECTORY))
-		goto no_open;
+		goto full_reval;
 	if (d_mountpoint(dentry))
-		goto no_open;
-	if (NFS_SB(dentry->d_sb)->caps & NFS_CAP_ATOMIC_OPEN_V1)
-		goto no_open;
+		goto full_reval;
 
 	inode = d_inode(dentry);
 
 	/* We can't create new files in nfs_open_revalidate(), so we
 	 * optimize away revalidation of negative dentries.
 	 */
-	if (inode == NULL) {
-		struct dentry *parent;
-		struct inode *dir;
-
-		if (flags & LOOKUP_RCU) {
-			parent = READ_ONCE(dentry->d_parent);
-			dir = d_inode_rcu(parent);
-			if (!dir)
-				return -ECHILD;
-		} else {
-			parent = dget_parent(dentry);
-			dir = d_inode(parent);
-		}
-		if (!nfs_neg_need_reval(dir, dentry, flags))
-			ret = 1;
-		else if (flags & LOOKUP_RCU)
-			ret = -ECHILD;
-		if (!(flags & LOOKUP_RCU))
-			dput(parent);
-		else if (parent != READ_ONCE(dentry->d_parent))
-			return -ECHILD;
-		goto out;
-	}
+	if (inode == NULL)
+		goto full_reval;
+
+	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
+		return nfs_lookup_revalidate_delegated(dir, dentry, inode);
 
 	/* NFS only supports OPEN on regular files */
 	if (!S_ISREG(inode->i_mode))
-		goto no_open;
+		goto full_reval;
+
 	/* We cannot do exclusive creation on a positive dentry */
-	if (flags & LOOKUP_EXCL)
-		goto no_open;
+	if (flags & (LOOKUP_EXCL | LOOKUP_REVAL))
+		goto reval_dentry;
+
+	/* Check if the directory changed */
+	if (!nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU))
+		goto reval_dentry;
 
 	/* Let f_op->open() actually open (and revalidate) the file */
-	ret = 1;
+	return 1;
+reval_dentry:
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+	return nfs_lookup_revalidate_dentry(dir, dentry, inode);;
 
-out:
-	return ret;
+full_reval:
+	return nfs_do_lookup_revalidate(dir, dentry, flags);
+}
 
-no_open:
-	return nfs_lookup_revalidate(dentry, flags);
+static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+{
+	return __nfs_lookup_revalidate(dentry, flags,
+			nfs4_do_lookup_revalidate);
 }
 
 #endif /* CONFIG_NFSV4 */
-- 
2.17.1
