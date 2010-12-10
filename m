Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab0LJGI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:56 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLv023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:55 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/22] pnfs-submit: wave2: remove all LAYOUTRETURN code
Date: Thu,  9 Dec 2010 20:22:55 -0500
Message-Id: <1291944177-7819-21-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

remove boilerplate nfs4proc and nfs4xdr code
pnfs_return_layout is only called by evict_inode.  Just have it forget everything

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |  118 -----------------------------------------------------
 fs/nfs/nfs4xdr.c  |  111 -------------------------------------------------
 fs/nfs/pnfs.c     |   62 +---------------------------
 fs/nfs/pnfs.h     |    2 -
 4 files changed, 1 insertions(+), 292 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 57f5a8a..9b15535 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5554,124 +5554,6 @@ out:
 	return 0;
 }
 
-static void
-nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfs4_layoutreturn *lrp = calldata;
-
-	dprintk("--> %s\n", __func__);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct nfs_inode *nfsi = NFS_I(lrp->args.inode);
-
-		if (pnfs_return_layout_barrier(nfsi, &lrp->args.range)) {
-			dprintk("%s: waiting on barrier\n", __func__);
-			rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
-			return;
-		}
-	}
-	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
-				&lrp->res.seq_res, 0, task))
-		return;
-	rpc_call_start(task);
-}
-
-static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
-{
-	struct nfs4_layoutreturn *lrp = calldata;
-	struct nfs_server *server;
-
-	dprintk("--> %s\n", __func__);
-
-	if (!nfs4_sequence_done(task, &lrp->res.seq_res))
-		return;
-
-	if (lrp->args.return_type == RETURN_FILE)
-		server = NFS_SERVER(lrp->args.inode);
-	else
-		server = NULL;
-	if (nfs4_async_handle_error(task, server, NULL, lrp->clp) == -EAGAIN) {
-		nfs_restart_rpc(task, lrp->clp);
-		return;
-	}
-	if ((task->tk_status == 0) && (lrp->args.return_type == RETURN_FILE)) {
-		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-
-		spin_lock(&lo->inode->i_lock);
-		if (lrp->res.lrs_present)
-			pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-		else
-			BUG_ON(!list_empty(&lo->segs));
-		spin_unlock(&lo->inode->i_lock);
-	}
-	dprintk("<-- %s\n", __func__);
-}
-
-static void nfs4_layoutreturn_release(void *calldata)
-{
-	struct nfs4_layoutreturn *lrp = calldata;
-
-	dprintk("--> %s return_type %d\n", __func__, lrp->args.return_type);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct inode *ino = lrp->args.inode;
-		struct pnfs_layout_hdr *lo = NFS_I(ino)->layout;
-
-		spin_lock(&ino->i_lock);
-		lo->plh_block_lgets--;
-		atomic_dec(&lo->plh_outstanding);
-		spin_unlock(&ino->i_lock);
-		put_layout_hdr(ino);
-	}
-	kfree(calldata);
-	dprintk("<-- %s\n", __func__);
-}
-
-static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
-	.rpc_call_prepare = nfs4_layoutreturn_prepare,
-	.rpc_call_done = nfs4_layoutreturn_done,
-	.rpc_release = nfs4_layoutreturn_release,
-};
-
-int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
-{
-	struct rpc_task *task;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTRETURN],
-		.rpc_argp = &lrp->args,
-		.rpc_resp = &lrp->res,
-	};
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = lrp->clp->cl_rpcclient,
-		.rpc_message = &msg,
-		.callback_ops = &nfs4_layoutreturn_call_ops,
-		.callback_data = lrp,
-		.flags = RPC_TASK_ASYNC,
-	};
-	int status = 0;
-
-	dprintk("--> %s\n", __func__);
-	if (lrp->args.return_type == RETURN_FILE) {
-		struct pnfs_layout_hdr *lo = NFS_I(lrp->args.inode)->layout;
-		/* FIXME we should test for BULK here */
-		spin_lock(&lo->inode->i_lock);
-		BUG_ON(lo->plh_block_lgets == 0);
-		atomic_inc(&lo->plh_outstanding);
-		spin_unlock(&lo->inode->i_lock);
-	}
-	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-	if (!issync)
-		goto out;
-	status = nfs4_wait_for_completion_rpc_task(task);
-	if (status != 0)
-		goto out;
-	status = task->tk_status;
-out:
-	dprintk("<-- %s\n", __func__);
-	rpc_put_task(task);
-	return status;
-}
-
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7f92bfa..4564021 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -329,12 +329,6 @@ static int nfs4_stat_to_errno(int);
 				op_encode_hdr_maxsz +          \
 				encode_stateid_maxsz)
 #define decode_layoutcommit_maxsz (3 + op_decode_hdr_maxsz)
