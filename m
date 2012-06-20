Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966Ab2FTTyH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:07 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] NFS: Create a have_delegation rpc_op
Date: Wed, 20 Jun 2012 15:53:43 -0400
Message-Id: <1340222029-18027-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Delegations are a v4 feature, so push them out of the generic code.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/delegation.c     | 2 +-
 fs/nfs/delegation.h     | 9 ++-------
 fs/nfs/dir.c            | 2 +-
 fs/nfs/file.c           | 6 +++---
 fs/nfs/inode.c          | 2 +-
 fs/nfs/nfs3proc.c       | 6 ++++++
 fs/nfs/nfs4proc.c       | 5 +++--
 fs/nfs/proc.c           | 6 ++++++
 fs/nfs/write.c          | 2 +-
 include/linux/nfs_xdr.h | 1 +
 10 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 9a7a1b4..36c7c64 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -47,7 +47,7 @@ void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
  *
  * Returns one if inode has the indicated delegation, otherwise zero.
  */
-int nfs_have_delegation(struct inode *inode, fmode_t flags)
+int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 	int ret = 0;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 206db56..d134fc5 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -56,14 +56,9 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
 bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
-int nfs_have_delegation(struct inode *inode, fmode_t flags);
+int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 
 #else
-static inline int nfs_have_delegation(struct inode *inode, fmode_t flags)
-{
-	return 0;
-}
-
 static inline int nfs_inode_return_delegation(struct inode *inode)
 {
 	nfs_wb_all(inode);
@@ -73,7 +68,7 @@ static inline int nfs_inode_return_delegation(struct inode *inode)
 
 static inline int nfs_have_delegated_attributes(struct inode *inode)
 {
-	return nfs_have_delegation(inode, FMODE_READ) &&
+	return NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) &&
 		!(NFS_I(inode)->cache_validity & NFS_INO_REVAL_FORCED);
 }
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f430057..4a3e23a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1144,7 +1144,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 		goto out_bad;
 	}
 
-	if (nfs_have_delegation(inode, FMODE_READ))
+	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
 
 	/* Force a full look up iff the parent directory has changed */
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8941ac4..57a22a1 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -178,7 +178,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 	 * If we're holding a write delegation, then just start the i/o
 	 * but don't wait for completion (or send a commit).
 	 */
-	if (nfs_have_delegation(inode, FMODE_WRITE))
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
 		return filemap_fdatawrite(file->f_mapping);
 
 	/* Flush writes to the server and return any errors */
@@ -677,7 +677,7 @@ do_getlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	}
 	fl->fl_type = saved_type;
 
-	if (nfs_have_delegation(inode, FMODE_READ))
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
 		goto out_noconflict;
 
 	if (is_local)
@@ -772,7 +772,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * This makes locking act as a cache coherency point.
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-	if (!nfs_have_delegation(inode, FMODE_READ)) {
+	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
 		if (is_time_granular(&NFS_SERVER(inode)->time_delta))
 			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
 		else
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f729698..0f0b928 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1457,7 +1457,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &= ~NFS_INO_INVALID_DATA;
-	if (!nfs_have_delegation(inode, FMODE_READ) ||
+	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) ||
 			(save_cache_validity & NFS_INO_REVAL_FORCED))
 		nfsi->cache_validity |= invalid;
 
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 2292a0f..08f8326 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -877,6 +877,11 @@ nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
+static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
+{
+	return 0;
+}
+
 const struct nfs_rpc_ops nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
@@ -921,5 +926,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.lock		= nfs3_proc_lock,
 	.clear_acl_cache = nfs3_forget_cached_acls,
 	.close_context	= nfs_close_context,
+	.have_delegation = nfs3_have_delegation,
 	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a533e63..993d6ec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -294,7 +294,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 		case 0:
 			return 0;
 		case -NFS4ERR_OPENMODE:
-			if (inode && nfs_have_delegation(inode, FMODE_READ)) {
+			if (inode && nfs4_have_delegation(inode, FMODE_READ)) {
 				nfs_inode_return_delegation(inode);
 				exception->retry = 1;
 				return 0;
@@ -3464,7 +3464,7 @@ bool nfs4_write_need_cache_consistency_data(const struct nfs_write_data *data)
 	/* Otherwise, request attributes if and only if we don't hold
 	 * a delegation
 	 */
-	return nfs_have_delegation(hdr->inode, FMODE_READ) == 0;
+	return nfs4_have_delegation(hdr->inode, FMODE_READ) == 0;
 }
 
 static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_message *msg)
@@ -6802,6 +6802,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.clear_acl_cache = nfs4_zap_acl_attr,
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
+	.have_delegation = nfs4_have_delegation,
 	.init_client	= nfs4_init_client,
 };
 
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 617c741..4aed3dd 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -734,6 +734,11 @@ out_einval:
 	return -EINVAL;
 }
 
+static int nfs_have_delegation(struct inode *inode, fmode_t flags)
+{
+	return 0;
+}
+
 const struct nfs_rpc_ops nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
@@ -777,5 +782,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.lock		= nfs_proc_lock,
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
+	.have_delegation = nfs_have_delegation,
 	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ee929e5..f163355 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -410,7 +410,7 @@ static void nfs_inode_add_request(struct inode *inode, struct nfs_page *req)
 	nfs_lock_request(req);
 
 	spin_lock(&inode->i_lock);
-	if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRITE))
+	if (!nfsi->npages && NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
 		inode->i_version++;
 	set_bit(PG_MAPPED, &req->wb_flags);
 	SetPagePrivate(req->wb_page);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5c0014d..8787f77 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1422,6 +1422,7 @@ struct nfs_rpc_ops {
 				struct nfs_open_context *ctx,
 				int open_flags,
 				struct iattr *iattr);
+	int (*have_delegation)(struct inode *, fmode_t);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t);
-- 
1.7.11

