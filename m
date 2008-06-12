From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 29/37] NFS: Fix the ftruncate() credential problem
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.14478.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759549AbYFLTe7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:59 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJYwNi001817
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:34:58 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ftruncate() access checking is supposed to be performed at open() time,
just like reads and writes.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c    |    4 ++--
 fs/nfs/nfs3proc.c |    2 ++
 fs/nfs/nfs4proc.c |   47 +++++++++++++++++++++++------------------------
 fs/nfs/proc.c     |    2 ++
 4 files changed, 29 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 596c5d8..2e4ab4a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -347,7 +347,7 @@ out_no_inode:
 	goto out;
 }
 
-#define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET)
+#define NFS_VALID_ATTRS (ATTR_MODE|ATTR_UID|ATTR_GID|ATTR_SIZE|ATTR_ATIME|ATTR_ATIME_SET|ATTR_MTIME|ATTR_MTIME_SET|ATTR_FILE)
 
 int
 nfs_setattr(struct dentry *dentry, struct iattr *attr)
@@ -369,7 +369,7 @@ nfs_setattr(struct dentry *dentry, struct iattr *attr)
 
 	/* Optimization: if the end result is no change, don't RPC */
 	attr->ia_valid &= NFS_VALID_ATTRS;
-	if (attr->ia_valid == 0)
+	if ((attr->ia_valid & ~ATTR_FILE) == 0)
 		return 0;
 
 	lock_kernel();
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index c3523ad..b14b378 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -129,6 +129,8 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	int	status;
 
 	dprintk("NFS call  setattr\n");
+	if (sattr->ia_valid & ATTR_FILE)
+		msg.rpc_cred = nfs_file_cred(sattr->ia_file);
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	if (status == 0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1293e0a..15084a0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1139,8 +1139,9 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir, struct path *path, int
 	return res;
 }
 
-static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
-                struct iattr *sattr, struct nfs4_state *state)
+static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+			    struct nfs_fattr *fattr, struct iattr *sattr,
+			    struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
         struct nfs_setattrargs  arg = {
@@ -1154,9 +1155,10 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
 		.server		= server,
         };
         struct rpc_message msg = {
-                .rpc_proc       = &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
-                .rpc_argp       = &arg,
-                .rpc_resp       = &res,
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_SETATTR],
+		.rpc_argp	= &arg,
+		.rpc_resp	= &res,
+		.rpc_cred	= cred,
         };
 	unsigned long timestamp = jiffies;
 	int status;
@@ -1166,7 +1168,6 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
 	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
 		/* Use that stateid */
 	} else if (state != NULL) {
-		msg.rpc_cred = state->owner->so_cred;
 		nfs4_copy_stateid(&arg.stateid, state, current->files);
 	} else
 		memcpy(&arg.stateid, &zero_stateid, sizeof(arg.stateid));
@@ -1177,15 +1178,16 @@ static int _nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
 	return status;
 }
 
-static int nfs4_do_setattr(struct inode *inode, struct nfs_fattr *fattr,
-                struct iattr *sattr, struct nfs4_state *state)
+static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+			   struct nfs_fattr *fattr, struct iattr *sattr,
+			   struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_do_setattr(inode, fattr, sattr, state),
+				_nfs4_do_setattr(inode, cred, fattr, sattr, state),
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -1647,29 +1649,25 @@ static int
 nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		  struct iattr *sattr)
 {
-	struct rpc_cred *cred;
 	struct inode *inode = dentry->d_inode;
-	struct nfs_open_context *ctx;
+	struct rpc_cred *cred = NULL;
 	struct nfs4_state *state = NULL;
 	int status;
 
 	nfs_fattr_init(fattr);
 	
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
-
 	/* Search for an existing open(O_WRITE) file */
-	ctx = nfs_find_open_context(inode, cred, FMODE_WRITE);
-	if (ctx != NULL)
+	if (sattr->ia_valid & ATTR_FILE) {
+		struct nfs_open_context *ctx;
+
+		ctx = nfs_file_open_context(sattr->ia_file);
+		cred = ctx->cred;
 		state = ctx->state;
+	}
 
-	status = nfs4_do_setattr(inode, fattr, sattr, state);
+	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
 	if (status == 0)
 		nfs_setattr_update_inode(inode, sattr);
-	if (ctx != NULL)
-		put_nfs_open_context(ctx);
-	put_rpccred(cred);
 	return status;
 }
 
@@ -1897,17 +1895,16 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		goto out;
 	}
 	state = nfs4_do_open(dir, &path, flags, sattr, cred);
-	put_rpccred(cred);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
-		goto out;
+		goto out_putcred;
 	}
 	d_add(dentry, igrab(state->inode));
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (flags & O_EXCL) {
 		struct nfs_fattr fattr;
-		status = nfs4_do_setattr(state->inode, &fattr, sattr, state);
+		status = nfs4_do_setattr(state->inode, cred, &fattr, sattr, state);
 		if (status == 0)
 			nfs_setattr_update_inode(state->inode, sattr);
 		nfs_post_op_update_inode(state->inode, &fattr);
@@ -1916,6 +1913,8 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		status = nfs4_intent_set_file(nd, &path, state);
 	else
 		nfs4_close_sync(&path, state, flags);
+out_putcred:
+	put_rpccred(cred);
 out:
 	return status;
 }
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 5c35b02..c760558 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -129,6 +129,8 @@ nfs_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 	sattr->ia_mode &= S_IALLUGO;
 
 	dprintk("NFS call  setattr\n");
+	if (sattr->ia_valid & ATTR_FILE)
+		msg.rpc_cred = nfs_file_cred(sattr->ia_file);
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
 	if (status == 0)