-#define encode_layoutreturn_maxsz (8 + op_encode_hdr_maxsz + \
-				encode_stateid_maxsz + \
-				1 /* FIXME: opaque lrf_body always empty at
-				   *the moment */)
-#define decode_layoutreturn_maxsz (op_decode_hdr_maxsz + \
-				1 + decode_stateid_maxsz)
 #else /* CONFIG_NFS_V4_1 */
 #define encode_sequence_maxsz	0
 #define decode_sequence_maxsz	0
@@ -748,14 +742,6 @@ static int nfs4_stat_to_errno(int);
 				decode_putfh_maxsz + \
 				decode_layoutcommit_maxsz + \
 				decode_getattr_maxsz)
-#define NFS4_enc_layoutreturn_sz (compound_encode_hdr_maxsz + \
-				encode_sequence_maxsz + \
-				encode_putfh_maxsz + \
-				encode_layoutreturn_maxsz)
-#define NFS4_dec_layoutreturn_sz (compound_decode_hdr_maxsz + \
-				decode_sequence_maxsz + \
-				decode_putfh_maxsz + \
-				decode_layoutreturn_maxsz)
 #define NFS4_enc_dswrite_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz +\
 				encode_putfh_maxsz + \
@@ -1902,36 +1888,6 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	return 0;
 }
 
-static void
-encode_layoutreturn(struct xdr_stream *xdr,
-		    const struct nfs4_layoutreturn_args *args,
-		    struct compound_hdr *hdr)
-{
-	nfs4_stateid stateid;
-	__be32 *p;
-
-	p = reserve_space(xdr, 20);
-	*p++ = cpu_to_be32(OP_LAYOUTRETURN);
-	*p++ = cpu_to_be32(args->reclaim);
-	*p++ = cpu_to_be32(args->layout_type);
-	*p++ = cpu_to_be32(args->range.iomode);
-	*p = cpu_to_be32(args->return_type);
-	if (args->return_type == RETURN_FILE) {
-		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
-		p = xdr_encode_hyper(p, args->range.offset);
-		p = xdr_encode_hyper(p, args->range.length);
-		spin_lock(&args->inode->i_lock);
-		memcpy(stateid.data, NFS_I(args->inode)->layout->stateid.data,
-		       NFS4_STATEID_SIZE);
-		spin_unlock(&args->inode->i_lock);
-		p = xdr_encode_opaque_fixed(p, &stateid.data,
-					    NFS4_STATEID_SIZE);
-		p = reserve_space(xdr, 4);
-		*p = cpu_to_be32(0);
-	}
-	hdr->nops++;
-	hdr->replen += decode_layoutreturn_maxsz;
-}
 #endif /* CONFIG_NFS_V4_1 */
 
 /*
@@ -2822,26 +2778,6 @@ static int nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req, uint32_t *p,
 }
 
 /*
- * Encode LAYOUTRETURN request
- */
-static int nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req, uint32_t *p,
-				     struct nfs4_layoutreturn_args *args)
-{
-	struct xdr_stream xdr;
-	struct compound_hdr hdr = {
-		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
-	};
-
-	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, &args->seq_args, &hdr);
-	encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
-	encode_layoutreturn(&xdr, args, &hdr);
-	encode_nops(&hdr);
-	return 0;
-}
-
-/*
  * Encode a pNFS File Layout Data Server WRITE request
  */
 static int nfs4_xdr_enc_dswrite(struct rpc_rqst *req, uint32_t *p,
@@ -5283,27 +5219,6 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_layoutreturn(struct xdr_stream *xdr,
-			       struct nfs4_layoutreturn_res *res)
-{
-	__be32 *p;
-	int status;
-
-	status = decode_op_hdr(xdr, OP_LAYOUTRETURN);
-	if (status)
-		return status;
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-	res->lrs_present = be32_to_cpup(p);
-	if (res->lrs_present)
-		status = decode_stateid(xdr, &res->stateid);
-	return status;
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
-}
-
 static int decode_layoutcommit(struct xdr_stream *xdr,
 				    struct rpc_rqst *req,
 				    struct nfs4_layoutcommit_res *res)
@@ -6409,31 +6324,6 @@ out:
 }
 
 /*
- * Decode LAYOUTRETURN response
- */
-static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp, uint32_t *p,
-				     struct nfs4_layoutreturn_res *res)
-{
-	struct xdr_stream xdr;
-	struct compound_hdr hdr;
-	int status;
-
-	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
-	status = decode_compound_hdr(&xdr, &hdr);
-	if (status)
-		goto out;
-	status = decode_sequence(&xdr, &res->seq_res, rqstp);
-	if (status)
-		goto out;
-	status = decode_putfh(&xdr);
-	if (status)
-		goto out;
-	status = decode_layoutreturn(&xdr, res);
-out:
-	return status;
-}
-
-/*
  * Decode LAYOUTCOMMIT response
  */
 static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp, uint32_t *p,
