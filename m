Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f194.google.com ([209.85.222.194]:34596 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726405AbeI2C2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2018 22:28:45 -0400
Received: by mail-qk1-f194.google.com with SMTP id 80-v6so4670417qkj.1
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 13:03:25 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Stan Hu <stanhu@gmail.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: Refactor nfs_lookup_revalidate()
Date: Fri, 28 Sep 2018 16:02:57 -0400
Message-Id: <20180928200258.68552-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180928200258.68552-2-trond.myklebust@hammerspace.com>
References: <20180928200258.68552-1-trond.myklebust@hammerspace.com>
 <20180928200258.68552-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor the code in nfs_lookup_revalidate() as a stepping stone towards
optimising and fixing nfs4_lookup_revalidate().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 222 +++++++++++++++++++++++++++++----------------------
 1 file changed, 126 insertions(+), 96 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8bfaa658b2c1..2e6a253e4104 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1072,6 +1072,100 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 	return !nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU);
 }
 
+static int
+nfs_lookup_revalidate_done(struct inode *dir, struct dentry *dentry,
+			   struct inode *inode, int error)
+{
+	switch (error) {
+	case 1:
+		dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is valid\n",
+			__func__, dentry);
+		return 1;
+	case 0:
+		nfs_mark_for_revalidate(dir);
+		if (inode && S_ISDIR(inode->i_mode)) {
+			/* Purge readdir caches. */
+			nfs_zap_caches(inode);
+			/*
+			 * We can't d_drop the root of a disconnected tree:
+			 * its d_hash is on the s_anon list and d_drop() would hide
+			 * it from shrink_dcache_for_unmount(), leading to busy
+			 * inodes on unmount and further oopses.
+			 */
+			if (IS_ROOT(dentry))
+				return 1;
+		}
+		dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is invalid\n",
+				__func__, dentry);
+		return 0;
+	}
+	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) lookup returned error %d\n",
+				__func__, dentry, error);
+	return error;
+}
+
+static int
+nfs_lookup_revalidate_negative(struct inode *dir, struct dentry *dentry,
+			       unsigned int flags)
+{
+	int ret = 1;
+	if (nfs_neg_need_reval(dir, dentry, flags)) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+		ret = 0;
+	}
+	return nfs_lookup_revalidate_done(dir, dentry, NULL, ret);
+}
+
+static int
+nfs_lookup_revalidate_delegated(struct inode *dir, struct dentry *dentry,
+				struct inode *inode)
+{
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+	return nfs_lookup_revalidate_done(dir, dentry, inode, 1);
+}
+
+static int
+nfs_lookup_revalidate_dentry(struct inode *dir, struct dentry *dentry,
+			     struct inode *inode)
+{
+	struct nfs_fh *fhandle;
+	struct nfs_fattr *fattr;
+	struct nfs4_label *label;
+	int ret;
+
+	ret = -ENOMEM;
+	fhandle = nfs_alloc_fhandle();
+	fattr = nfs_alloc_fattr();
+	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
+	if (fhandle == NULL || fattr == NULL || IS_ERR(label))
+		goto out;
+
+	ret = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
+	if (ret < 0) {
+		if (ret == -ESTALE || ret == -ENOENT)
+			ret = 0;
+		goto out;
+	}
+	ret = 0;
+	if (nfs_compare_fh(NFS_FH(inode), fhandle))
+		goto out;
+	if (nfs_refresh_inode(inode, fattr) < 0)
+		goto out;
+
+	nfs_setsecurity(inode, fattr, label);
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+
+	/* set a readdirplus hint that we had a cache miss */
+	nfs_force_use_readdirplus(dir);
+	ret = 1;
+out:
+	nfs_free_fattr(fattr);
+	nfs_free_fhandle(fhandle);
+	nfs4_label_free(label);
+	return nfs_lookup_revalidate_done(dir, dentry, inode, ret);
+}
+
 /*
  * This is called every time the dcache has a lookup hit,
  * and we should check whether we can really trust that
@@ -1083,58 +1177,36 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
  * If the parent directory is seen to have changed, we throw out the
  * cached dentry and do a new lookup.
  */
