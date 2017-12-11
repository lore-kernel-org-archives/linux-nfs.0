Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40308 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752335AbdLKEmB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 10 Dec 2017 23:42:01 -0500
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id ABA37AAB5
        for <linux-nfs@vger.kernel.org>; Mon, 11 Dec 2017 04:41:59 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 11 Dec 2017 15:40:18 +1100
Subject: [PATCH 15/19] NFS/NFSD/SUNRPC: replace generic creds with 'struct
 cred'.
Message-ID: <151296721800.24753.1703874154732941245.stgit@noble>
In-Reply-To: <151296579813.24753.5905981862981613395.stgit@noble>
References: <151296579813.24753.5905981862981613395.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SUNRPC has two sorts of credentials, both of which appear as
"struct rpc_cred".
There are "generic credentials" which as supplied by clients
such as NFS and passed in 'struct rpc_message' to indicate
which user should be used to authorize the request, and there
are low-level credentials such as AUTH_NULL, AUTH_UNIX, AUTH_GSS
which describe the credential to be sent over the wires.

This patch replaces all the generic credentials by 'struct cred'
pointers - the credential structure used throughout Linux.

For machine credentials, there is a special 'struct cred *' pointer
which is statically allocated and recognized where needed as
having a special meaning.  A look-up of a low-level cred will
map this to a machine credential.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lockd/clntproc.c                       |    6 +
 fs/nfs/delegation.c                       |   24 ++--
 fs/nfs/delegation.h                       |   10 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    |   31 ++----
 fs/nfs/flexfilelayout/flexfilelayout.h    |    8 +
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   16 +--
 fs/nfs/inode.c                            |   10 +-
 fs/nfs/internal.h                         |    6 +
 fs/nfs/nfs3proc.c                         |   18 ---
 fs/nfs/nfs4_fs.h                          |   56 +++++-----
 fs/nfs/nfs4client.c                       |    4 -
 fs/nfs/nfs4proc.c                         |  163 +++++++++++++----------------
 fs/nfs/nfs4renewd.c                       |    4 -
 fs/nfs/nfs4session.c                      |    4 -
 fs/nfs/nfs4state.c                        |   78 +++++++-------
 fs/nfs/pagelist.c                         |    2 
 fs/nfs/pnfs.c                             |   10 +-
 fs/nfs/pnfs.h                             |   10 +-
 fs/nfs/pnfs_dev.c                         |    4 -
 fs/nfs/pnfs_nfs.c                         |    2 
 fs/nfs/proc.c                             |    9 --
 fs/nfs/unlink.c                           |   15 +--
 fs/nfs/write.c                            |    2 
 fs/nfsd/nfs4callback.c                    |   18 +--
 fs/nfsd/state.h                           |    2 
 include/linux/cred.h                      |   11 ++
 include/linux/nfs_fs.h                    |    6 +
 include/linux/nfs_xdr.h                   |   14 +-
 include/linux/sunrpc/auth.h               |   20 ----
 include/linux/sunrpc/sched.h              |    2 
 net/sunrpc/auth.c                         |   14 ++
 net/sunrpc/clnt.c                         |    4 -
 net/sunrpc/sched.c                        |    2 
 33 files changed, 259 insertions(+), 326 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac313ae5c..7180ea5e6bd9 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -256,7 +256,7 @@ static int nlm_wait_on_grace(wait_queue_head_t *queue)
  * Generic NLM call
  */
 static int
-nlmclnt_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc)
+nlmclnt_call(const struct cred *cred, struct nlm_rqst *req, u32 proc)
 {
 	struct nlm_host	*host = req->a_host;
 	struct rpc_clnt	*clnt;
@@ -401,7 +401,7 @@ int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *t
  *      completion in order to be able to correctly track the lock
  *      state.
  */
-static int nlmclnt_async_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
+static int nlmclnt_async_call(const struct cred *cred, struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
 {
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_args,
@@ -510,7 +510,7 @@ static int do_vfs_lock(struct file_lock *fl)
 static int
 nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 {
-	struct rpc_cred *cred = nfs_file_cred(fl->fl_file);
+	const struct cred *cred = nfs_file_cred(fl->fl_file);
 	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
 	struct nlm_wait *block = NULL;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index ade44ca0c66c..cb0eea918baa 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -25,7 +25,7 @@
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	if (delegation->cred) {
-		put_rpccred(delegation->cred);
+		put_cred(delegation->cred);
 		delegation->cred = NULL;
 	}
 	kfree_rcu(delegation, rcu);
@@ -173,11 +173,11 @@ static int nfs_delegation_claim_opens(struct inode *inode,
  * @res: new delegation state from server
  *
  */
-void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
+void nfs_inode_reclaim_delegation(struct inode *inode, const struct cred *cred,
 				  struct nfs_openres *res)
 {
 	struct nfs_delegation *delegation;
-	struct rpc_cred *oldcred = NULL;
+	const struct cred *oldcred = NULL;
 
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
@@ -188,12 +188,12 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
 			delegation->type = res->delegation_type;
 			delegation->pagemod_limit = res->pagemod_limit;
 			oldcred = delegation->cred;
-			delegation->cred = get_rpccred(cred);
+			delegation->cred = get_cred(cred);
 			clear_bit(NFS_DELEGATION_NEED_RECLAIM,
 				  &delegation->flags);
 			spin_unlock(&delegation->lock);
 			rcu_read_unlock();
-			put_rpccred(oldcred);
+			put_cred(oldcred);
 			trace_nfs4_reclaim_delegation(inode, res->delegation_type);
 			return;
 		}
@@ -332,7 +332,7 @@ nfs_update_inplace_delegation(struct nfs_delegation *delegation,
  *
  * Returns zero on success, or a negative errno value.
  */
-int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
+int nfs_inode_set_delegation(struct inode *inode, const struct cred *cred, struct nfs_openres *res)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_client *clp = server->nfs_client;
@@ -348,7 +348,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation->type = res->delegation_type;
 	delegation->pagemod_limit = res->pagemod_limit;
 	delegation->change_attr = inode->i_version;
-	delegation->cred = get_rpccred(cred);
+	delegation->cred = get_cred(cred);
 	delegation->inode = inode;
 	delegation->flags = 1<<NFS_DELEGATION_REFERENCED;
 	spin_lock_init(&delegation->lock);
@@ -953,7 +953,7 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
 	struct nfs_delegation *delegation;
 	struct nfs_server *server;
 	struct inode *inode;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	nfs4_stateid stateid;
 
 restart:
@@ -975,7 +975,7 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
 				nfs_sb_deactive(server->super);
 				goto restart;
 			}
-			cred = get_rpccred_rcu(delegation->cred);
+			cred = get_cred_rcu(delegation->cred);
 			nfs4_stateid_copy(&stateid, &delegation->stateid);
 			clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags);
 			rcu_read_unlock();
@@ -984,7 +984,7 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
 				nfs_revoke_delegation(inode, &stateid);
 				nfs_inode_find_state_and_recover(inode, &stateid);
 			}
-			put_rpccred(cred);
+			put_cred(cred);
 			if (nfs4_server_rebooted(clp)) {
 				nfs_inode_mark_test_expired_delegation(server,inode);
 				iput(inode);
@@ -1078,7 +1078,7 @@ bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
  * otherwise "false" is returned.
  */
 bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags,
-		nfs4_stateid *dst, struct rpc_cred **cred)
+		nfs4_stateid *dst, const struct cred **cred)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
@@ -1092,7 +1092,7 @@ bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags,
 		nfs4_stateid_copy(dst, &delegation->stateid);
 		nfs_mark_delegation_referenced(delegation);
 		if (cred)
-			*cred = get_rpccred(delegation->cred);
+			*cred = get_cred(delegation->cred);
 	}
 	rcu_read_unlock();
 	return ret;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 185a09f37a89..06f37f823029 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -15,7 +15,7 @@
  */
 struct nfs_delegation {
 	struct list_head super_list;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	struct inode *inode;
 	nfs4_stateid stateid;
 	fmode_t type;
@@ -36,8 +36,8 @@ enum {
 	NFS_DELEGATION_TEST_EXPIRED,
 };
 
-int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
-void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
+int nfs_inode_set_delegation(struct inode *inode, const struct cred *cred, struct nfs_openres *res);
+void nfs_inode_reclaim_delegation(struct inode *inode, const struct cred *cred, struct nfs_openres *res);
 int nfs4_inode_return_delegation(struct inode *inode);
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid);
 void nfs_inode_return_delegation_noreclaim(struct inode *inode);
@@ -58,10 +58,10 @@ void nfs_mark_test_expired_all_delegations(struct nfs_client *clp);
 void nfs_reap_expired_delegations(struct nfs_client *clp);
 
 /* NFSv4 delegation-related procedures */
-int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
+int nfs4_proc_delegreturn(struct inode *inode, const struct cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid, fmode_t type);
 int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid);
-bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags, nfs4_stateid *dst, struct rpc_cred **cred);
+bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags, nfs4_stateid *dst, const struct cred **cred);
 bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 8ef4a9c50b10..00864ee0f170 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -224,16 +224,16 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(gfp_t gfp_flags)
 
 static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 {
-	struct rpc_cred	*cred;
+	const struct cred	*cred;
 
 	ff_layout_remove_mirror(mirror);
 	kfree(mirror->fh_versions);
 	cred = rcu_access_pointer(mirror->ro_cred);
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 	cred = rcu_access_pointer(mirror->rw_cred);
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 	nfs4_ff_layout_put_deviceid(mirror->mirror_ds);
 	kfree(mirror);
 }
