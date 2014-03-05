Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52092 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755165AbaCEDB0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 22:01:26 -0500
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 05 Mar 2014 14:00:28 +1100
Subject: [PATCH 2/8] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140305030028.27421.92032.stgit@notabene.brown>
In-Reply-To: <20140305025813.27421.23871.stgit@notabene.brown>
References: <20140305025813.27421.23871.stgit@notabene.brown>
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

In nfs4_lookup_revalidate we simple avoid testing LOOKUP_RCU on the
path that simply calls nfs_lookup_revalidate() as that function
already performs the required test.



Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/dir.c |   36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f5509f95f261..dcec2c56fe13 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1056,14 +1056,17 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	int error;
 
 	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
-	parent = dget_parent(dentry);
+		parent = rcu_dereference(dentry->d_parent);
+	else
+		parent = dget_parent(dentry);
 	dir = parent->d_inode;
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode = dentry->d_inode;
 
 	if (!inode) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		if (nfs_neg_need_reval(dir, dentry, flags))
 			goto out_bad;
 		goto out_valid_noent;
@@ -1078,6 +1081,9 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
 
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentry)) {
 		if (nfs_lookup_verify_inode(inode, flags))
@@ -1120,7 +1126,8 @@ out_set_verifier:
 	/* Success: notify readdir to use READDIRPLUS */
 	nfs_advise_use_readdirplus(dir);
  out_valid_noent:
-	dput(parent);
+	if (!(flags & LOOKUP_RCU))
+		dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is valid\n",
 			__func__, dentry);
 	return 1;
@@ -1147,7 +1154,8 @@ out_zap_parent:
 	if (check_submounts_and_drop(dentry) != 0)
 		goto out_valid;
 
-	dput(parent);
+	if (!(flags & LOOKUP_RCU))
+		dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is invalid\n",
 			__func__, dentry);
 	return 0;
@@ -1155,7 +1163,8 @@ out_error:
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
-	dput(parent);
+	if (!(flags & LOOKUP_RCU))
+		dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) lookup returned error %d\n",
 			__func__, dentry, error);
 	return error;
@@ -1499,9 +1508,6 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	struct inode *inode;
 	int ret = 0;
 
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
 	if (!(flags & LOOKUP_OPEN) || (flags & LOOKUP_DIRECTORY))
 		goto no_open;
 	if (d_mountpoint(dentry))
@@ -1518,6 +1524,9 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 		struct dentry *parent;
 		struct inode *dir;
 
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		parent = dget_parent(dentry);
 		dir = parent->d_inode;
 		if (!nfs_neg_need_reval(dir, dentry, flags))
@@ -2273,9 +2282,6 @@ int nfs_permission(struct inode *inode, int mask)
 	struct rpc_cred *cred;
 	int res = 0;
 
-	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
-
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
 
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
@@ -2302,6 +2308,9 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
 
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	cred = rpc_lookup_cred();
 	if (!IS_ERR(cred)) {
 		res = nfs_do_access(inode, cred, mask);
@@ -2316,6 +2325,9 @@ out:
 		inode->i_sb->s_id, inode->i_ino, mask, res);
 	return res;
 out_notsup:
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	res = nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (res == 0)
 		res = generic_permission(inode, mask);