-static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+static int
+nfs_do_lookup_revalidate(struct inode *dir, struct dentry *dentry,
+			 unsigned int flags)
 {
-	struct inode *dir;
 	struct inode *inode;
-	struct dentry *parent;
-	struct nfs_fh *fhandle = NULL;
-	struct nfs_fattr *fattr = NULL;
-	struct nfs4_label *label = NULL;
 	int error;
 
-	if (flags & LOOKUP_RCU) {
-		parent = READ_ONCE(dentry->d_parent);
-		dir = d_inode_rcu(parent);
-		if (!dir)
-			return -ECHILD;
-	} else {
-		parent = dget_parent(dentry);
-		dir = d_inode(parent);
-	}
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode = d_inode(dentry);
 
-	if (!inode) {
-		if (nfs_neg_need_reval(dir, dentry, flags)) {
-			if (flags & LOOKUP_RCU)
-				return -ECHILD;
-			goto out_bad;
-		}
-		goto out_valid;
-	}
+	if (!inode)
+		return nfs_lookup_revalidate_negative(dir, dentry, flags);
 
 	if (is_bad_inode(inode)) {
-		if (flags & LOOKUP_RCU)
-			return -ECHILD;
 		dfprintk(LOOKUPCACHE, "%s: %pd2 has dud inode\n",
 				__func__, dentry);
 		goto out_bad;
 	}
 
 	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
-		goto out_set_verifier;
+		return nfs_lookup_revalidate_delegated(dir, dentry, inode);
 
 	/* Force a full look up iff the parent directory has changed */
 	if (!(flags & (LOOKUP_EXCL | LOOKUP_REVAL)) &&
 	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
 		error = nfs_lookup_verify_inode(inode, flags);
 		if (error) {
-			if (flags & LOOKUP_RCU)
-				return -ECHILD;
 			if (error == -ESTALE)
-				goto out_zap_parent;
-			goto out_error;
+				nfs_zap_caches(dir);
+			goto out_bad;
 		}
 		nfs_advise_use_readdirplus(dir);
 		goto out_valid;
@@ -1146,81 +1218,39 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (NFS_STALE(inode))
 		goto out_bad;
 
-	error = -ENOMEM;
-	fhandle = nfs_alloc_fhandle();
-	fattr = nfs_alloc_fattr();
-	if (fhandle == NULL || fattr == NULL)
-		goto out_error;
-
-	label = nfs4_label_alloc(NFS_SERVER(inode), GFP_NOWAIT);
-	if (IS_ERR(label))
-		goto out_error;
-
 	trace_nfs_lookup_revalidate_enter(dir, dentry, flags);
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, label);
+	error = nfs_lookup_revalidate_dentry(dir, dentry, inode);
 	trace_nfs_lookup_revalidate_exit(dir, dentry, flags, error);
-	if (error == -ESTALE || error == -ENOENT)
-		goto out_bad;
-	if (error)
-		goto out_error;
-	if (nfs_compare_fh(NFS_FH(inode), fhandle))
-		goto out_bad;
-	if ((error = nfs_refresh_inode(inode, fattr)) != 0)
-		goto out_bad;
-
-	nfs_setsecurity(inode, fattr, label);
-
-	nfs_free_fattr(fattr);
-	nfs_free_fhandle(fhandle);
-	nfs4_label_free(label);
+	return error;
+out_valid:
+	return nfs_lookup_revalidate_done(dir, dentry, inode, 1);
+out_bad:
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+	return nfs_lookup_revalidate_done(dir, dentry, inode, 0);
+}
 
-	/* set a readdirplus hint that we had a cache miss */
-	nfs_force_use_readdirplus(dir);
+static int
+nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
+{
+	struct dentry *parent;
+	struct inode *dir;
+	int ret;
 
-out_set_verifier:
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
- out_valid:
 	if (flags & LOOKUP_RCU) {
+		parent = READ_ONCE(dentry->d_parent);
+		dir = d_inode_rcu(parent);
+		if (!dir)
+			return -ECHILD;
+		ret = nfs_do_lookup_revalidate(dir, dentry, flags);
 		if (parent != READ_ONCE(dentry->d_parent))
 			return -ECHILD;
-	} else
+	} else {
+		parent = dget_parent(dentry);
+		ret = nfs_do_lookup_revalidate(d_inode(parent), dentry, flags);
 		dput(parent);
-	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is valid\n",
-			__func__, dentry);
-	return 1;
-out_zap_parent:
-	nfs_zap_caches(dir);
- out_bad:
-	WARN_ON(flags & LOOKUP_RCU);
-	nfs_free_fattr(fattr);
-	nfs_free_fhandle(fhandle);
-	nfs4_label_free(label);
-	nfs_mark_for_revalidate(dir);
-	if (inode && S_ISDIR(inode->i_mode)) {
-		/* Purge readdir caches. */
-		nfs_zap_caches(inode);
-		/*
-		 * We can't d_drop the root of a disconnected tree:
-		 * its d_hash is on the s_anon list and d_drop() would hide
-		 * it from shrink_dcache_for_unmount(), leading to busy
-		 * inodes on unmount and further oopses.
-		 */
-		if (IS_ROOT(dentry))
-			goto out_valid;
 	}
-	dput(parent);
-	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is invalid\n",
-			__func__, dentry);
-	return 0;
-out_error:
-	WARN_ON(flags & LOOKUP_RCU);
-	nfs_free_fattr(fattr);
-	nfs_free_fhandle(fhandle);
-	nfs4_label_free(label);
-	dput(parent);
-	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) lookup returned error %d\n",
-			__func__, dentry, error);
-	return error;
+	return ret;
 }
 
 /*
-- 
2.17.1
