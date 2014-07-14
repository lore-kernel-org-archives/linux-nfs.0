Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53415 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbaGNBbL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:31:11 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 2/7] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714012820.12562.1238.stgit@notabene.brown>
In-Reply-To: <20140714011630.12562.1940.stgit@notabene.brown>
References: <20140714011630.12562.1940.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_lookup_revalidate, nfs4_lookup_revalidate, and nfs_permission
all need to understand and handle RCU-walk for NFS to gain the
benefits of RCU-walk for cached information.

Currently these functions all immediately return -ECHILD
if the relevant flag (LOOKUP_RCU or MAY_NOT_BLOCK) is set.

This patch pushes those tests later in the code so that we only abort
immediately before we enter rcu-unsafe code.  As subsequent patches
make that rcu-unsafe code rcu-safe, several of these new tests will
disappear.

With this patch there are several paths through the code which will no
longer return -ECHILD during an RCU-walk.  However these are mostly
error paths or other uninteresting cases.

A noteworthy change in nfs_lookup_revalidate is that we don't take
(or put) the reference to ->d_parent when LOOKUP_RCU is set.
Rather we rcu_dereference ->d_parent, and check that ->d_inode
is not NULL.  We also check that ->d_parent hasn't changed after
all the tests.

In nfs4_lookup_revalidate we simply avoid testing LOOKUP_RCU on the
path that only calls nfs_lookup_revalidate() as that function
already performs the required test.



Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |   45 +++++++++++++++++++++++++++++++++------------
 1 file changed, 33 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index c5a4a89637fb..3c2b36acf291 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1088,21 +1088,30 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	struct nfs4_label *label = NULL;
 	int error;
 
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
-	parent = dget_parent(dentry);
-	dir = parent->d_inode;
+	if (flags & LOOKUP_RCU) {
+		parent = rcu_dereference(dentry->d_parent);
+		dir = ACCESS_ONCE(parent->d_inode);
+		if (!dir)
+			return -ECHILD;
+	} else {
+		parent = dget_parent(dentry);
+		dir = parent->d_inode;
+	}
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode = dentry->d_inode;
 
 	if (!inode) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		if (nfs_neg_need_reval(dir, dentry, flags))
 			goto out_bad;
 		goto out_valid_noent;
 	}
 
 	if (is_bad_inode(inode)) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
 		dfprintk(LOOKUPCACHE, "%s: %pd2 has dud inode\n",
 				__func__, dentry);
 		goto out_bad;
@@ -1111,6 +1120,9 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
 
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentry)) {
 		if (nfs_lookup_verify_inode(inode, flags))
@@ -1153,13 +1165,18 @@ out_set_verifier:
 	/* Success: notify readdir to use READDIRPLUS */
 	nfs_advise_use_readdirplus(dir);
  out_valid_noent:
-	dput(parent);
+	if (flags & LOOKUP_RCU) {
+		if (parent != rcu_dereference(dentry->d_parent))
+			return -ECHILD;
+	} else
+		dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is valid\n",
 			__func__, dentry);
 	return 1;
 out_zap_parent:
 	nfs_zap_caches(dir);
  out_bad:
+	WARN_ON(flags & LOOKUP_RCU);
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
@@ -1185,6 +1202,7 @@ out_zap_parent:
 			__func__, dentry);
 	return 0;
 out_error:
+	WARN_ON(flags & LOOKUP_RCU);
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
@@ -1532,9 +1550,6 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	struct inode *inode;
 	int ret = 0;
 
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
 	if (!(flags & LOOKUP_OPEN) || (flags & LOOKUP_DIRECTORY))
 		goto no_open;
 	if (d_mountpoint(dentry))
@@ -1551,6 +1566,9 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		struct dentry *parent;
 		struct inode *dir;
 
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		parent = dget_parent(dentry);
 		dir = parent->d_inode;
 		if (!nfs_neg_need_reval(dir, dentry, flags))
@@ -2320,9 +2338,6 @@ int nfs_permission(struct inode *inode, int mask)
 	struct rpc_cred *cred;
 	int res = 0;
 
-	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
-
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
 
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
@@ -2349,6 +2364,9 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	cred = rpc_lookup_cred();
 	if (!IS_ERR(cred)) {
 		res = nfs_do_access(inode, cred, mask);
@@ -2363,6 +2381,9 @@ out:
 		inode->i_sb->s_id, inode->i_ino, mask, res);
 	return res;
 out_notsup:
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	res = nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (res == 0)
 		res = generic_permission(inode, mask);


