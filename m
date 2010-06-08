From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 3/7] pnfs-submit: change stateid to be a union
Date: Tue,  8 Jun 2010 15:14:57 -0700
Message-ID: <1276035301-2019-4-git-send-email-batsakis@netapp.com>
References: <1276035301-2019-1-git-send-email-batsakis@netapp.com>
 <1276035301-2019-2-git-send-email-batsakis@netapp.com>
 <1276035301-2019-3-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48250 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab0FHWOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 18:14:50 -0400
In-Reply-To: <1276035301-2019-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In NFSv4.1 the stateid consists of the other and seqid fields. For layout
processing we need to numerically compare the seqid value of layout stateids.
To do so, introduce a union to nfs4_stateid to swtich between opaque(16 bytes)
 and opaque(12 bytes) / __be32

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback_proc.c |   13 +++++++------
 fs/nfs/callback_xdr.c  |    2 +-
 fs/nfs/delegation.c    |   19 +++++++++++--------
 fs/nfs/nfs4proc.c      |   41 +++++++++++++++++++++++++----------------
 fs/nfs/nfs4state.c     |    4 ++--
 fs/nfs/nfs4xdr.c       |   38 +++++++++++++++++++++-----------------
 fs/nfs/pnfs.c          |   11 ++++++-----
 fs/nfsd/nfs4callback.c |    1 -
 include/linux/nfs4.h   |   16 ++++++++++++++--
 9 files changed, 87 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0053fbb..8752239 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -121,8 +121,9 @@ out:
 
 int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
-	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
-					 sizeof(delegation->stateid.data)) != 0)
+	if (delegation == NULL || memcmp(delegation->stateid.u.data,
+					 stateid->u.data,
+					 sizeof(delegation->stateid.u.data)))
 		return 0;
 	return 1;
 }
@@ -331,11 +332,11 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
 	if (delegation == NULL)
 		return 0;
 
-	/* seqid is 4-bytes long */
-	if (((u32 *) &stateid->data)[0] != 0)
+	if (stateid->u.stateid.seqid != 0)
 		return 0;
-	if (memcmp(&delegation->stateid.data[4], &stateid->data[4],
-		   sizeof(stateid->data)-4))
+	if (memcmp(&delegation->stateid.u.stateid.other,
+		   &stateid->u.stateid.other,
+		   NFS4_STATEID_OTHER_SIZE))
 		return 0;
 
 	return 1;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 1856181..b88db4d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -137,7 +137,7 @@ static __be32 decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 	p = read_buf(xdr, 16);
 	if (unlikely(p == NULL))
 		return htonl(NFS4ERR_RESOURCE);
-	memcpy(stateid->data, p, 16);
+	memcpy(stateid->u.data, p, 16);
 	return 0;
 }
 
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 3016345..13b3e8d 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -104,7 +104,8 @@ again:
 			continue;
 		if (!test_bit(NFS_DELEGATED_STATE, &state->flags))
 			continue;
-		if (memcmp(state->stateid.data, stateid->data, sizeof(state->stateid.data)) != 0)
+		if (memcmp(state->stateid.u.data, stateid->u.data,
+			   sizeof(state->stateid.u.data)) != 0)
 			continue;
 		get_nfs_open_context(ctx);
 		spin_unlock(&inode->i_lock);
