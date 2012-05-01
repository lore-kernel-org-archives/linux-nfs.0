Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9515 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab2EAWGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 18:06:25 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Subject: [PATCH] NFS: Adapt readdirplus to application usage patterns
Date: Tue,  1 May 2012 18:06:23 -0400
Message-Id: <1335909983-26413-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While the use of READDIRPLUS is significantly more efficient than
READDIR followed by many LOOKUP calls, it is still less efficient
than just READDIR if the attributes are not required.

This patch tracks when lookups are attempted on the directory,
and uses that information to selectively disable READDIRPLUS
on that directory.
The first 'readdir' call is always served using READDIRPLUS.
Subsequent calls only use READDIRPLUS if there was a successful
lookup or revalidation on a child in the mean time.

Credit for the original idea should go to Neil Brown. See:
      http://www.spinics.net/lists/linux-nfs/msg19996.html
However, the implementation in this patch differs from Neil's
in that it focuses on tracking lookups rather than calls to
stat().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>
---
 fs/nfs/dir.c           |   35 +++++++++++++++++++++++++++++++++--
 fs/nfs/inode.c         |    2 --
 include/linux/nfs_fs.h |    5 -----
 3 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 82b42e2..03a0220 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -475,6 +475,29 @@ different:
 }
 
 static
+bool nfs_use_readdirplus(struct inode *dir, struct file *filp)
+{
+	if (!nfs_server_capable(dir, NFS_CAP_READDIRPLUS))
+		return false;
+	if (test_and_clear_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags))
+		return true;
+	if (filp->f_pos == 0)
+		return true;
+	return false;
+}
+
+/*
+ * This function is called by the lookup code to request the use of
+ * readdirplus to accelerate any future lookups in the same
+ * directory.
+ */
+static
+void nfs_advise_use_readdirplus(struct inode *dir)
+{
+	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
+}
+
+static
 void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 {
 	struct qstr filename = {
@@ -874,7 +897,9 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->file = filp;
 	desc->dir_cookie = &dir_ctx->dir_cookie;
 	desc->decode = NFS_PROTO(inode)->decode_dirent;
-	desc->plus = NFS_USE_READDIRPLUS(inode);
+	desc->plus = 0;
+	if (nfs_use_readdirplus(inode, filp))
+		desc->plus = 1;
 
 	nfs_block_sillyrename(dentry);
 	res = nfs_revalidate_mapping(inode, filp->f_mapping);
@@ -1114,7 +1139,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	if (!inode) {
 		if (nfs_neg_need_reval(dir, dentry, nd))
 			goto out_bad;
-		goto out_valid;
+		goto out_valid_noent;
 	}
 
 	if (is_bad_inode(inode)) {
@@ -1156,6 +1181,9 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 out_set_verifier:
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
  out_valid:
+	/* Success: notify readdir to use READDIRPLUS */
+	nfs_advise_use_readdirplus(dir);
+ out_valid_noent:
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is valid\n",
 			__func__, dentry->d_parent->d_name.name,
@@ -1311,6 +1339,9 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
 	if (IS_ERR(res))
 		goto out_unblock_sillyrename;
 
+	/* Success: notify readdir to use READDIRPLUS */
+	nfs_advise_use_readdirplus(dir);
+
 no_entry:
 	res = d_materialise_unique(dentry, inode);
 	if (res != NULL) {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0d53113..9f17cd1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -298,8 +298,6 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr)
 			inode->i_op = NFS_SB(sb)->nfs_client->rpc_ops->dir_inode_ops;
 			inode->i_fop = &nfs_dir_operations;
 			inode->i_data.a_ops = &nfs_dir_aops;
-			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS))
-				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
 			/* Deal with crossing mountpoints */
 			if (fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT ||
 					fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 8a88c16..6cc7dba 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -314,11 +314,6 @@ static inline int nfs_server_capable(struct inode *inode, int cap)
 	return NFS_SERVER(inode)->caps & cap;
 }
 
-static inline int NFS_USE_READDIRPLUS(struct inode *inode)
-{
-	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(inode)->flags);
-}
-
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 {
 	dentry->d_time = verf;
-- 
1.7.7.6