@@ -411,9 +411,8 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 
 	for (i = 0; i < fls->mirror_array_cnt; i++) {
 		struct nfs4_ff_layout_mirror *mirror;
-		struct auth_cred acred = {};
-		struct rpc_cred	__rcu *cred;
 		struct cred *kcred;
+		const struct cred *cred;
 		kuid_t uid;
 		kgid_t gid;
 		u32 ds_count, fh_count, id;
@@ -504,15 +503,7 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 			goto out_err_free;
 		kcred->fsuid = uid;
 		kcred->fsgid = gid;
-		acred.cred = kcred;
-
-		/* find the cred for it */
-		rcu_assign_pointer(cred, rpc_lookup_generic_cred(&acred, 0, gfp_flags));
-		put_cred(kcred);
-		if (IS_ERR(cred)) {
-			rc = PTR_ERR(cred);
-			goto out_err_free;
-		}
+		cred = kcred;
 
 		if (lgr->range.iomode == IOMODE_READ)
 			rcu_assign_pointer(fls->mirror_array[i]->ro_cred, cred);
@@ -1716,7 +1707,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
-	struct rpc_cred *ds_cred;
+	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	u32 idx = hdr->pgio_mirror_idx;
 	int vers;
@@ -1762,7 +1753,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 			  vers == 3 ? &ff_layout_read_call_ops_v3 :
 				      &ff_layout_read_call_ops_v4,
 			  0, RPC_TASK_SOFTCONN);
-	put_rpccred(ds_cred);
+	put_cred(ds_cred);
 	return PNFS_ATTEMPTED;
 
 out_failed:
@@ -1778,7 +1769,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
-	struct rpc_cred *ds_cred;
+	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	int vers;
 	struct nfs_fh *fh;
@@ -1823,7 +1814,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 			  vers == 3 ? &ff_layout_write_call_ops_v3 :
 				      &ff_layout_write_call_ops_v4,
 			  sync, RPC_TASK_SOFTCONN);
-	put_rpccred(ds_cred);
+	put_cred(ds_cred);
 	return PNFS_ATTEMPTED;
 
 out_failed:
@@ -1853,7 +1844,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
-	struct rpc_cred *ds_cred;
+	const struct cred *ds_cred;
 	u32 idx;
 	int vers, ret;
 	struct nfs_fh *fh;
@@ -1893,7 +1884,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 				   vers == 3 ? &ff_layout_commit_call_ops_v3 :
 					       &ff_layout_commit_call_ops_v4,
 				   how, RPC_TASK_SOFTCONN);
-	put_rpccred(ds_cred);
+	put_cred(ds_cred);
 	return ret;
 out_err:
 	pnfs_generic_prepare_to_resend_writes(data);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 411798346e48..e1521e422269 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -81,8 +81,8 @@ struct nfs4_ff_layout_mirror {
 	u32				fh_versions_cnt;
 	struct nfs_fh			*fh_versions;
 	nfs4_stateid			stateid;
-	struct rpc_cred	__rcu		*ro_cred;
-	struct rpc_cred	__rcu		*rw_cred;
+	const struct cred __rcu		*ro_cred;
+	const struct cred __rcu		*rw_cred;
 	refcount_t			ref;
 	spinlock_t			lock;
 	unsigned long			flags;
@@ -225,8 +225,8 @@ nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg,
 				 u32 ds_idx,
 				 struct nfs_client *ds_clp,
 				 struct inode *inode);
-struct rpc_cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
-				       u32 ds_idx, struct rpc_cred *mdscred);
+const struct cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
+				       u32 ds_idx, const struct cred *mdscred);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index d62279d3fc5d..b357dcbd2ed3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -329,10 +329,10 @@ int ff_layout_track_ds_error(struct nfs4_flexfile_layout *flo,
 	return 0;
 }
 
-static struct rpc_cred *
+static const struct cred *
 ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
 {
-	struct rpc_cred *cred, __rcu **pcred;
+	const struct cred *cred, __rcu **pcred;
 
 	if (iomode == IOMODE_READ)
 		pcred = &mirror->ro_cred;
@@ -345,7 +345,7 @@ ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
 		if (!cred)
 			break;
 
-		cred = get_rpccred_rcu(cred);
+		cred = get_cred_rcu(cred);
 	} while(!cred);
 	rcu_read_unlock();
 	return cred;
@@ -445,19 +445,19 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	return ds;
 }
 
-struct rpc_cred *
+const struct cred *
 ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
-		      struct rpc_cred *mdscred)
+		      const struct cred *mdscred)
 {
 	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	if (mirror) {
 		cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
 		if (!cred)
-			cred = get_rpccred(mdscred);
+			cred = get_cred(mdscred);
 	} else {
-		cred = get_rpccred(mdscred);
+		cred = get_cred(mdscred);
 	}
 	return cred;
 }
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 40fe5c0fd401..d7fd583f73e4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -885,13 +885,11 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 						struct file *filp)
 {
 	struct nfs_open_context *ctx;
-	struct rpc_cred *cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return ERR_CAST(cred);
+	const struct cred *cred = get_current_cred();
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx) {
-		put_rpccred(cred);
+		put_cred(cred);
 		return ERR_PTR(-ENOMEM);
 	}
 	nfs_sb_active(dentry->d_sb);
@@ -934,7 +932,7 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 	if (inode != NULL)
 		NFS_PROTO(inode)->close_context(ctx, is_sync);
 	if (ctx->cred != NULL)
-		put_rpccred(ctx->cred);
+		put_cred(ctx->cred);
 	dput(ctx->dentry);
 	nfs_sb_deactive(sb);
 	put_rpccred(ctx->ll_cred);
@@ -982,7 +980,7 @@ EXPORT_SYMBOL_GPL(nfs_file_set_open_context);
 /*
  * Given an inode, search for an open context with the desired characteristics
  */
-struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode)
+struct nfs_open_context *nfs_find_open_context(struct inode *inode, const struct cred *cred, fmode_t mode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_open_context *pos, *ctx = NULL;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8357ff69962f..2b31e29fc433 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -254,7 +254,7 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
 void nfs_pgio_header_free(struct nfs_pgio_header *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
-		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
+		      const struct cred *cred, const struct nfs_rpc_ops *rpc_ops,
 		      const struct rpc_call_ops *call_ops, int how, int flags);
 void nfs_free_request(struct nfs_page *req);
 struct nfs_pgio_mirror *
@@ -565,10 +565,10 @@ extern struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 			    const struct nfs_client_initdata *);
 extern int nfs40_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
-				struct rpc_cred *cred);
+				const struct cred *cred);
 extern int nfs41_walk_client_list(struct nfs_client *clp,
 				struct nfs_client **result,
-				struct rpc_cred *cred);
+				const struct cred *cred);
 extern int nfs4_test_session_trunk(struct rpc_clnt *,
 				struct rpc_xprt *,
 				void *);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 2b1291396162..263f8c8d9280 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -191,20 +191,15 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		.access		= entry->mask,
 	};
 	struct nfs3_accessres	res;
-	struct auth_cred acred = {
-		.cred		= entry->cred,
-	};
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_ACCESS],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
-		.rpc_cred	= rpc_lookup_generic_cred(&acred, 0, GFP_NOFS),
+		.rpc_cred	= entry->cred,
 	};
 	int status = -ENOMEM;
 
 	dprintk("NFS call  access\n");
-	if (!msg.rpc_cred)
-		goto out;
 	res.fattr = nfs_alloc_fattr();
 	if (res.fattr == NULL)
 		goto out;
@@ -215,8 +210,6 @@ static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 		nfs_access_set_mask(entry, res.access);
 	nfs_free_fattr(res.fattr);
 out:
-	if (msg.rpc_cred)
-		put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply access: %d\n", status);
 	return status;
 }
@@ -623,15 +616,11 @@ nfs3_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		.verf		= verf,
 		.plus		= plus
 	};
-	struct auth_cred acred = {
-		.cred		= cred,
-	};
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_READDIR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
-		.rpc_cred	= rpc_lookup_generic_cred(&acred,
-							  0, GFP_NOFS),
+		.rpc_cred	= cred,
 	};
 	int status = -ENOMEM;
 
