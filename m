Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20580 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607Ab2JBBM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 21:12:28 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4 reduce attribute requests for open reclaim
Date: Mon,  1 Oct 2012 21:12:22 -0400
Message-Id: <1349140342-2408-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We currently make no distinction in attribute requests between normal OPENs
and OPEN with CLAIM_PREVIOUS.  This offers more possibility of failures in
the GETATTR response which foils OPEN reclaim attempts.

Reduce the requested attributes to the bare minimum needed to update the
reclaim open stateid and split nfs4_opendata_to_nfs4_state processing
accordingly.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c    |    4 +-
 fs/nfs/internal.h |    1 +
 fs/nfs/nfs4proc.c |  110 ++++++++++++++++++++++++++++++++++++++++------------
 fs/nfs/nfs4xdr.c  |    2 +-
 4 files changed, 88 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 126a4cb..8bf3cdf 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -61,7 +61,6 @@
 static bool enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
 
 static void nfs_invalidate_inode(struct inode *);
-static int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
 static struct kmem_cache * nfs_inode_cachep;
 
@@ -1292,7 +1291,7 @@ EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
  *
  * A very similar scenario holds for the dir cache.
  */
-static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
+int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
 	struct nfs_server *server;
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -1495,6 +1494,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	nfs_invalidate_inode(inode);
 	return -ESTALE;
 }
+EXPORT_SYMBOL_GPL(nfs_update_inode);
 
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 89a795d..aff4399 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -323,6 +323,7 @@ extern void nfs_clear_inode(struct inode *);
 extern void nfs_evict_inode(struct inode *);
 void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
+int nfs_update_inode(struct inode *, struct nfs_fattr *);
 
 /* super.c */
 extern const struct super_operations nfs_sops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50e79c9..fc5670f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -152,6 +152,12 @@ static const u32 nfs4_pnfs_open_bitmap[3] = {
 	FATTR4_WORD2_MDSTHRESHOLD
 };
 
+static const u32 nfs4_open_noattr_bitmap[3] = {
+	FATTR4_WORD0_TYPE
+	| FATTR4_WORD0_CHANGE
+	| FATTR4_WORD0_FILEID,
+};
+
 const u32 nfs4_statfs_bitmap[2] = {
 	FATTR4_WORD0_FILES_AVAIL
 	| FATTR4_WORD0_FILES_FREE
@@ -1120,11 +1126,76 @@ out_return_state:
 	return state;
 }
 
-static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
+static void
+nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
+{
+	struct nfs_client *clp = NFS_SERVER(state->inode)->nfs_client;
+	struct nfs_delegation *delegation;
+	int delegation_flags = 0;
+
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
+	if (delegation)
+		delegation_flags = delegation->flags;
+	rcu_read_unlock();
+	if (data->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR) {
+		pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
+				   "returning a delegation for "
+				   "OPEN(CLAIM_DELEGATE_CUR)\n",
+				   clp->cl_hostname);
+	} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
+		nfs_inode_set_delegation(state->inode,
+					 data->owner->so_cred,
+					 &data->o_res);
+	else
+		nfs_inode_reclaim_delegation(state->inode,
+					     data->owner->so_cred,
+					     &data->o_res);
+}
+
+/*
+ * Check the inode attributes against the CLAIM_PREVIOUS returned attributes
+ * and update the nfs4_state.
+ */
+static struct nfs4_state *
+_nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
+{
+	struct inode *inode = data->state->inode;
+	struct nfs4_state *state = data->state;
+	int ret = -ESTALE;
+
+	if (!data->rpc_done || !(data->f_attr.valid & NFS_ATTR_FATTR) ||
+	    !(data->f_attr.valid & NFS_ATTR_FATTR_TYPE) ||
+	    !(data->f_attr.valid & NFS_ATTR_FATTR_CHANGE) ||
+	    !(data->f_attr.valid & NFS_ATTR_FATTR_FILEID))
+		goto err;
+
+	ret = -ENOMEM;
+	state = nfs4_get_open_state(inode, data->owner);
+	if (state == NULL)
+		goto err;
+
+	spin_lock(&inode->i_lock);
+	ret = nfs_update_inode(inode, &data->f_attr);
+	spin_unlock(&inode->i_lock);
+	if (ret)
+		goto err;
+	if (data->o_res.delegation_type != 0)
+		nfs4_opendata_check_deleg(data, state);
+	update_open_stateid(state, &data->o_res.stateid, NULL,
+			    data->o_arg.fmode);
+
+	return state;
+err:
+	return ERR_PTR(ret);
+
+}
+
+static struct nfs4_state *
+_nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 {
 	struct inode *inode;
 	struct nfs4_state *state = NULL;
-	struct nfs_delegation *delegation;
 	int ret;
 
 	if (!data->rpc_done) {
@@ -1143,30 +1214,8 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 	state = nfs4_get_open_state(inode, data->owner);
 	if (state == NULL)
 		goto err_put_inode;
-	if (data->o_res.delegation_type != 0) {
-		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
-		int delegation_flags = 0;
-
-		rcu_read_lock();
-		delegation = rcu_dereference(NFS_I(inode)->delegation);
-		if (delegation)
-			delegation_flags = delegation->flags;
-		rcu_read_unlock();
-		if (data->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR) {
-			pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
-					"returning a delegation for "
-					"OPEN(CLAIM_DELEGATE_CUR)\n",
-					clp->cl_hostname);
-		} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
-			nfs_inode_set_delegation(state->inode,
-					data->owner->so_cred,
-					&data->o_res);
-		else
-			nfs_inode_reclaim_delegation(state->inode,
-					data->owner->so_cred,
-					&data->o_res);
-	}
-
+	if (data->o_res.delegation_type != 0)
+		nfs4_opendata_check_deleg(data, state);
 	update_open_stateid(state, &data->o_res.stateid, NULL,
 			data->o_arg.fmode);
 	iput(inode);
@@ -1178,6 +1227,14 @@ err:
 	return ERR_PTR(ret);
 }
 
+static struct nfs4_state *
+nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
+{
+	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS)
+		return _nfs4_opendata_reclaim_to_nfs4_state(data);
+	return _nfs4_opendata_to_nfs4_state(data);
+}
+
 static struct nfs_open_context *nfs4_state_find_open_context(struct nfs4_state *state)
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
@@ -1499,6 +1556,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+		data->o_arg.open_bitmap = &nfs4_open_noattr_bitmap[0];
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 657483c..ba5b195 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2262,7 +2262,7 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_access(xdr, args->access, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
 }
 
-- 
1.7.7.6

