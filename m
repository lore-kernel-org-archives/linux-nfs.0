Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53425 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbaGNBba (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:31:30 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 5/7] NFS: teach nfs_neg_need_reval to understand LOOKUP_RCU
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714012820.12562.59239.stgit@notabene.brown>
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
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

If RCU_WALK prevents nfs_check_verifier or nfs_neg_need_reval from
doing a full check, they return a status indicating that a revalidation
is required.  As this revalidation will not be possible in RCU_WALK
mode, -ECHILD will ultimately be returned, which is the desired result.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c           |   59 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/inode.c         |    9 +++++++
 include/linux/nfs_fs.h |    1 +
 3 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ac958f29e558..de9bc809c7ea 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -988,9 +988,13 @@ EXPORT_SYMBOL_GPL(nfs_force_lookup_revalidate);
  * A check for whether or not the parent directory has changed.
  * In the case it has, we assume that the dentries are untrustworthy
  * and may need to be looked up again.
+ * If rcu_walk prevents us from performing a full check, return 0.
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
@@ -998,7 +1002,11 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
 	/* Revalidate nfsi->cache_change_attribute before we declare a match */
-	if (nfs_revalidate_inode(NFS_SERVER(dir), dir) < 0)
+	if (rcu_walk)
+		ret = nfs_revalidate_inode_rcu(NFS_SERVER(dir), dir);
+	else
+		ret = nfs_revalidate_inode(NFS_SERVER(dir), dir);
+	if (ret < 0)
 		return 0;
 	if (!nfs_verify_change_attribute(dir, dentry->d_time))
 		return 0;
@@ -1054,6 +1062,9 @@ out_force:
  *
  * If parent mtime has changed, we revalidate, else we wait for a
  * period corresponding to the parent's attribute cache timeout value.
+ *
+ * If LOOKUP_RCU prevents us from performing a full check, return 1
+ * suggesting a reval is needed.
  */
 static inline
 int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
@@ -1064,7 +1075,7 @@ int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry,
 		return 0;
 	if (NFS_SERVER(dir)->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG)
 		return 1;
-	return !nfs_check_verifier(dir, dentry);
+	return !nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU);
 }
 
 /*
@@ -1101,11 +1112,11 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
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
 
@@ -1120,16 +1131,21 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
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
 	}
 
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	if (NFS_STALE(inode))
 		goto out_bad;
 
@@ -1566,14 +1582,23 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		struct dentry *parent;
 		struct inode *dir;
 
-		if (flags & LOOKUP_RCU)
-			return -ECHILD;
-
-		parent = dget_parent(dentry);
-		dir = parent->d_inode;
+		if (flags & LOOKUP_RCU) {
+			parent = rcu_dereference(dentry);
+			dir = ACCESS_ONCE(parent->d_inode);
+			if (!dir)
+				return -ECHILD;
+		} else {
+			parent = dget_parent(dentry);
+			dir = parent->d_inode;
+		}
 		if (!nfs_neg_need_reval(dir, dentry, flags))
 			ret = 1;
-		dput(parent);
+		else if (flags & LOOKUP_RCU)
+			ret = -ECHILD;
+		if (!(flags & LOOKUP_RCU))
+			dput(parent);
+		else if (parent != rcu_dereference(dentry))
+			return -ECHILD;
 		goto out;
 	}
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index abd37a380535..432b6c4bea47 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1002,6 +1002,15 @@ int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
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
index e30f6059ecd6..60cd9e377926 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -352,6 +352,7 @@ extern int nfs_release(struct inode *, struct file *);
 extern int nfs_attribute_timeout(struct inode *inode);
 extern int nfs_attribute_cache_expired(struct inode *inode);
 extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
+extern int nfs_revalidate_inode_rcu(struct nfs_server *server, struct inode *inode);
 extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
 extern int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
 extern int nfs_setattr(struct dentry *, struct iattr *);