@@ -641,8 +630,6 @@ nfs3_proc_readdir(struct dentry *dentry, const struct cred *cred,
 	dprintk("NFS call  readdir%s %d\n",
 			plus? "plus" : "", (unsigned int) cookie);
 
-	if (!msg.rpc_cred)
-		return -ENOMEM;
 	res.dir_attr = nfs_alloc_fattr();
 	if (res.dir_attr == NULL)
 		goto out;
@@ -654,7 +641,6 @@ nfs3_proc_readdir(struct dentry *dentry, const struct cred *cred,
 
 	nfs_free_fattr(res.dir_attr);
 out:
-	put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply readdir%s: %d\n",
 			plus? "plus" : "", status);
 	return status;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 725b20fc2ebf..c8995291b5a1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -60,7 +60,7 @@ struct nfs4_minor_version_ops {
 	void	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
 	int	(*test_and_free_expired)(struct nfs_server *,
-			nfs4_stateid *, struct rpc_cred *);
+			nfs4_stateid *, const struct cred *);
 	struct nfs_seqid *
 		(*alloc_seqid)(struct nfs_seqid_counter *, gfp_t);
 	int	(*session_trunk)(struct rpc_clnt *, struct rpc_xprt *, void *);
@@ -105,7 +105,7 @@ struct nfs4_state_owner {
 	unsigned long        so_expires;
 	struct rb_node	     so_server_node;
 
-	struct rpc_cred	     *so_cred;	 /* Associated cred */
+	const struct cred    *so_cred;	 /* Associated cred */
 
 	spinlock_t	     so_lock;
 	atomic_t	     so_count;
@@ -206,27 +206,27 @@ struct nfs4_state_recovery_ops {
 	int state_flag_bit;
 	int (*recover_open)(struct nfs4_state_owner *, struct nfs4_state *);
 	int (*recover_lock)(struct nfs4_state *, struct file_lock *);
-	int (*establish_clid)(struct nfs_client *, struct rpc_cred *);
-	int (*reclaim_complete)(struct nfs_client *, struct rpc_cred *);
+	int (*establish_clid)(struct nfs_client *, const struct cred *);
+	int (*reclaim_complete)(struct nfs_client *, const struct cred *);
 	int (*detect_trunking)(struct nfs_client *, struct nfs_client **,
-		struct rpc_cred *);
+		const struct cred *);
 };
 
 struct nfs4_add_xprt_data {
 	struct nfs_client	*clp;
-	struct rpc_cred		*cred;
+	const struct cred	*cred;
 };
 
 struct nfs4_state_maintenance_ops {
-	int (*sched_state_renewal)(struct nfs_client *, struct rpc_cred *, unsigned);
-	struct rpc_cred * (*get_state_renewal_cred)(struct nfs_client *);
-	int (*renew_lease)(struct nfs_client *, struct rpc_cred *);
+	int (*sched_state_renewal)(struct nfs_client *, const struct cred *, unsigned);
+	const struct cred * (*get_state_renewal_cred)(struct nfs_client *);
+	int (*renew_lease)(struct nfs_client *, const struct cred *);
 };
 
 struct nfs4_mig_recovery_ops {
 	int (*get_locations)(struct inode *, struct nfs4_fs_locations *,
-		struct page *, struct rpc_cred *);
-	int (*fsid_present)(struct inode *, struct rpc_cred *);
+		struct page *, const struct cred *);
+	int (*fsid_present)(struct inode *, const struct cred *);
 };
 
 extern const struct dentry_operations nfs4_dentry_operations;
@@ -252,21 +252,21 @@ extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
 extern void nfs4_init_sequence(struct nfs4_sequence_args *, struct nfs4_sequence_res *, int);
-extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
-extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
+extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, const struct cred *, struct nfs4_setclientid_res *);
+extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, const struct cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
-extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, struct rpc_cred *cred);
-extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
+extern int nfs4_proc_bind_conn_to_session(struct nfs_client *, const struct cred *cred);
+extern int nfs4_proc_exchange_id(struct nfs_client *clp, const struct cred *cred);
 extern int nfs4_destroy_clientid(struct nfs_client *clp);
-extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
-extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
+extern int nfs4_init_clientid(struct nfs_client *, const struct cred *);
+extern int nfs41_init_clientid(struct nfs_client *, const struct cred *);
 extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct rpc_clnt *, struct inode *, const struct qstr *,
 				  struct nfs4_fs_locations *, struct page *);
 extern int nfs4_proc_get_locations(struct inode *, struct nfs4_fs_locations *,
-		struct page *page, struct rpc_cred *);
-extern int nfs4_proc_fsid_present(struct inode *, struct rpc_cred *);
+		struct page *page, const struct cred *);
+extern int nfs4_proc_fsid_present(struct inode *, const struct cred *);
 extern struct rpc_clnt *nfs4_proc_lookup_mountpoint(struct inode *, const struct qstr *,
 			    struct nfs_fh *, struct nfs_fattr *);
 extern int nfs4_proc_secinfo(struct inode *, const struct qstr *, struct nfs4_secinfo_flavors *);
@@ -278,8 +278,8 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
 
 #if defined(CONFIG_NFS_V4_1)
 extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res *);
-extern int nfs4_proc_create_session(struct nfs_client *, struct rpc_cred *);
-extern int nfs4_proc_destroy_session(struct nfs4_session *, struct rpc_cred *);
+extern int nfs4_proc_create_session(struct nfs_client *, const struct cred *);
+extern int nfs4_proc_destroy_session(struct nfs4_session *, const struct cred *);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
@@ -409,16 +409,16 @@ extern void nfs4_set_lease_period(struct nfs_client *clp,
 
 
 /* nfs4state.c */
-struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp);
-struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
+const struct cred *nfs4_get_clid_cred(struct nfs_client *clp);
+const struct cred *nfs4_get_machine_cred(struct nfs_client *clp);
+const struct cred *nfs4_get_renew_cred(struct nfs_client *clp);
 int nfs4_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **);
 int nfs40_discover_server_trunking(struct nfs_client *clp,
-			struct nfs_client **, struct rpc_cred *);
+			struct nfs_client **, const struct cred *);
 #if defined(CONFIG_NFS_V4_1)
 int nfs41_discover_server_trunking(struct nfs_client *clp,
-			struct nfs_client **, struct rpc_cred *);
+			struct nfs_client **, const struct cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
 extern void nfs41_notify_server(struct nfs_client *);
 #else
@@ -427,7 +427,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-extern struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *, gfp_t);
+extern struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *, const struct cred *, gfp_t);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
 extern void nfs4_purge_state_owners(struct nfs_server *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
@@ -453,7 +453,7 @@ extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
 		const struct nfs_lock_context *, nfs4_stateid *,
-		struct rpc_cred **);
+		const struct cred **);
 extern bool nfs4_refresh_open_stateid(nfs4_stateid *dst,
 		struct nfs4_state *state);
 extern bool nfs4_copy_open_stateid(nfs4_stateid *dst,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 12bbab0becb4..0bd22e15289e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -526,7 +526,7 @@ static int nfs4_match_client(struct nfs_client  *pos,  struct nfs_client *new,
  */
 int nfs40_walk_client_list(struct nfs_client *new,
 			   struct nfs_client **result,
-			   struct rpc_cred *cred)
+			   const struct cred *cred)
 {
 	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
 	struct nfs_client *pos, *prev = NULL;
@@ -687,7 +687,7 @@ int nfs4_detect_session_trunking(struct nfs_client *clp,
  */
 int nfs41_walk_client_list(struct nfs_client *new,
 			   struct nfs_client **result,
-			   struct rpc_cred *cred)
+			   const struct cred *cred)
 {
 	struct nfs_net *nn = net_generic(new->cl_net, nfs_net_id);
 	struct nfs_client *pos, *prev = NULL;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5477b4f291bb..8a099467da3b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -91,19 +91,19 @@ static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinf
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
-static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs_open_context *ctx, struct nfs4_label *ilabel,
 			    struct nfs4_label *olabel);
 #ifdef CONFIG_NFS_V4_1
 static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
-		struct rpc_cred *cred,
+		const struct cred *cred,
 		struct nfs4_slot *slot,
 		bool is_privileged);
 static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
-		struct rpc_cred *);
+		const struct cred *);
 static int nfs41_free_stateid(struct nfs_server *, const nfs4_stateid *,
-		struct rpc_cred *, bool);
+		const struct cred *, bool);
 #endif
 
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
@@ -332,7 +332,7 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 
 static void nfs4_test_and_free_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	const struct nfs4_minor_version_ops *ops = server->nfs_client->cl_mvops;
 