@@ -133,8 +134,8 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, st
 	if (delegation != NULL) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL) {
-			memcpy(delegation->stateid.data, res->delegation.data,
-			       sizeof(delegation->stateid.data));
+			memcpy(delegation->stateid.u.data, res->delegation.u.data,
+			       sizeof(delegation->stateid.u.data));
 			delegation->type = res->delegation_type;
 			delegation->maxsize = res->maxsize;
 			oldcred = delegation->cred;
@@ -187,8 +188,9 @@ static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfs
 	if (delegation == NULL)
 		goto nomatch;
 	spin_lock(&delegation->lock);
-	if (stateid != NULL && memcmp(delegation->stateid.data, stateid->data,
-				sizeof(delegation->stateid.data)) != 0)
+	if (stateid != NULL && memcmp(delegation->stateid.u.data,
+				      stateid->u.data,
+				      sizeof(delegation->stateid.u.data)) != 0)
 		goto nomatch_unlock;
 	list_del_rcu(&delegation->super_list);
 	delegation->inode = NULL;
@@ -216,8 +218,8 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation = kmalloc(sizeof(*delegation), GFP_NOFS);
 	if (delegation == NULL)
 		return -ENOMEM;
-	memcpy(delegation->stateid.data, res->delegation.data,
-			sizeof(delegation->stateid.data));
+	memcpy(delegation->stateid.u.data, res->delegation.u.data,
+			sizeof(delegation->stateid.u.data));
 	delegation->type = res->delegation_type;
 	delegation->maxsize = res->maxsize;
 	delegation->change_attr = nfsi->change_attr;
@@ -562,7 +564,8 @@ int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
 	rcu_read_lock();
 	delegation = rcu_dereference(nfsi->delegation);
 	if (delegation != NULL) {
-		memcpy(dst->data, delegation->stateid.data, sizeof(dst->data));
+		memcpy(dst->u.data, delegation->stateid.u.data,
+		       sizeof(dst->u.data));
 		ret = 1;
 	}
 	rcu_read_unlock();
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bf854fe..ee3e3bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -867,8 +867,10 @@ static void update_open_stateflags(struct nfs4_state *state, fmode_t fmode)
 static void nfs_set_open_stateid_locked(struct nfs4_state *state, nfs4_stateid *stateid, fmode_t fmode)
 {
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-		memcpy(state->stateid.data, stateid->data, sizeof(state->stateid.data));
-	memcpy(state->open_stateid.data, stateid->data, sizeof(state->open_stateid.data));
+		memcpy(state->stateid.u.data, stateid->u.data,
+		       sizeof(state->stateid.u.data));
+	memcpy(state->open_stateid.u.data, stateid->u.data,
+	       sizeof(state->open_stateid.u.data));
 	switch (fmode) {
 		case FMODE_READ:
 			set_bit(NFS_O_RDONLY_STATE, &state->flags);
@@ -896,7 +898,8 @@ static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_s
 	 */
 	write_seqlock(&state->seqlock);
 	if (deleg_stateid != NULL) {
-		memcpy(state->stateid.data, deleg_stateid->data, sizeof(state->stateid.data));
+		memcpy(state->stateid.u.data, deleg_stateid->u.data,
+		       sizeof(state->stateid.u.data));
 		set_bit(NFS_DELEGATED_STATE, &state->flags);
 	}
 	if (open_stateid != NULL)
@@ -927,7 +930,8 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 
 	if (delegation == NULL)
 		delegation = &deleg_cur->stateid;
-	else if (memcmp(deleg_cur->stateid.data, delegation->data, NFS4_STATEID_SIZE) != 0)
+	else if (memcmp(deleg_cur->stateid.u.data, delegation->u.data,
+			NFS4_STATEID_SIZE) != 0)
 		goto no_delegation_unlock;
 
 	nfs_mark_delegation_referenced(deleg_cur);
@@ -989,7 +993,8 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 			break;
 		}
 		/* Save the delegation */
-		memcpy(stateid.data, delegation->stateid.data, sizeof(stateid.data));
+		memcpy(stateid.u.data, delegation->stateid.u.data,
+		       sizeof(stateid.u.data));
 		rcu_read_unlock();
 		ret = nfs_may_open(state->inode, state->owner->so_cred, open_mode);
 		if (ret != 0)
@@ -1155,10 +1160,13 @@ static int nfs4_open_recover(struct nfs4_opendata *opendata, struct nfs4_state *
 	 * Check if we need to update the current stateid.
 	 */
 	if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0 &&
-	    memcmp(state->stateid.data, state->open_stateid.data, sizeof(state->stateid.data)) != 0) {
+	    memcmp(state->stateid.u.data, state->open_stateid.u.data,
+		   sizeof(state->stateid.u.data)) != 0) {
 		write_seqlock(&state->seqlock);
 		if (test_bit(NFS_DELEGATED_STATE, &state->flags) == 0)
-			memcpy(state->stateid.data, state->open_stateid.data, sizeof(state->stateid.data));
+			memcpy(state->stateid.u.data,
+			       state->open_stateid.u.data,
+			       sizeof(state->stateid.u.data));
 		write_sequnlock(&state->seqlock);
 	}
 	pnfs4_layout_reclaim(state);
@@ -1229,8 +1237,8 @@ static int _nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs
 	if (IS_ERR(opendata))
 		return PTR_ERR(opendata);
 	opendata->o_arg.claim = NFS4_OPEN_CLAIM_DELEGATE_CUR;
-	memcpy(opendata->o_arg.u.delegation.data, stateid->data,
-			sizeof(opendata->o_arg.u.delegation.data));
+	memcpy(opendata->o_arg.u.delegation.u.data, stateid->u.data,
+			sizeof(opendata->o_arg.u.delegation.u.data));
 	ret = nfs4_open_recover(opendata, state);
 	nfs4_opendata_put(opendata);
 	return ret;
@@ -1288,8 +1296,8 @@ static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 	if (RPC_ASSASSINATED(task))
 		return;
 	if (data->rpc_status == 0) {
-		memcpy(data->o_res.stateid.data, data->c_res.stateid.data,
-				sizeof(data->o_res.stateid.data));
+		memcpy(data->o_res.stateid.u.data, data->c_res.stateid.u.data,
+				sizeof(data->o_res.stateid.u.data));
 		nfs_confirm_seqid(&data->owner->so_seqid, 0);
 		renew_lease(data->o_res.server, data->timestamp);
 		data->rpc_done = 1;
@@ -4132,9 +4140,10 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		return;
 	switch (task->tk_status) {
 		case 0:
-			memcpy(calldata->lsp->ls_stateid.data,
-					calldata->res.stateid.data,
-					sizeof(calldata->lsp->ls_stateid.data));
+			memcpy(calldata->lsp->ls_stateid.u.data,
+					calldata->res.stateid.u.data,
+					sizeof(calldata->lsp->ls_stateid.u.
+					       data));
 			renew_lease(calldata->server, calldata->timestamp);
 			break;
 		case -NFS4ERR_BAD_STATEID:
@@ -4348,8 +4357,8 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 			goto out;
 	}
 	if (data->rpc_status == 0) {
-		memcpy(data->lsp->ls_stateid.data, data->res.stateid.data,
-					sizeof(data->lsp->ls_stateid.data));
+		memcpy(data->lsp->ls_stateid.u.data, data->res.stateid.u.data,
+					sizeof(data->lsp->ls_stateid.u.data));
 		data->lsp->ls_flags |= NFS_LOCK_INITIALIZED;
 		renew_lease(NFS_SERVER(data->ctx->path.dentry->d_inode), data->timestamp);
 	}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8185c1e..0f44704 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1055,8 +1055,8 @@ restart:
 				 * Open state on this file cannot be recovered
 				 * All we can do is revert to using the zero stateid.
 				 */
-				memset(state->stateid.data, 0,
-					sizeof(state->stateid.data));
+				memset(state->stateid.u.data, 0,
+					sizeof(state->stateid.u.data));
 				/* Mark the file as being 'closed' */
 				state->state = 0;
 				break;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 31a4b89..301ae14 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -986,7 +986,7 @@ static void encode_close(struct xdr_stream *xdr, const struct nfs_closeargs *arg
 	p = reserve_space(xdr, 8+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_CLOSE);
 	*p++ = cpu_to_be32(arg->seqid->sequence->counter);
-	xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, arg->stateid->u.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_close_maxsz;
 }
@@ -1160,7 +1160,8 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	if (args->new_lock_owner){
 		p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+32);
 		*p++ = cpu_to_be32(args->open_seqid->sequence->counter);
-		p = xdr_encode_opaque_fixed(p, args->open_stateid->data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, args->open_stateid->u.data,
+					    NFS4_STATEID_SIZE);
 		*p++ = cpu_to_be32(args->lock_seqid->sequence->counter);
 		p = xdr_encode_hyper(p, args->lock_owner.clientid);
 		*p++ = cpu_to_be32(16);
@@ -1169,7 +1170,7 @@ static void encode_lock(struct xdr_stream *xdr, const struct nfs_lock_args *args
 	}
 	else {
 		p = reserve_space(xdr, NFS4_STATEID_SIZE+4);
-		p = xdr_encode_opaque_fixed(p, args->lock_stateid->data, NFS4_STATEID_SIZE);
+		p = xdr_encode_opaque_fixed(p, args->lock_stateid->u.data, NFS4_STATEID_SIZE);
 		*p = cpu_to_be32(args->lock_seqid->sequence->counter);
 	}
 	hdr->nops++;
@@ -1201,7 +1202,8 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	*p++ = cpu_to_be32(OP_LOCKU);
 	*p++ = cpu_to_be32(nfs4_lock_type(args->fl, 0));
 	*p++ = cpu_to_be32(args->seqid->sequence->counter);
-	p = xdr_encode_opaque_fixed(p, args->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, args->stateid->u.data,
+				    NFS4_STATEID_SIZE);
 	p = xdr_encode_hyper(p, args->fl->fl_start);
 	xdr_encode_hyper(p, nfs4_lock_length(args->fl));
 	hdr->nops++;
@@ -1351,7 +1353,7 @@ static inline void encode_claim_delegate_cur(struct xdr_stream *xdr, const struc
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(NFS4_OPEN_CLAIM_DELEGATE_CUR);
-	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, stateid->u.data, NFS4_STATEID_SIZE);
 	encode_string(xdr, name->len, name->name);
 }
 
@@ -1382,7 +1384,7 @@ static void encode_open_confirm(struct xdr_stream *xdr, const struct nfs_open_co
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_CONFIRM);
-	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid->u.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	hdr->nops++;
 	hdr->replen += decode_open_confirm_maxsz;
@@ -1394,7 +1396,7 @@ static void encode_open_downgrade(struct xdr_stream *xdr, const struct nfs_close
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE+4);
 	*p++ = cpu_to_be32(OP_OPEN_DOWNGRADE);
-	p = xdr_encode_opaque_fixed(p, arg->stateid->data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, arg->stateid->u.data, NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(arg->seqid->sequence->counter);
 	encode_share_access(xdr, arg->fmode);
 	hdr->nops++;
@@ -1432,9 +1434,10 @@ static void encode_stateid(struct xdr_stream *xdr, const struct nfs_open_context
 	p = reserve_space(xdr, NFS4_STATEID_SIZE);
 	if (ctx->state != NULL) {
 		nfs4_copy_stateid(&stateid, ctx->state, ctx->lockowner);
-		xdr_encode_opaque_fixed(p, stateid.data, NFS4_STATEID_SIZE);
+		xdr_encode_opaque_fixed(p, stateid.u.data,
+					NFS4_STATEID_SIZE);
 	} else
-		xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+		xdr_encode_opaque_fixed(p, zero_stateid.u.data, NFS4_STATEID_SIZE);
 }
 
 static void encode_read(struct xdr_stream *xdr, const struct nfs_readargs *args, struct compound_hdr *hdr)
@@ -1548,7 +1551,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
-	xdr_encode_opaque_fixed(p, zero_stateid.data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, zero_stateid.u.data, NFS4_STATEID_SIZE);
 	p = reserve_space(xdr, 2*4);
 	*p++ = cpu_to_be32(1);
 	*p = cpu_to_be32(FATTR4_WORD0_ACL);
@@ -1579,7 +1582,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(OP_SETATTR);
-	xdr_encode_opaque_fixed(p, arg->stateid.data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, arg->stateid.u.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_setattr_maxsz;
 	encode_attrs(xdr, arg->iap, server);
@@ -1642,7 +1645,7 @@ static void encode_delegreturn(struct xdr_stream *xdr, const nfs4_stateid *state
 	p = reserve_space(xdr, 4+NFS4_STATEID_SIZE);
 
 	*p++ = cpu_to_be32(OP_DELEGRETURN);
-	xdr_encode_opaque_fixed(p, stateid->data, NFS4_STATEID_SIZE);
+	xdr_encode_opaque_fixed(p, stateid->u.data, NFS4_STATEID_SIZE);
 	hdr->nops++;
 	hdr->replen += decode_delegreturn_maxsz;
 }
@@ -1833,7 +1836,8 @@ encode_layoutget(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->lseg.offset);
 	p = xdr_encode_hyper(p, args->lseg.length);
 	p = xdr_encode_hyper(p, args->minlength);
-	p = xdr_encode_opaque_fixed(p, &args->stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, &args->stateid.u.data,
+				    NFS4_STATEID_SIZE);
 	*p = cpu_to_be32(args->maxcount);
 
 	dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
@@ -1865,7 +1869,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	p = xdr_encode_hyper(p, args->lseg.offset);
 	p = xdr_encode_hyper(p, args->lseg.length);
 	*p++ = cpu_to_be32(0);     /* reclaim */
-	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_encode_opaque_fixed(p, args->stateid.u.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1);     /* newoffset = TRUE */
 	p = xdr_encode_hyper(p, args->lastbytewritten);
 	*p = cpu_to_be32(args->time_modify_changed != 0);
@@ -1912,7 +1916,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->lseg.offset);
 		p = xdr_encode_hyper(p, args->lseg.length);
-		p = xdr_encode_opaque_fixed(p, &args->stateid.data,
+		p = xdr_encode_opaque_fixed(p, &args->stateid.u.data,
 					    NFS4_STATEID_SIZE);
 
 		dprintk("%s: call %pF\n", __func__,
@@ -3935,7 +3939,7 @@ static int decode_opaque_fixed(struct xdr_stream *xdr, void *buf, size_t len)
 
 static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
 {
-	return decode_opaque_fixed(xdr, stateid->data, NFS4_STATEID_SIZE);
+	return decode_opaque_fixed(xdr, stateid->u.data, NFS4_STATEID_SIZE);
 }
 
 static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
@@ -5183,7 +5187,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (unlikely(!p))
 		goto out_overflow;
 	res->return_on_close = be32_to_cpup(p++);
-	p = xdr_decode_opaque_fixed(p, res->stateid.data, NFS4_STATEID_SIZE);
+	p = xdr_decode_opaque_fixed(p, res->stateid.u.data, NFS4_STATEID_SIZE);
 	layout_count = be32_to_cpup(p);
 	if (!layout_count) {
 		dprintk("%s: server responded with empty layout array\n",
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4e35ad9..8202523 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -489,7 +489,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			const nfs4_stateid *stateid)
 {
 	write_seqlock(&lo->seqlock);
-	memcpy(lo->stateid.data, stateid->data, sizeof(lo->stateid.data));
+	memcpy(lo->stateid.u.data, stateid->u.data, sizeof(lo->stateid.u.data));
 	write_sequnlock(&lo->seqlock);
 }
 
@@ -502,7 +502,8 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
 
 	do {
 		seq = read_seqbegin(&lo->seqlock);
-		memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
+		memcpy(dst->u.data, lo->stateid.u.data,
+		       sizeof(lo->stateid.u.data));
 	} while (read_seqretry(&lo->seqlock, seq));
 
 	dprintk("<-- %s\n", __func__);
@@ -517,8 +518,8 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 
 	do {
 		seq = read_seqbegin(&state->seqlock);
-		memcpy(dst->data, state->stateid.data,
-				sizeof(state->stateid.data));
+		memcpy(dst->u.data, state->stateid.u.data,
+				sizeof(state->stateid.u.data));
 	} while (read_seqretry(&state->seqlock, seq));
 
 	dprintk("<-- %s\n", __func__);
@@ -564,7 +565,7 @@ get_layout(struct inode *ino,
 	lgp->args.inode = ino;
 	lgp->lsegpp = lsegpp;
 
-	if (!memcmp(lo->stateid.data, &zero_stateid, NFS4_STATEID_SIZE)) {
+	if (!memcmp(lo->stateid.u.data, &zero_stateid, NFS4_STATEID_SIZE)) {
 		struct nfs_open_context *oldctx = ctx;
 
 		if (!oldctx) {
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index eb78e7e..d80356a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -41,7 +41,6 @@
 
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
-#define NFS4_STATEID_SIZE 16
 
 /* Index of predefined Linux callback client operations */
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 219e6b4..46bd627 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -17,7 +17,9 @@
 
 #define NFS4_BITMAP_SIZE	2
 #define NFS4_VERIFIER_SIZE	8
-#define NFS4_STATEID_SIZE	16
+#define NFS4_STATEID_SEQID_SIZE 4
+#define NFS4_STATEID_OTHER_SIZE 12
+#define NFS4_STATEID_SIZE	(NFS4_STATEID_SEQID_SIZE + NFS4_STATEID_OTHER_SIZE)
 #define NFS4_FHSIZE		128
 #define NFS4_MAXPATHLEN		PATH_MAX
 #define NFS4_MAXNAMLEN		NAME_MAX
@@ -174,7 +176,17 @@ struct nfs4_acl {
 };
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
-typedef struct { char data[NFS4_STATEID_SIZE]; } nfs4_stateid;
+
+struct nfs41_stateid {
+	__be32 seqid;
+	char other[NFS4_STATEID_OTHER_SIZE];
+} __attribute__ ((packed));
+typedef struct {
+	union {
+		char data[NFS4_STATEID_SIZE];
+		struct nfs41_stateid stateid;
+	} u;
+} nfs4_stateid;
 
 enum nfs_opnum4 {
 	OP_ACCESS = 3,
-- 
1.6.2.5

