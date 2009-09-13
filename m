From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 10/12] nfsd41: Backchannel: Implement cb_recall over
	NFSv4.1
Date: Sun, 13 Sep 2009 16:39:49 -0400
Message-ID: <20090913203949.GE13109@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574824-30348-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39473 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754393AbZIMUjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Sep 2009 16:39:46 -0400
In-Reply-To: <1252574824-30348-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 12:27:04PM +0300, Benny Halevy wrote:
> @@ -668,16 +701,19 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
>  		break;
>  	default:
>  		/* success, or error we can't handle */
> -		return;
> +		goto done;
>  	}
>  	if (dp->dl_retries--) {
>  		rpc_delay(task, 2*HZ);
>  		task->tk_status = 0;
>  		rpc_restart_call(task);
> +		return;
>  	} else {
>  		atomic_set(&clp->cl_cb_conn.cb_set, 0);
>  		warn_no_callback_path(clp, task->tk_status);
>  	}
> +done:
> +	kfree(task->tk_msg.rpc_argp);
>  }
>  
>  static void nfsd4_cb_recall_release(void *calldata)
> @@ -703,16 +739,24 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
>  {
>  	struct nfs4_client *clp = dp->dl_client;
>  	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
> +	struct nfs4_rpc_args *args;
>  	struct rpc_message msg = {
>  		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
> -		.rpc_argp = dp,
>  		.rpc_cred = clp->cl_cb_conn.cb_cred
>  	};
>  	int status;
>  
> +	args = kzalloc(sizeof(*args), GFP_KERNEL);
> +	if (!args) {
> +		status = -ENOMEM;
> +		goto out;
> +	}
> +	args->args_op = dp;
> +	msg.rpc_argp = args;
>  	dp->dl_retries = 1;
>  	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
>  				&nfsd4_cb_recall_ops, dp);
> +out:
>  	if (status) {
>  		put_nfs4_client(clp);
>  		nfs4_put_delegation(dp);
> -- 
> 1.6.4
> 

Tracing down through rpc_call_async.... It doesn't look to me like it
will call rpc_call_done on returning an error, so you're leaking args in
that case.  Probably just need a kfree(args); applying as below.

--b.

commit 18d8774a149c28b8c9ac66592873e78bbc66330a
Author: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Date:   Thu Sep 10 12:27:04 2009 +0300

    nfsd41: Backchannel: Implement cb_recall over NFSv4.1
    
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    [nfsd41: cb_recall callback]
    [Share v4.0 and v4.1 back channel xdr]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [Share v4.0 and v4.1 back channel xdr]
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfsd41: use nfsd4_cb_sequence for callback minorversion]
    [nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfsd41: Backchannel: Add sequence arguments to callback RPC arguments]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    [pulled-in definition of nfsd4_cb_done]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 74c8b33..fabfe12 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -267,15 +267,19 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *args)
+nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
+		struct nfs4_rpc_args *rpc_args)
 {
 	struct xdr_stream xdr;
+	struct nfs4_delegation *args = rpc_args->args_op;
 	struct nfs4_cb_compound_hdr hdr = {
 		.ident = args->dl_ident,
+		.minorversion = rpc_args->args_seq.cbs_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_cb_compound_hdr(&xdr, &hdr);
+	encode_cb_sequence(&xdr, &rpc_args->args_seq, &hdr);
 	encode_cb_recall(&xdr, args, &hdr);
 	encode_cb_nops(&hdr);
 	return 0;
@@ -324,7 +328,8 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
 }
 
 static int
-nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
+nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
+		struct nfsd4_cb_sequence *seq)
 {
 	struct xdr_stream xdr;
 	struct nfs4_cb_compound_hdr hdr;
@@ -334,6 +339,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
 	status = decode_cb_compound_hdr(&xdr, &hdr);
 	if (status)
 		goto out;
+	if (seq) {
+		status = decode_cb_sequence(&xdr, seq, rqstp);
+		if (status)
+			goto out;
+	}
 	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
 out:
 	return status;
@@ -575,11 +585,34 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	rpc_call_start(task);
 }
 
+static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_delegation *dp = calldata;
+	struct nfs4_client *clp = dp->dl_client;
+
+	dprintk("%s: minorversion=%d\n", __func__,
+		clp->cl_cb_conn.cb_minorversion);
+
+	if (clp->cl_cb_conn.cb_minorversion) {
+		/* No need for lock, access serialized in nfsd4_cb_prepare */
+		++clp->cl_cb_seq_nr;
+		clear_bit(0, &clp->cl_cb_slot_busy);
+		rpc_wake_up_next(&clp->cl_cb_waitq);
+		dprintk("%s: freed slot, new seqid=%d\n", __func__,
+			clp->cl_cb_seq_nr);
+
+		/* We're done looking into the sequence information */
+		task->tk_msg.rpc_resp = NULL;
+	}
+}
+
 static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegation *dp = calldata;
 	struct nfs4_client *clp = dp->dl_client;
 
+	nfsd4_cb_done(task, calldata);
+
 	switch (task->tk_status) {
 	case -EIO:
 		/* Network partition? */
@@ -592,16 +625,19 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		break;
 	default:
 		/* success, or error we can't handle */
-		return;
+		goto done;
 	}
 	if (dp->dl_retries--) {
 		rpc_delay(task, 2*HZ);
 		task->tk_status = 0;
 		rpc_restart_call(task);
+		return;
 	} else {
 		atomic_set(&clp->cl_cb_conn.cb_set, 0);
 		warn_no_callback_path(clp, task->tk_status);
 	}
+done:
+	kfree(task->tk_msg.rpc_argp);
 }
 
 static void nfsd4_cb_recall_release(void *calldata)
@@ -627,17 +663,24 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_client;
 	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
+	struct nfs4_rpc_args *args;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
-		.rpc_argp = dp,
 		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
-	int status;
+	int status = -ENOMEM;
 
+	args = kzalloc(sizeof(*args), GFP_KERNEL);
+	if (!args)
+		goto out;
+	args->args_op = dp;
+	msg.rpc_argp = args;
 	dp->dl_retries = 1;
 	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
 				&nfsd4_cb_recall_ops, dp);
+out:
 	if (status) {
+		kfree(args);
 		put_nfs4_client(clp);
 		nfs4_put_delegation(dp);
 	}
