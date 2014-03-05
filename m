Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52103 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDCC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:02:02 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 6/8] NFS: teach nfs_neg_need_reval to understand LOOKUP_RCU
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.49580.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This requires nfs_check_verifier to take an rcu_walk flag, and requires
an rcu version of nfs_revalidate_inode which returns -ECHILD rather
than making an RPC call.

With this, nfs_lookup_revalidate can call nfs_neg_need_reval in
RCU-walk mode.

We can also move the LOOKUP_RCU check past the nfs_check_verifier()
call in nfs_lookup_revalidate.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c           |   47 ++++++++++++++++++++++++++++++++---------------
 fs/nfs/inode.c         |    9 +++++++++
 include/linux/nfs_fs.h |    1 +
 3 files changed, 42 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f3895325ac6a..76b5f40c8587 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -956,8 +956,11 @@ EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
  * In the case it has, we assume that the dentries are untrustworthy
  * and may need to be looked up again.
  */
-static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
+static int nfs_check_verifier(struct inode *dir, struct dentry *dentry,
+			      int rcu_walk)
 {
+	int ret;
+
 	if (IS_ROOT(dentry))
 		return 1;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
@@ -965,7 +968,13 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
 	/* Revalidate nfsi->cache_change_attribute before we declare a match */
-	if (nfs_revalidate_inode(NFS_SERVER(dir), dir) < 0)
+	if (rcu_walk)
+		ret = nfs_revalidate_inode_rcu(NFS_SERVER(dir), dir);
+	else
+		ret = nfs_revalidate_inode(NFS_SERVER(dir), dir);
+	if (ret == -ECHILD)
+		return -ECHILD;
+	if (ret < 0)
 		return 0;
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
@@ -1031,7 +1040,7 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		return 0;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
-	return !nfs_check_verifier(dir, dentry);
+	return !nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU);
 }
 
 /*
@@ -1064,11 +1073,11 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	inode = dentry->d_inode;
 
 	if (!inode) {
-		if (flags & LOOKUP_RCU)
-			return -ECHILD;
-
-		if (nfs_neg_need_reval(dir, dentry, flags))
+		if (nfs_neg_need_reval(dir, dentry, flags)) {
+			if (flags & LOOKUP_RCU)
+				return -ECHILD;
 			goto out_bad;
+		}
 		goto out_valid_noent;
 	}
 
@@ -1081,11 +1090,13 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
 
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
 	/* Force a full look up iff the parent directory has changed */
-	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentry)) {
+	if (!nfs_is_exclusive_create(dir, flags) &&
+	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
+
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		if (nfs_lookup_verify_inode(inode, flags))
 			goto out_zap_parent;
 		goto out_valid;
@@ -1094,6 +1105,9 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (NFS_STALE(inode))
 		goto out_bad;
 
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	error = -ENOMEM;
 	fhandle = nfs_alloc_fhandle();
 	fattr = nfs_alloc_fattr();
@@ -1525,13 +1539,16 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		struct inode *dir;
 
 		if (flags & LOOKUP_RCU)
-			return -ECHILD;
-
-		parent = dget_parent(dentry);
+			parent = rcu_dereference(dentry);
+		else
+			parent = dget_parent(dentry);
 		dir = parent->d_inode;
 		if (!nfs_neg_need_reval(dir, dentry, flags))
 			ret = 1;
-		dput(parent);
+		else if (flags & LOOKUP_RCU)
+			ret = -ECHILD;
+		if (!(flags & LOOKUP_RCU))
+			dput(parent);
 		goto out;
 	}
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 59e57cceeab5..6f39cadfad8c 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -962,6 +962,15 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
 
+int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode)
+{
+	if (!(NFS_I(inode)->cache_validity &
+			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
+			&& !nfs_attribute_cache_expired(inode))
+		return NFS_STALE(inode) ? -ESTALE : 0;
+	return -ECHILD;
+}
+
 static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0ae5807480f4..9e91f2cfcd01 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -351,6 +351,7 @@ extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
+extern int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);