@@ -6711,7 +6601,6 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
   PROC(LAYOUTGET,  enc_layoutget,     dec_layoutget),
   PROC(LAYOUTCOMMIT, enc_layoutcommit,  dec_layoutcommit),
-  PROC(LAYOUTRETURN, enc_layoutreturn,  dec_layoutreturn),
   PROC(PNFS_WRITE, enc_dswrite,  dec_dswrite),
   PROC(PNFS_COMMIT, enc_dscommit,  dec_dscommit),
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e76d4f8..c22e439 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -599,55 +599,6 @@ void nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 		}
 }
 
-/* Return true if there is layout based io in progress in the given range.
- * Assumes range has already been marked invalid, and layout marked to
- * prevent any new lseg from being inserted.
- */
-bool
-pnfs_return_layout_barrier(struct nfs_inode *nfsi,
-			   struct pnfs_layout_range *range)
-{
-	struct pnfs_layout_segment *lseg;
-	bool ret = false;
-
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
-		if (should_free_lseg(&lseg->range, range)) {
-			ret = true;
-			break;
-		}
-	spin_unlock(&nfsi->vfs_inode.i_lock);
-	dprintk("%s:Return %d\n", __func__, ret);
-	return ret;
-}
-
-static int
-return_layout(struct inode *ino, struct pnfs_layout_range *range, bool wait)
-{
-	struct nfs4_layoutreturn *lrp;
-	struct nfs_server *server = NFS_SERVER(ino);
-	int status = -ENOMEM;
-
-	dprintk("--> %s\n", __func__);
-
-	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
-	if (lrp == NULL) {
-		put_layout_hdr(ino);
-		goto out;
-	}
-	lrp->args.reclaim = 0;
-	lrp->args.layout_type = server->pnfs_curr_ld->id;
-	lrp->args.return_type = RETURN_FILE;
-	lrp->args.range = *range;
-	lrp->args.inode = ino;
-	lrp->clp = server->nfs_client;
-
-	status = nfs4_proc_layoutreturn(lrp, wait);
-out:
-	dprintk("<-- %s status: %d\n", __func__, status);
-	return status;
-}
-
 /* Initiates a LAYOUTRETURN(FILE) */
 int
 _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
@@ -673,21 +624,10 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		goto out;
 	}
 	lo->plh_block_lgets++;
-	/* Reference matched in nfs4_layoutreturn_release */
-	get_layout_hdr(lo);
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&tmp_list);
 
-	if (layoutcommit_needed(nfsi)) {
-		status = pnfs_layoutcommit_inode(ino, wait);
-		if (status) {
-			/* Return layout even if layoutcommit fails */
-			dprintk("%s: layoutcommit failed, status=%d. "
-				"Returning layout anyway\n",
-				__func__, status);
-		}
-	}
-	status = return_layout(ino, &arg, wait);
+	/* Don't need to wait since this is followed by call to end_writeback */
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d999e38..0ddab0d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -183,7 +183,6 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				   int issync);
-extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool wait);
 
 /* pnfs.c */
 void get_layout_hdr(struct pnfs_layout_hdr *lo);
@@ -193,7 +192,6 @@ bool should_free_lseg(struct pnfs_layout_range *lseg_range,
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
-bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
-- 
1.7.2.1