@@ -341,7 +341,7 @@ static void nfs4_test_and_free_stateid(struct nfs_server *server,
 
 static void __nfs4_free_revoked_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	stateid->type = NFS4_REVOKED_STATEID_TYPE;
 	nfs4_test_and_free_stateid(server, stateid, cred);
@@ -349,7 +349,7 @@ static void __nfs4_free_revoked_stateid(struct nfs_server *server,
 
 static void nfs4_free_revoked_stateid(struct nfs_server *server,
 		const nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	nfs4_stateid tmp;
 
@@ -865,7 +865,7 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 
 static void
 nfs4_sequence_process_interrupted(struct nfs_client *client,
-		struct nfs4_slot *slot, struct rpc_cred *cred)
+		struct nfs4_slot *slot, const struct cred *cred)
 {
 	struct rpc_task *task;
 
@@ -896,7 +896,7 @@ EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 
 static void
 nfs4_sequence_process_interrupted(struct nfs_client *client,
-		struct nfs4_slot *slot, struct rpc_cred *cred)
+		struct nfs4_slot *slot, const struct cred *cred)
 {
 	WARN_ON_ONCE(1);
 	slot->interrupted = 0;
@@ -1708,7 +1708,7 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		rcu_read_unlock();
 		nfs_release_seqid(opendata->o_arg.seqid);
 		if (!opendata->is_recover) {
-			ret = nfs_may_open(state->inode, state->owner->so_cred->cr_cred, open_mode);
+			ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
 			if (ret != 0)
 				goto out;
 		}
@@ -2388,7 +2388,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
  * Note that in the non-execute case, we want to turn off permission
  * checking if we just created a new file (POSIX open() semantics).
  */
-static int nfs4_opendata_access(struct rpc_cred *cred,
+static int nfs4_opendata_access(const struct cred *cred,
 				struct nfs4_opendata *opendata,
 				struct nfs4_state *state, fmode_t fmode,
 				int openflags)
@@ -2415,7 +2415,7 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 	} else if ((fmode & FMODE_READ) && !opendata->file_created)
 		mask = NFS4_ACCESS_READ;
 
-	cache.cred = cred->cr_cred;
+	cache.cred = cred;
 	nfs_access_set_mask(&cache, opendata->o_res.access_result);
 	nfs_access_add_cache(state->inode, &cache);
 
@@ -2555,7 +2555,7 @@ static int nfs40_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 
 static int nfs40_test_and_free_expired_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	return -NFS4ERR_BAD_STATEID;
 }
@@ -2563,7 +2563,7 @@ static int nfs40_test_and_free_expired_stateid(struct nfs_server *server,
 #if defined(CONFIG_NFS_V4_1)
 static int nfs41_test_and_free_expired_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	int status;
 
@@ -2597,7 +2597,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	nfs4_stateid stateid;
 	struct nfs_delegation *delegation;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int status;
 
 	/* Get the delegation credential for use by test/free_stateid */
@@ -2617,14 +2617,14 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 		return;
 	}
 
-	cred = get_rpccred(delegation->cred);
+	cred = get_cred(delegation->cred);
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
 	trace_nfs4_test_delegation_stateid(state, NULL, status);
 	if (status == -NFS4ERR_EXPIRED || status == -NFS4ERR_BAD_STATEID)
 		nfs_finish_clear_delegation_stateid(state, &stateid);
 
-	put_rpccred(cred);
+	put_cred(cred);
 }
 
 /**
@@ -2647,7 +2647,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 	spin_lock(&state->state_lock);
 	list_for_each_entry(lsp, &state->lock_states, ls_locks) {
 		if (test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags)) {
-			struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
+			const struct cred *cred = lsp->ls_state->owner->so_cred;
 
 			refcount_inc(&lsp->ls_count);
 			spin_unlock(&state->state_lock);
@@ -2691,7 +2691,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	nfs4_stateid *stateid = &state->open_stateid;
-	struct rpc_cred *cred = state->owner->so_cred;
+	const struct cred *cred = state->owner->so_cred;
 	int status;
 
 	if (test_bit(NFS_OPEN_STATE, &state->flags) == 0) {
@@ -2831,7 +2831,7 @@ static int _nfs4_do_open(struct inode *dir,
 	struct nfs_server       *server = NFS_SERVER(dir);
 	struct nfs4_opendata *opendata;
 	struct dentry *dentry = ctx->dentry;
-	struct rpc_cred *cred = ctx->cred;
+	const struct cred *cred = ctx->cred;
 	struct nfs4_threshold **ctx_th = &ctx->mdsthreshold;
 	fmode_t fmode = ctx->mode & (FMODE_READ|FMODE_WRITE|FMODE_EXEC);
 	enum open_claim_type4 claim = NFS4_OPEN_CLAIM_NULL;
@@ -2997,7 +2997,7 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 static int _nfs4_do_setattr(struct inode *inode,
 			    struct nfs_setattrargs *arg,
 			    struct nfs_setattrres *res,
-			    struct rpc_cred *cred,
+			    const struct cred *cred,
 			    struct nfs_open_context *ctx)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -3007,7 +3007,7 @@ static int _nfs4_do_setattr(struct inode *inode,
 		.rpc_resp	= res,
 		.rpc_cred	= cred,
 	};
-	struct rpc_cred *delegation_cred = NULL;
+	const struct cred *delegation_cred = NULL;
 	unsigned long timestamp = jiffies;
 	fmode_t fmode;
 	bool truncate;
@@ -3040,14 +3040,14 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg->seq_args, &res->seq_res, 1);
 
-	put_rpccred(delegation_cred);
+	put_cred(delegation_cred);
 	if (status == 0 && ctx != NULL)
 		renew_lease(server, timestamp);
 	trace_nfs4_setattr(inode, &arg->stateid, status);
 	return status;
 }
 
-static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
+static int nfs4_do_setattr(struct inode *inode, const struct cred *cred,
 			   struct nfs_fattr *fattr, struct iattr *sattr,
 			   struct nfs_open_context *ctx, struct nfs4_label *ilabel,
 			   struct nfs4_label *olabel)
@@ -3829,7 +3829,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		  struct iattr *sattr)
 {
 	struct inode *inode = d_inode(dentry);
-	struct rpc_cred *cred = NULL;
+	const struct cred *cred = NULL;
 	struct nfs_open_context *ctx = NULL;
 	struct nfs4_label *label = NULL;
 	int status;
@@ -4041,24 +4041,17 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 	struct nfs4_accessres res = {
 		.server = server,
 	};
-	struct auth_cred acred = {
-		.cred = entry->cred,
-	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_ACCESS],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
-		.rpc_cred = rpc_lookup_generic_cred(&acred, 0, GFP_NOFS),
+		.rpc_cred = entry->cred,
 	};
 	int status = 0;
 
-	if (!msg.rpc_cred)
-		return -ENOMEM;
 	res.fattr = nfs_alloc_fattr();
-	if (res.fattr == NULL) {
-		put_rpccred(msg.rpc_cred);
+	if (res.fattr == NULL)
 		return -ENOMEM;
-	}
 
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
 	if (!status) {
@@ -4066,7 +4059,6 @@ static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry
 		nfs_refresh_inode(inode, res.fattr);
 	}
 	nfs_free_fattr(res.fattr);
-	put_rpccred(msg.rpc_cred);
 	return status;
 }
 
@@ -4503,23 +4495,17 @@ static int _nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		.plus = plus,
 	};
 	struct nfs4_readdir_res res;
-	struct auth_cred acred = {
-		.cred		= cred,
-	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READDIR],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
-		.rpc_cred = rpc_lookup_generic_cred(&acred,
-						    0, GFP_NOFS),
+		.rpc_cred = cred,
 	};
 	int			status;
 
 	dprintk("%s: dentry = %pd2, cookie = %Lu\n", __func__,
 			dentry,
 			(unsigned long long)cookie);
-	if (!msg.rpc_cred)
-		return -ENOMEM;
 	nfs4_setup_readdir(cookie, NFS_I(dir)->cookieverf, dentry, &args);
 	res.pgbase = args.pgbase;
 	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
@@ -4530,7 +4516,6 @@ static int _nfs4_proc_readdir(struct dentry *dentry, const struct cred *cred,
 
 	nfs_invalidate_atime(dir);
 
-	put_rpccred(msg.rpc_cred);
 	dprintk("%s: returns %d\n", __func__, status);
 	return status;
 }
@@ -5025,7 +5010,7 @@ static const struct rpc_call_ops nfs4_renew_ops = {
 	.rpc_release = nfs4_renew_release,
 };
 
-static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
+static int nfs4_proc_async_renew(struct nfs_client *clp, const struct cred *cred, unsigned renew_flags)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
@@ -5049,7 +5034,7 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred,
 			&nfs4_renew_ops, data);
 }
 
-static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs4_proc_renew(struct nfs_client *clp, const struct cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_RENEW],
@@ -5462,7 +5447,6 @@ nfs4_set_security_label(struct inode *inode, const void *buf, size_t buflen)
 {
 	struct nfs4_label ilabel, *olabel = NULL;
 	struct nfs_fattr fattr;
-	struct rpc_cred *cred;
 	int status;
 
 	if (!nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL))
@@ -5475,10 +5459,6 @@ nfs4_set_security_label(struct inode *inode, const void *buf, size_t buflen)
 	ilabel.label = (char *)buf;
 	ilabel.len = buflen;
 
-	cred = rpc_lookup_cred();
-	if (IS_ERR(cred))
-		return PTR_ERR(cred);
-
 	olabel = nfs4_label_alloc(NFS_SERVER(inode), GFP_KERNEL);
 	if (IS_ERR(olabel)) {
 		status = -PTR_ERR(olabel);
@@ -5491,7 +5471,6 @@ nfs4_set_security_label(struct inode *inode, const void *buf, size_t buflen)
 
 	nfs4_label_free(olabel);
 out:
-	put_rpccred(cred);
 	return status;
 }
 #endif	/* CONFIG_NFS_V4_SECURITY_LABEL */
@@ -5652,13 +5631,13 @@ static const struct rpc_call_ops nfs4_setclientid_ops = {
  * @clp: state data structure
  * @program: RPC program for NFSv4 callback service
  * @port: IP port number for NFS4 callback service
- * @cred: RPC credential to use for this call
+ * @cred: credential to use for this call
  * @res: where to place the result
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status code.
  */
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
-		unsigned short port, struct rpc_cred *cred,
+		unsigned short port, const struct cred *cred,
 		struct nfs4_setclientid_res *res)
 {
 	nfs4_verifier sc_verifier;
@@ -5727,13 +5706,13 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
  * nfs4_proc_setclientid_confirm - Confirm client ID
  * @clp: state data structure
  * @res: result of a previous SETCLIENTID
- * @cred: RPC credential to use for this call
+ * @cred: credential to use for this call
  *
  * Returns zero, a negative errno, or a negative NFS4ERR status code.
  */
 int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		struct nfs4_setclientid_res *arg,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID_CONFIRM],
@@ -5883,7 +5862,7 @@ static const struct rpc_call_ops nfs4_delegreturn_ops = {
 	.rpc_release = nfs4_delegreturn_release,
 };
 
-static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
+static int _nfs4_proc_delegreturn(struct inode *inode, const struct cred *cred, const nfs4_stateid *stateid, int issync)
 {
 	struct nfs4_delegreturndata *data;
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -5950,7 +5929,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	return status;
 }
 
-int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync)
+int nfs4_proc_delegreturn(struct inode *inode, const struct cred *cred, const nfs4_stateid *stateid, int issync)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs4_exception exception = { };
@@ -6996,7 +6975,7 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
  */
 static int _nfs40_proc_get_locations(struct inode *inode,
 				     struct nfs4_fs_locations *locations,
-				     struct page *page, struct rpc_cred *cred)
+				     struct page *page, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_clnt *clnt = server->client;
@@ -7054,7 +7033,7 @@ static int _nfs40_proc_get_locations(struct inode *inode,
  */
 static int _nfs41_proc_get_locations(struct inode *inode,
 				     struct nfs4_fs_locations *locations,
-				     struct page *page, struct rpc_cred *cred)
+				     struct page *page, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_clnt *clnt = server->client;
@@ -7114,7 +7093,7 @@ static int _nfs41_proc_get_locations(struct inode *inode,
  */
 int nfs4_proc_get_locations(struct inode *inode,
 			    struct nfs4_fs_locations *locations,
-			    struct page *page, struct rpc_cred *cred)
+			    struct page *page, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_client *clp = server->nfs_client;
@@ -7145,7 +7124,7 @@ int nfs4_proc_get_locations(struct inode *inode,
  * is appended to this compound to identify the client ID which is
  * performing recovery.
  */
-static int _nfs40_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
+static int _nfs40_proc_fsid_present(struct inode *inode, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
@@ -7192,7 +7171,7 @@ static int _nfs40_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
  * this operation is identified in the SEQUENCE operation in this
  * compound.
  */
-static int _nfs41_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
+static int _nfs41_proc_fsid_present(struct inode *inode, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_clnt *clnt = server->client;
@@ -7240,7 +7219,7 @@ static int _nfs41_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
  *  NFS4ERR code if some error occurred on the server, or a
  *  negative errno if a local failure occurred.
  */
-int nfs4_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
+int nfs4_proc_fsid_present(struct inode *inode, const struct cred *cred)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_client *clp = server->nfs_client;
@@ -7287,7 +7266,7 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_resp = &res,
 	};
 	struct rpc_clnt *clnt = NFS_SERVER(dir)->client;
-	struct rpc_cred *cred = NULL;
+	const struct cred *cred = NULL;
 
 	if (use_integrity) {
 		clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
@@ -7305,7 +7284,7 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 	dprintk("NFS reply  secinfo: %d\n", status);
 
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 
 	return status;
 }
@@ -7386,7 +7365,7 @@ static
 int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt,
 		struct nfs_client *clp,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	int status;
 	struct nfs41_bind_conn_to_session_args args = {
@@ -7448,7 +7427,7 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 
 struct rpc_bind_conn_calldata {
 	struct nfs_client *clp;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 };
 
 static int
@@ -7461,7 +7440,7 @@ nfs4_proc_bind_conn_to_session_callback(struct rpc_clnt *clnt,
 	return nfs4_proc_bind_one_conn_to_session(clnt, xprt, p->clp, p->cred);
 }
 
-int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, const struct cred *cred)
 {
 	struct rpc_bind_conn_calldata data = {
 		.clp = clp,
@@ -7627,7 +7606,7 @@ static const struct rpc_call_ops nfs4_exchange_id_call_ops = {
  * Wrapper for EXCHANGE_ID operation.
  */
 static struct rpc_task *
-nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
+nfs4_run_exchange_id(struct nfs_client *clp, const struct cred *cred,
 			u32 sp4_how, struct rpc_xprt *xprt)
 {
 	struct rpc_message msg = {
@@ -7723,7 +7702,7 @@ nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
  *
  * Wrapper for EXCHANGE_ID operation.
  */
-static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
+static int _nfs4_proc_exchange_id(struct nfs_client *clp, const struct cred *cred,
 			u32 sp4_how)
 {
 	struct rpc_task *task;
@@ -7790,7 +7769,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
  *
  * Will attempt to negotiate SP4_MACH_CRED if krb5i / krb5p auth is used.
  */
-int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_proc_exchange_id(struct nfs_client *clp, const struct cred *cred)
 {
 	rpc_authflavor_t authflavor = clp->cl_rpcclient->cl_auth->au_flavor;
 	int status;
@@ -7852,7 +7831,7 @@ int nfs4_test_session_trunk(struct rpc_clnt *clnt, struct rpc_xprt *xprt,
 EXPORT_SYMBOL_GPL(nfs4_test_session_trunk);
 
 static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_CLIENTID],
@@ -7870,7 +7849,7 @@ static int _nfs4_proc_destroy_clientid(struct nfs_client *clp,
 }
 
 static int nfs4_proc_destroy_clientid(struct nfs_client *clp,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	unsigned int loop;
 	int ret;
@@ -7891,7 +7870,7 @@ static int nfs4_proc_destroy_clientid(struct nfs_client *clp,
 
 int nfs4_destroy_clientid(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int ret = 0;
 
 	if (clp->cl_mvops->minor_version < 1)
@@ -7903,7 +7882,7 @@ int nfs4_destroy_clientid(struct nfs_client *clp)
 	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_destroy_clientid(clp, cred);
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 	switch (ret) {
 	case 0:
 	case -NFS4ERR_STALE_CLIENTID:
@@ -8120,7 +8099,7 @@ static void nfs4_update_session(struct nfs4_session *session,
 }
 
 static int _nfs4_proc_create_session(struct nfs_client *clp,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs4_session *session = clp->cl_session;
 	struct nfs41_create_session_args args = {
@@ -8172,7 +8151,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
  * It is the responsibility of the caller to verify the session is
  * expired before calling this routine.
  */
-int nfs4_proc_create_session(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_proc_create_session(struct nfs_client *clp, const struct cred *cred)
 {
 	int status;
 	unsigned *ptr;
@@ -8203,7 +8182,7 @@ int nfs4_proc_create_session(struct nfs_client *clp, struct rpc_cred *cred)
  * The caller must serialize access to this routine.
  */
 int nfs4_proc_destroy_session(struct nfs4_session *session,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DESTROY_SESSION],
@@ -8305,7 +8284,7 @@ static const struct rpc_call_ops nfs41_sequence_ops = {
 };
 
 static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
-		struct rpc_cred *cred,
+		const struct cred *cred,
 		struct nfs4_slot *slot,
 		bool is_privileged)
 {
@@ -8350,7 +8329,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 	return ret;
 }
 
-static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
+static int nfs41_proc_async_sequence(struct nfs_client *clp, const struct cred *cred, unsigned renew_flags)
 {
 	struct rpc_task *task;
 	int ret = 0;
@@ -8366,7 +8345,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
 	return ret;
 }
 
-static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+static int nfs4_proc_sequence(struct nfs_client *clp, const struct cred *cred)
 {
 	struct rpc_task *task;
 	int ret;
@@ -8460,7 +8439,7 @@ static const struct rpc_call_ops nfs4_reclaim_complete_call_ops = {
  * Issue a global reclaim complete.
  */
 static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs4_reclaim_complete_data *calldata;
 	struct rpc_task *task;
@@ -8862,7 +8841,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 		struct pnfs_device *pdev,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs4_getdeviceinfo_args args = {
 		.pdev = pdev,
@@ -8894,7 +8873,7 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 
 int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 		struct pnfs_device *pdev,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -8951,7 +8930,7 @@ static void nfs4_layoutcommit_release(void *calldata)
 	pnfs_cleanup_layoutcommit(data);
 	nfs_post_op_update_inode_force_wcc(data->args.inode,
 					   data->res.fattr);
-	put_rpccred(data->cred);
+	put_cred(data->cred);
 	nfs_iput_and_deactive(data->inode);
 	kfree(data);
 }
@@ -9027,7 +9006,7 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 	struct rpc_clnt *clnt = server->client;
-	struct rpc_cred *cred = NULL;
+	const struct cred *cred = NULL;
 	int status;
 
 	if (use_integrity) {
@@ -9042,7 +9021,7 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 
 	return status;
 }
@@ -9155,7 +9134,7 @@ nfs41_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 
 static int _nfs41_test_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	int status;
 	struct nfs41_test_stateid_args args = {
@@ -9217,7 +9196,7 @@ static void nfs4_handle_delay_or_session_error(struct nfs_server *server,
  */
 static int nfs41_test_stateid(struct nfs_server *server,
 		nfs4_stateid *stateid,
-		struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs4_exception exception = { };
 	int err;
@@ -9269,7 +9248,7 @@ static const struct rpc_call_ops nfs41_free_stateid_ops = {
 
 static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 		const nfs4_stateid *stateid,
-		struct rpc_cred *cred,
+		const struct cred *cred,
 		bool privileged)
 {
 	struct rpc_message msg = {
@@ -9317,7 +9296,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
  */
 static int nfs41_free_stateid(struct nfs_server *server,
 		const nfs4_stateid *stateid,
-		struct rpc_cred *cred,
+		const struct cred *cred,
 		bool is_recovery)
 {
 	struct rpc_task *task;
@@ -9332,7 +9311,7 @@ static int nfs41_free_stateid(struct nfs_server *server,
 static void
 nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
-	struct rpc_cred *cred = lsp->ls_state->owner->so_cred;
+	const struct cred *cred = lsp->ls_state->owner->so_cred;
 
 	nfs41_free_stateid(server, &lsp->ls_stateid, cred, false);
 	nfs4_free_lock_state(server, lsp);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 8880cd958210..6ea431b067dd 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -57,7 +57,7 @@ nfs4_renew_state(struct work_struct *work)
 	const struct nfs4_state_maintenance_ops *ops;
 	struct nfs_client *clp =
 		container_of(work, struct nfs_client, cl_renewd.work);
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	long lease;
 	unsigned long last, now;
 	unsigned renew_flags = 0;
@@ -90,7 +90,7 @@ nfs4_renew_state(struct work_struct *work)
 
 			/* Queue an asynchronous RENEW. */
 			ret = ops->sched_state_renewal(clp, cred, renew_flags);
-			put_rpccred(cred);
+			put_cred(cred);
 			switch (ret) {
 			default:
 				goto out_exp;
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 769b85655c4b..fa01f9a367e7 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -573,12 +573,12 @@ static void nfs4_destroy_session_slot_tables(struct nfs4_session *session)
 void nfs4_destroy_session(struct nfs4_session *session)
 {
 	struct rpc_xprt *xprt;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	cred = nfs4_get_clid_cred(session->clp);
 	nfs4_proc_destroy_session(session, cred);
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 
 	rcu_read_lock();
 	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index dd4ef896df2a..92d80961b82e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -79,7 +79,7 @@ const nfs4_stateid invalid_stateid = {
 
 static DEFINE_MUTEX(nfs_clid_init_mutex);
 
-int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs4_init_clientid(struct nfs_client *clp, const struct cred *cred)
 {
 	struct nfs4_setclientid_res clid = {
 		.clientid = clp->cl_clientid,
@@ -126,7 +126,7 @@ int nfs4_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
  */
 int nfs40_discover_server_trunking(struct nfs_client *clp,
 				   struct nfs_client **result,
-				   struct rpc_cred *cred)
+				   const struct cred *cred)
 {
 	struct nfs4_setclientid_res clid = {
 		.clientid = clp->cl_clientid,
@@ -156,9 +156,9 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 	return status;
 }
 
-struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
+const struct cred *nfs4_get_machine_cred(struct nfs_client *clp)
 {
-	return get_rpccred(rpc_machine_cred());
+	return get_cred(rpc_machine_cred());
 }
 
 static void nfs4_root_machine_cred(struct nfs_client *clp)
@@ -169,10 +169,10 @@ static void nfs4_root_machine_cred(struct nfs_client *clp)
 	clp->cl_rpcclient->cl_principal = NULL;
 }
 
-static struct rpc_cred *
+static const struct cred *
 nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 {
-	struct rpc_cred *cred = NULL;
+	const struct cred *cred = NULL;
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
 
@@ -182,7 +182,7 @@ nfs4_get_renew_cred_server_locked(struct nfs_server *server)
 		sp = rb_entry(pos, struct nfs4_state_owner, so_server_node);
 		if (list_empty(&sp->so_states))
 			continue;
-		cred = get_rpccred(sp->so_cred);
+		cred = get_cred(sp->so_cred);
 		break;
 	}
 	return cred;
@@ -195,9 +195,9 @@ nfs4_get_renew_cred_server_locked(struct nfs_server *server)
  * Returns an rpc_cred with reference count bumped, or NULL.
  * Caller must hold clp->cl_lock.
  */
-struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
+const struct cred *nfs4_get_renew_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *cred = NULL;
+	const struct cred *cred = NULL;
 	struct nfs_server *server;
 
 	/* Use machine credentials if available */
@@ -304,7 +304,7 @@ static void nfs41_finish_session_reset(struct nfs_client *clp)
 	nfs41_setup_state_renewal(clp);
 }
 
-int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
+int nfs41_init_clientid(struct nfs_client *clp, const struct cred *cred)
 {
 	int status;
 
@@ -339,7 +339,7 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
  */
 int nfs41_discover_server_trunking(struct nfs_client *clp,
 				   struct nfs_client **result,
-				   struct rpc_cred *cred)
+				   const struct cred *cred)
 {
 	int status;
 
@@ -377,18 +377,18 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
  * nfs4_get_clid_cred - Acquire credential for a setclientid operation
  * @clp: client state handle
  *
- * Returns an rpc_cred with reference count bumped, or NULL.
+ * Returns a cred with reference count bumped, or NULL.
  */
-struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp)
+const struct cred *nfs4_get_clid_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	cred = nfs4_get_machine_cred(clp);
 	return cred;
 }
 
 static struct nfs4_state_owner *
-nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
+nfs4_find_state_owner_locked(struct nfs_server *server, const struct cred *cred)
 {
 	struct rb_node **p = &server->state_owners.rb_node,
 		       *parent = NULL;
@@ -478,7 +478,7 @@ nfs4_destroy_seqid_counter(struct nfs_seqid_counter *sc)
  */
 static struct nfs4_state_owner *
 nfs4_alloc_state_owner(struct nfs_server *server,
-		struct rpc_cred *cred,
+		const struct cred *cred,
 		gfp_t gfp_flags)
 {
 	struct nfs4_state_owner *sp;
@@ -487,7 +487,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	if (!sp)
 		return NULL;
 	sp->so_server = server;
-	sp->so_cred = get_rpccred(cred);
+	sp->so_cred = get_cred(cred);
 	spin_lock_init(&sp->so_lock);
 	INIT_LIST_HEAD(&sp->so_states);
 	nfs4_init_seqid_counter(&sp->so_seqid);
@@ -516,7 +516,7 @@ nfs4_reset_state_owner(struct nfs4_state_owner *sp)
 static void nfs4_free_state_owner(struct nfs4_state_owner *sp)
 {
 	nfs4_destroy_seqid_counter(&sp->so_seqid);
-	put_rpccred(sp->so_cred);
+	put_cred(sp->so_cred);
 	kfree(sp);
 }
 
@@ -553,7 +553,7 @@ static void nfs4_gc_state_owners(struct nfs_server *server)
  * Returns a pointer to an instantiated nfs4_state_owner struct, or NULL.
  */
 struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
-					      struct rpc_cred *cred,
+					      const struct cred *cred,
 					      gfp_t gfp_flags)
 {
 	struct nfs_client *clp = server->nfs_client;
@@ -1026,7 +1026,7 @@ bool nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
  */
 int nfs4_select_rw_stateid(struct nfs4_state *state,
 		fmode_t fmode, const struct nfs_lock_context *l_ctx,
-		nfs4_stateid *dst, struct rpc_cred **cred)
+		nfs4_stateid *dst, const struct cred **cred)
 {
 	int ret;
 
@@ -1683,7 +1683,7 @@ static void nfs4_state_start_reclaim_reboot(struct nfs_client *clp)
 
 static int nfs4_reclaim_complete(struct nfs_client *clp,
 				 const struct nfs4_state_recovery_ops *ops,
-				 struct rpc_cred *cred)
+				 const struct cred *cred)
 {
 	/* Notify the server we're done reclaiming our state */
 	if (ops->reclaim_complete)
@@ -1734,7 +1734,7 @@ static int nfs4_state_clear_reclaim_reboot(struct nfs_client *clp)
 static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 {
 	const struct nfs4_state_recovery_ops *ops;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int err;
 
 	if (!nfs4_state_clear_reclaim_reboot(clp))
@@ -1742,7 +1742,7 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	ops = clp->cl_mvops->reboot_recovery_ops;
 	cred = nfs4_get_clid_cred(clp);
 	err = nfs4_reclaim_complete(clp, ops, cred);
-	put_rpccred(cred);
+	put_cred(cred);
 	if (err == -NFS4ERR_CONN_NOT_BOUND_TO_SESSION)
 		set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 }
@@ -1838,7 +1838,7 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
 
 static int nfs4_check_lease(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	const struct nfs4_state_maintenance_ops *ops =
 		clp->cl_mvops->state_renewal_ops;
 	int status;
@@ -1854,7 +1854,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 			goto out;
 	}
 	status = ops->renew_lease(clp, cred);
-	put_rpccred(cred);
+	put_cred(cred);
 	if (status == -ETIMEDOUT) {
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 		return 0;
@@ -1914,7 +1914,7 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 
 static int nfs4_establish_lease(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	const struct nfs4_state_recovery_ops *ops =
 		clp->cl_mvops->reboot_recovery_ops;
 	int status;
@@ -1924,7 +1924,7 @@ static int nfs4_establish_lease(struct nfs_client *clp)
 	if (cred == NULL)
 		return -ENOENT;
 	status = ops->establish_clid(clp, cred);
-	put_rpccred(cred);
+	put_cred(cred);
 	if (status != 0)
 		return status;
 	pnfs_destroy_all_layouts(clp);
@@ -1971,7 +1971,7 @@ static int nfs4_purge_lease(struct nfs_client *clp)
  *
  * Returns zero or a negative NFS4ERR status code.
  */
-static int nfs4_try_migration(struct nfs_server *server, struct rpc_cred *cred)
+static int nfs4_try_migration(struct nfs_server *server, const struct cred *cred)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_fs_locations *locations = NULL;
@@ -2039,7 +2039,7 @@ static int nfs4_handle_migration(struct nfs_client *clp)
 	const struct nfs4_state_maintenance_ops *ops =
 				clp->cl_mvops->state_renewal_ops;
 	struct nfs_server *server;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	dprintk("%s: migration reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
@@ -2065,13 +2065,13 @@ static int nfs4_handle_migration(struct nfs_client *clp)
 		rcu_read_unlock();
 		status = nfs4_try_migration(server, cred);
 		if (status < 0) {
-			put_rpccred(cred);
+			put_cred(cred);
 			return status;
 		}
 		goto restart;
 	}
 	rcu_read_unlock();
-	put_rpccred(cred);
+	put_cred(cred);
 	return 0;
 }
 
@@ -2085,7 +2085,7 @@ static int nfs4_handle_lease_moved(struct nfs_client *clp)
 	const struct nfs4_state_maintenance_ops *ops =
 				clp->cl_mvops->state_renewal_ops;
 	struct nfs_server *server;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	dprintk("%s: lease moved reported on \"%s\"\n", __func__,
 			clp->cl_hostname);
@@ -2118,7 +2118,7 @@ static int nfs4_handle_lease_moved(struct nfs_client *clp)
 	rcu_read_unlock();
 
 out:
-	put_rpccred(cred);
+	put_cred(cred);
 	return 0;
 }
 
@@ -2141,7 +2141,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	const struct nfs4_state_recovery_ops *ops =
 				clp->cl_mvops->reboot_recovery_ops;
 	struct rpc_clnt *clnt;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int i, status;
 
 	dprintk("NFS: %s: testing '%s'\n", __func__, clp->cl_hostname);
@@ -2157,7 +2157,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 		goto out_unlock;
 
 	status = ops->detect_trunking(clp, result, cred);
-	put_rpccred(cred);
+	put_cred(cred);
 	switch (status) {
 	case 0:
 	case -EINTR:
@@ -2345,7 +2345,7 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags,
 
 static int nfs4_reset_session(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int status;
 
 	if (!nfs4_has_session(clp))
@@ -2382,13 +2382,13 @@ static int nfs4_reset_session(struct nfs_client *clp)
 			__func__, clp->cl_hostname);
 out:
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 	return status;
 }
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	int ret;
 
 	if (!nfs4_has_session(clp))
@@ -2397,7 +2397,7 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 	cred = nfs4_get_clid_cred(clp);
 	ret = nfs4_proc_bind_conn_to_session(clp, cred);
 	if (cred)
-		put_rpccred(cred);
+		put_cred(cred);
 	clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
 	switch (ret) {
 	case 0:
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d0543e19098a..4e6f52ab242d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -587,7 +587,7 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 }
 
 int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
-		      struct rpc_cred *cred, const struct nfs_rpc_ops *rpc_ops,
+		      const struct cred *cred, const struct nfs_rpc_ops *rpc_ops,
 		      const struct rpc_call_ops *call_ops, int how, int flags)
 {
 	struct rpc_task *task;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d602fe9e1ac8..641425591787 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -274,7 +274,7 @@ pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 		list_del_init(&lo->plh_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	put_rpccred(lo->plh_lc_cred);
+	put_cred(lo->plh_lc_cred);
 	return ld->free_layout_hdr(lo);
 }
 
@@ -1223,7 +1223,7 @@ pnfs_commit_and_return_layout(struct inode *inode)
 bool pnfs_roc(struct inode *ino,
 		struct nfs4_layoutreturn_args *args,
 		struct nfs4_layoutreturn_res *res,
-		const struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_open_context *ctx;
@@ -1475,7 +1475,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	INIT_LIST_HEAD(&lo->plh_return_segs);
 	INIT_LIST_HEAD(&lo->plh_bulk_destroy);
 	lo->plh_inode = ino;
-	lo->plh_lc_cred = get_rpccred(ctx->cred);
+	lo->plh_lc_cred = get_cred(ctx->cred);
 	lo->plh_flags |= 1 << NFS_LAYOUT_INVALID_STID;
 	return lo;
 }
@@ -2607,7 +2607,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-	data->cred = get_rpccred(nfsi->layout->plh_lc_cred);
+	data->cred = get_cred(nfsi->layout->plh_lc_cred);
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
 	data->res.fattr = &data->fattr;
@@ -2620,7 +2620,7 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	if (ld->prepare_layoutcommit) {
 		status = ld->prepare_layoutcommit(&data->args);
 		if (status) {
-			put_rpccred(data->cred);
+			put_cred(data->cred);
 			spin_lock(&inode->i_lock);
 			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
 			if (end_pos > nfsi->layout->plh_lwb)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8d507c361d98..6136714adb56 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -194,7 +194,7 @@ struct pnfs_layout_hdr {
 	u32			plh_return_seq;
 	enum pnfs_iomode	plh_return_iomode;
 	loff_t			plh_lwb; /* last write byte for layoutcommit */
-	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
+	const struct cred	*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
 };
 
@@ -223,7 +223,7 @@ extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 /* nfs4proc.c */
 extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev,
-				   struct rpc_cred *cred);
+				   const struct cred *cred);
 extern struct pnfs_layout_segment* nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags);
 extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync);
 
@@ -270,7 +270,7 @@ int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 bool pnfs_roc(struct inode *ino,
 		struct nfs4_layoutreturn_args *args,
 		struct nfs4_layoutreturn_res *res,
-		const struct rpc_cred *cred);
+		const struct cred *cred);
 void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
 		struct nfs4_layoutreturn_res *res,
 		int ret);
@@ -333,7 +333,7 @@ struct nfs4_deviceid_node {
 
 struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(struct nfs_server *server,
-		const struct nfs4_deviceid *id, struct rpc_cred *cred,
+		const struct nfs4_deviceid *id, const struct cred *cred,
 		gfp_t gfp_mask);
 void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
@@ -677,7 +677,7 @@ static inline bool
 pnfs_roc(struct inode *ino,
 		struct nfs4_layoutreturn_args *args,
 		struct nfs4_layoutreturn_res *res,
-		const struct rpc_cred *cred)
+		const struct cred *cred)
 {
 	return false;
 }
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 2961fcd7a2df..30b00109b667 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -95,7 +95,7 @@ _lookup_deviceid(const struct pnfs_layoutdriver_type *ld,
 static struct nfs4_deviceid_node *
 nfs4_get_device_info(struct nfs_server *server,
 		const struct nfs4_deviceid *dev_id,
-		struct rpc_cred *cred, gfp_t gfp_flags)
+		const struct cred *cred, gfp_t gfp_flags)
 {
 	struct nfs4_deviceid_node *d = NULL;
 	struct pnfs_device *pdev = NULL;
@@ -185,7 +185,7 @@ __nfs4_find_get_deviceid(struct nfs_server *server,
 
 struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(struct nfs_server *server,
-		const struct nfs4_deviceid *id, struct rpc_cred *cred,
+		const struct nfs4_deviceid *id, const struct cred *cred,
 		gfp_t gfp_mask)
 {
 	long hash = nfs4_deviceid_hash(id);
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 03aaa60c7768..753ca6f33fb7 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -688,7 +688,7 @@ static int _nfs4_pnfs_v4_ds_connect(struct nfs_server *mds_srv,
 					  rpc_clnt_setup_test_and_add_xprt,
 					  &rpcdata);
 			if (xprtdata.cred)
-				put_rpccred(xprtdata.cred);
+				put_cred(xprtdata.cred);
 		} else {
 			clp = nfs4_set_ds_client(mds_srv,
 						(struct sockaddr *)&da->da_addr,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 70df66a72d15..402225e8f378 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -495,25 +495,18 @@ nfs_proc_readdir(struct dentry *dentry, const struct cred *cred,
 		.count		= count,
 		.pages		= pages,
 	};
-	struct auth_cred acred = {
-		.cred		= cred,
-	};
 	struct rpc_message	msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_READDIR],
 		.rpc_argp	= &arg,
-		.rpc_cred	= rpc_lookup_generic_cred(&acred,
-							  0, GFP_NOFS),
+		.rpc_cred	= cred,
 	};
 	int			status;
 
 	dprintk("NFS call  readdir %d\n", (unsigned int)cookie);
-	if (!msg.rpc_cred)
-		return -ENOMEM;
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
 
 	nfs_invalidate_atime(dir);
 
-	put_rpccred(msg.rpc_cred);
 	dprintk("NFS reply readdir: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 630b4a3c1a93..0964d669df8e 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -31,7 +31,7 @@
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
-	put_rpccred(data->cred);
+	put_cred(data->cred);
 	kfree(data->args.name.name);
 	kfree(data);
 }
@@ -177,11 +177,7 @@ nfs_async_unlink(struct dentry *dentry, const struct qstr *name)
 		goto out_free;
 	data->args.name.len = name->len;
 
-	data->cred = rpc_lookup_cred();
-	if (IS_ERR(data->cred)) {
-		status = PTR_ERR(data->cred);
-		goto out_free_name;
-	}
+	data->cred = get_current_cred();
 	data->res.dir_attr = &data->dir_attr;
 	init_waitqueue_head(&data->wq);
 
@@ -202,8 +198,7 @@ nfs_async_unlink(struct dentry *dentry, const struct qstr *name)
 	return 0;
 out_unlock:
 	spin_unlock(&dentry->d_lock);
-	put_rpccred(data->cred);
-out_free_name:
+	put_cred(data->cred);
 	kfree(data->args.name.name);
 out_free:
 	kfree(data);
@@ -307,7 +302,7 @@ static void nfs_async_rename_release(void *calldata)
 	iput(data->old_dir);
 	iput(data->new_dir);
 	nfs_sb_deactive(sb);
-	put_rpccred(data->cred);
+	put_cred(data->cred);
 	kfree(data);
 }
 
@@ -352,7 +347,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 		return ERR_PTR(-ENOMEM);
 	task_setup_data.callback_data = data;
 
-	data->cred = rpc_lookup_cred();
+	data->cred = get_current_cred();
 	if (IS_ERR(data->cred)) {
 		struct rpc_task *task = ERR_CAST(data->cred);
 		kfree(data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 40c8e12165ec..d0998d9707c0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1250,7 +1250,7 @@ bool nfs_ctx_key_to_expire(struct nfs_open_context *ctx, struct inode *inode)
 	struct rpc_auth *auth = NFS_SERVER(inode)->client->cl_auth;
 	struct rpc_cred *cred = ctx->ll_cred;
 	struct auth_cred acred = {
-		.cred = ctx->cred->cr_cred,
+		.cred = ctx->cred,
 	};
 
 	if (cred && !cred->cr_ops->crmatch(&acred, cred, 0)) {
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d48a18087686..48601d1b36d3 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -746,27 +746,21 @@ static int max_cb_time(struct net *net)
 	return max(nn->nfsd4_lease/10, (time_t)1) * HZ;
 }
 
-static struct rpc_cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
+static const struct cred *get_backchannel_cred(struct nfs4_client *clp, struct rpc_clnt *client, struct nfsd4_session *ses)
 {
 	if (clp->cl_minorversion == 0) {
 		client->cl_principal = "nfs";
-		return get_rpccred(rpc_machine_cred());
+		return get_cred(rpc_machine_cred());
 	} else {
-		struct rpc_auth *auth = client->cl_auth;
-		struct auth_cred acred = {};
 		struct cred *kcred;
-		struct rpc_cred *ret;
 
 		kcred = prepare_kernel_cred(NULL);
-		if (!acred.cred)
+		if (!kcred)
 			return NULL;
 
 		kcred->uid = ses->se_cb_sec.uid;
 		kcred->gid = ses->se_cb_sec.gid;
-		acred.cred = kcred;
-		ret = auth->au_ops->lookup_cred(client->cl_auth, &acred, 0);
-		put_cred(kcred);
-		return ret;
+		return kcred;
 	}
 }
 
@@ -789,7 +783,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 	};
 	struct rpc_clnt *client;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 
 	if (clp->cl_minorversion == 0) {
 		if (!clp->cl_cred.cr_principal &&
@@ -1118,7 +1112,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	if (clp->cl_cb_client) {
 		rpc_shutdown_client(clp->cl_cb_client);
 		clp->cl_cb_client = NULL;
-		put_rpccred(clp->cl_cb_cred);
+		put_cred(clp->cl_cb_cred);
 		clp->cl_cb_cred = NULL;
 	}
 	if (clp->cl_cb_conn.cb_xprt) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0b15dac7e609..61938e75c9e2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -327,7 +327,7 @@ struct nfs4_client {
 #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
 					 1 << NFSD4_CLIENT_CB_KILL)
 	unsigned long		cl_flags;
-	struct rpc_cred		*cl_cb_cred;
+	const struct cred	*cl_cb_cred;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
 #define NFSD4_CB_UP		0
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 099058e1178b..984614eed330 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -245,6 +245,17 @@ static inline const struct cred *get_cred(const struct cred *cred)
 	return get_new_cred(nonconst_cred);
 }
 
+static inline const struct cred *get_cred_rcu(const struct cred *cred)
+{
+	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return NULL;
+	if (!atomic_inc_not_zero(&nonconst_cred->usage))
+		return NULL;
+	validate_creds(cred);
+	return cred;
+}
+
 /**
  * put_cred - Release a reference to a set of credentials
  * @cred: The credentials to release
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 702b6fe5d642..3cb005c66c34 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -69,7 +69,7 @@ struct nfs_open_context {
 	struct nfs_lock_context lock_context;
 	fl_owner_t flock_owner;
 	struct dentry *dentry;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	struct rpc_cred *ll_cred;	/* low-level cred - use to check for expiry */
 	struct nfs4_state *state;
 	fmode_t mode;
@@ -367,7 +367,7 @@ extern void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 				struct nfs4_label *label);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
-extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_cred *cred, fmode_t mode);
+extern struct nfs_open_context *nfs_find_open_context(struct inode *inode, const struct cred *cred, fmode_t mode);
 extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, fmode_t f_mode, struct file *filp);
 extern void nfs_inode_attach_open_context(struct nfs_open_context *ctx);
 extern void nfs_file_set_open_context(struct file *filp, struct nfs_open_context *ctx);
@@ -438,7 +438,7 @@ static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 	return filp->private_data;
 }
 
-static inline struct rpc_cred *nfs_file_cred(struct file *file)
+static inline const struct cred *nfs_file_cred(struct file *file)
 {
 	if (file != NULL) {
 		struct nfs_open_context *ctx =
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b33a7f3577e1..28cf7d194a2e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -269,7 +269,7 @@ struct nfs4_layoutget_res {
 struct nfs4_layoutget {
 	struct nfs4_layoutget_args args;
 	struct nfs4_layoutget_res res;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	gfp_t gfp_flags;
 };
 
@@ -308,7 +308,7 @@ struct nfs4_layoutcommit_data {
 	struct rpc_task task;
 	struct nfs_fattr fattr;
 	struct list_head lseg_list;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	struct inode *inode;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;
@@ -333,7 +333,7 @@ struct nfs4_layoutreturn_res {
 struct nfs4_layoutreturn {
 	struct nfs4_layoutreturn_args args;
 	struct nfs4_layoutreturn_res res;
-	struct rpc_cred *cred;
+	const struct cred *cred;
 	struct nfs_client *clp;
 	struct inode *inode;
 	int rpc_status;
@@ -1439,7 +1439,7 @@ enum {
 struct nfs_io_completion;
 struct nfs_pgio_header {
 	struct inode		*inode;
-	struct rpc_cred		*cred;
+	const struct cred		*cred;
 	struct list_head	pages;
 	struct nfs_page		*req;
 	struct nfs_writeverf	verf;		/* Used for writes */
@@ -1500,7 +1500,7 @@ struct nfs_commit_info {
 struct nfs_commit_data {
 	struct rpc_task		task;
 	struct inode		*inode;
-	struct rpc_cred		*cred;
+	const struct cred		*cred;
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
 	struct list_head	pages;		/* Coalesced requests we wish to flush */
@@ -1531,7 +1531,7 @@ struct nfs_unlinkdata {
 	struct nfs_removeres res;
 	struct dentry *dentry;
 	wait_queue_head_t wq;
-	struct rpc_cred	*cred;
+	const struct cred *cred;
 	struct nfs_fattr dir_attr;
 	long timeout;
 };
@@ -1539,7 +1539,7 @@ struct nfs_unlinkdata {
 struct nfs_renamedata {
 	struct nfs_renameargs	args;
 	struct nfs_renameres	res;
-	struct rpc_cred		*cred;
+	const struct cred	*cred;
 	struct inode		*old_dir;
 	struct dentry		*old_dentry;
 	struct nfs_fattr	old_fattr;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 0513db589739..ff289e8b24c0 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -67,7 +67,7 @@ struct rpc_cred {
 #define RPCAUTH_CRED_HASHED	2
 #define RPCAUTH_CRED_NEGATIVE	3
 
-struct rpc_cred *rpc_machine_cred(void);
+const struct cred *rpc_machine_cred(void);
 
 /*
  * Client authentication handle
@@ -193,23 +193,5 @@ struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 	return cred;
 }
 
-/**
- * get_rpccred_rcu - get a reference to a cred using rcu-protected pointer
- * @cred: cred of which to take a reference
- *
- * In some cases, we may have a pointer to a credential to which we
- * want to take a reference, but don't already have one. Because these
- * objects are freed using RCU, we can access the cr_count while its
- * on its way to destruction and only take a reference if it's not already
- * zero.
- */
-static inline struct rpc_cred *
-get_rpccred_rcu(struct rpc_cred *cred)
-{
-	if (atomic_inc_not_zero(&cred->cr_count))
-		return cred;
-	return NULL;
-}
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_AUTH_H */
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 39c7b05d845d..fbc1c32924f1 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -26,7 +26,7 @@ struct rpc_message {
 	const struct rpc_procinfo *rpc_proc;	/* Procedure information */
 	void *			rpc_argp;	/* Arguments */
 	void *			rpc_resp;	/* Result */
-	struct rpc_cred *	rpc_cred;	/* Credentials */
+	const struct cred *	rpc_cred;	/* Credentials */
 };
 
 struct rpc_call_ops;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 66559de0c6f1..6121eaa94e0e 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -40,15 +40,15 @@ static const struct rpc_authops *auth_flavors[RPC_AUTH_MAXFLAVOR] = {
 static LIST_HEAD(cred_unused);
 static unsigned long number_cred_unused;
 
-static struct rpc_cred machine_cred = {
-	.cr_count = ATOMIC_INIT(1),
+static struct cred machine_cred = {
+	.usage = ATOMIC_INIT(1),
 };
 
 /*
  * Return the machine_cred pointer to be used whenever
  * the a generic machine credential is needed.
  */
-struct rpc_cred *rpc_machine_cred(void)
+const struct cred *rpc_machine_cred(void)
 {
 	return &machine_cred;
 }
@@ -695,11 +695,15 @@ rpcauth_bind_new_cred(struct rpc_task *task, int lookupflags)
 }
 
 static int
-rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
+rpcauth_bindcred(struct rpc_task *task, const struct cred *cred, int flags)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_cred *new = NULL;
 	int lookupflags = 0;
+	struct rpc_auth *auth = task->tk_client->cl_auth;
+	struct auth_cred acred = {
+		.cred = cred,
+	};
 
 	if (flags & RPC_TASK_ASYNC)
 		lookupflags |= RPCAUTH_LOOKUP_NEW;
@@ -708,7 +712,7 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 		new = task->tk_op_cred->cr_ops->crbind(task, task->tk_op_cred,
 						       lookupflags);
 	if (cred != NULL && cred != &machine_cred)
-		new = cred->cr_ops->crbind(task, cred, lookupflags);
+		new = auth->au_ops->lookup_cred(auth, &acred, lookupflags);
 	else if (cred == &machine_cred)
 		new = rpcauth_bind_machine_cred(task, lookupflags);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f673d45e1608..7b1a44bf24f7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1018,7 +1018,7 @@ rpc_task_set_rpc_message(struct rpc_task *task, const struct rpc_message *msg)
 		task->tk_msg.rpc_argp = msg->rpc_argp;
 		task->tk_msg.rpc_resp = msg->rpc_resp;
 		if (msg->rpc_cred != NULL)
-			task->tk_msg.rpc_cred = get_rpccred(msg->rpc_cred);
+			task->tk_msg.rpc_cred = get_cred(msg->rpc_cred);
 	}
 }
 
@@ -2540,7 +2540,7 @@ struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 		.rpc_op_cred = cred,
 		.callback_ops = (ops != NULL) ? ops : &rpc_default_ops,
 		.callback_data = data,
-		.flags = flags,
+		.flags = flags | RPC_TASK_NULLCREDS,
 	};
 
 	return rpc_run_task(&task_setup_data);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 398ca786abcc..4caf0c53e0a7 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1016,7 +1016,7 @@ static void rpc_release_resources_task(struct rpc_task *task)
 {
 	xprt_release(task);
 	if (task->tk_msg.rpc_cred) {
-		put_rpccred(task->tk_msg.rpc_cred);
+		put_cred(task->tk_msg.rpc_cred);
 		task->tk_msg.rpc_cred = NULL;
 	}
 	rpc_task_release_client(task);


