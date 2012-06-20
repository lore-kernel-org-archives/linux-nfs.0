Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65521 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757970Ab2FTTyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:08 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] NFS: Create a return_delegation rpc op
Date: Wed, 20 Jun 2012 15:53:44 -0400
Message-Id: <1340222029-18027-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Delegations are a v4 feature, so push return_delegation out of the
generic client by creating a new rpc_op and renaming the old function to
be in the nfs v4 "namespace"

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/delegation.c     | 2 +-
 fs/nfs/delegation.h     | 8 +-------
 fs/nfs/dir.c            | 8 ++++----
 fs/nfs/inode.c          | 2 +-
 fs/nfs/nfs3proc.c       | 7 +++++++
 fs/nfs/nfs4proc.c       | 7 ++++---
 fs/nfs/proc.c           | 7 +++++++
 fs/nfs/unlink.c         | 2 +-
 include/linux/nfs_xdr.h | 1 +
 9 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 36c7c64..81c5eec 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -388,7 +388,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
  *
  * Returns zero on success, or a negative errno value.
  */
-int nfs_inode_return_delegation(struct inode *inode)
+int nfs4_inode_return_delegation(struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index d134fc5..1f3ccd9 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -33,7 +33,7 @@ enum {
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
 void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-int nfs_inode_return_delegation(struct inode *inode);
+int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 
@@ -58,12 +58,6 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
 
-#else
-static inline int nfs_inode_return_delegation(struct inode *inode)
-{
-	nfs_wb_all(inode);
-	return 0;
-}
 #endif
 
 static inline int nfs_have_delegated_attributes(struct inode *inode)
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a3e23a..68e451f 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1778,7 +1778,7 @@ static int nfs_safe_remove(struct dentry *dentry)
 	}
 
 	if (inode != NULL) {
-		nfs_inode_return_delegation(inode);
+		NFS_PROTO(inode)->return_delegation(inode);
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
 		/* The VFS may want to delete this inode */
 		if (error == 0)
@@ -1906,7 +1906,7 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	nfs_inode_return_delegation(inode);
+	NFS_PROTO(inode)->return_delegation(inode);
 
 	d_drop(dentry);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
@@ -1990,9 +1990,9 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		}
 	}
 
-	nfs_inode_return_delegation(old_inode);
+	NFS_PROTO(old_inode)->return_delegation(old_inode);
 	if (new_inode != NULL)
-		nfs_inode_return_delegation(new_inode);
+		NFS_PROTO(new_inode)->return_delegation(new_inode);
 
 	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
 					   new_dir, &new_dentry->d_name);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 0f0b928..28c9ebb 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -430,7 +430,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 	 * Return any delegations if we're going to change ACLs
 	 */
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) != 0)
-		nfs_inode_return_delegation(inode);
+		NFS_PROTO(inode)->return_delegation(inode);
 	error = NFS_PROTO(inode)->setattr(dentry, fattr, attr);
 	if (error == 0)
 		nfs_refresh_inode(inode, fattr);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 08f8326..4749a32 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -882,6 +882,12 @@ static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
+static int nfs3_return_delegation(struct inode *inode)
+{
+	nfs_wb_all(inode);
+	return 0;
+}
+
 const struct nfs_rpc_ops nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
@@ -927,5 +933,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.clear_acl_cache = nfs3_forget_cached_acls,
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs3_have_delegation,
+	.return_delegation = nfs3_return_delegation,
 	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 993d6ec..b2cd0f1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -295,7 +295,7 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			return 0;
 		case -NFS4ERR_OPENMODE:
 			if (inode && nfs4_have_delegation(inode, FMODE_READ)) {
-				nfs_inode_return_delegation(inode);
+				nfs4_inode_return_delegation(inode);
 				exception->retry = 1;
 				return 0;
 			}
@@ -1065,7 +1065,7 @@ static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmo
 		return;
 	}
 	rcu_read_unlock();
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 }
 
 static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
@@ -3868,7 +3868,7 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
 	if (i < 0)
 		return i;
-	nfs_inode_return_delegation(inode);
+	nfs4_inode_return_delegation(inode);
 	ret = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 
 	/*
@@ -6803,6 +6803,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
 	.have_delegation = nfs4_have_delegation,
+	.return_delegation = nfs4_inode_return_delegation,
 	.init_client	= nfs4_init_client,
 };
 
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4aed3dd..1663293 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -739,6 +739,12 @@ static int nfs_have_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
+static int nfs_return_delegation(struct inode *inode)
+{
+	nfs_wb_all(inode);
+	return 0;
+}
+
 const struct nfs_rpc_ops nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
@@ -783,5 +789,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs_have_delegation,
+	.return_delegation = nfs_return_delegation,
 	.init_client	= nfs_init_client,
 };
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3210a03..13cea63 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -501,7 +501,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 		(unsigned long long)NFS_FILEID(dentry->d_inode));
 
 	/* Return delegation in anticipation of the rename */
-	nfs_inode_return_delegation(dentry->d_inode);
+	NFS_PROTO(dentry->d_inode)->return_delegation(dentry->d_inode);
 
 	sdentry = NULL;
 	do {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 8787f77..62235be 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1423,6 +1423,7 @@ struct nfs_rpc_ops {
 				int open_flags,
 				struct iattr *iattr);
 	int (*have_delegation)(struct inode *, fmode_t);
+	int (*return_delegation)(struct inode *);
 	struct nfs_client *
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t);
-- 
1.7.11

