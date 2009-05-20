From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
Date: Wed, 20 May 2009 10:46:34 +0300
Message-ID: <4A13B55A.3030405@panasas.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com> <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-5-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-7-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-8-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-9-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-10-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23629 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753971AbZETHrh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 03:47:37 -0400
In-Reply-To: <1242788428-18723-10-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 20, 2009, 6:00 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> [nfsd41: cb_recall callback]
> [Share v4.0 and v4.1 back channel xdr]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [Share v4.0 and v4.1 back channel xdr]
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: use nfsd4_cb_sequence for callback minorversion]
> [nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [nfsd41: Backchannel: Add sequence arguments to callback RPC arguments]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |   40 ++++++++++++++++++++++++++++++++++++----
>  1 files changed, 36 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 521d5f5..b25dcc2 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -292,15 +292,19 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
>  }
>  
>  static int
> -nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct nfs4_delegation *args)
> +nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
> +		struct nfs4_rpc_args *rpc_args)
>  {
>  	struct xdr_stream xdr;
> +	struct nfs4_delegation *args = rpc_args->args_op;
>  	struct nfs4_cb_compound_hdr hdr = {
>  		.ident = args->dl_ident,
> +		.minorversion = rpc_args->args_seq.cbs_minorversion,
>  	};
>  
>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>  	encode_cb_compound_hdr(&xdr, &hdr);
> +	encode_cb_sequence(&xdr, &rpc_args->args_seq, &hdr);
>  	encode_cb_recall(&xdr, args, &hdr);
>  	encode_cb_nops(&hdr);
>  	return 0;
> @@ -400,7 +404,8 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
>  }
>  
>  static int
> -nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
> +nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
> +		struct nfs4_rpc_res *rpc_res)
>  {
>  	struct xdr_stream xdr;
>  	struct nfs4_cb_compound_hdr hdr;
> @@ -410,6 +415,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
>  	status = decode_cb_compound_hdr(&xdr, &hdr);
>  	if (status)
>  		goto out;
> +	if (rpc_res && rpc_res->res_seq) {

With this version rpc_res != NULL is guaranteed, isn't it?
Also, embedding res_seq in nfs4_rpc_res will obviate this condition further.

> +		status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
> +		if (status)
> +			goto out;
> +	}
>  	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
>  out:
>  	return status;
> @@ -687,6 +697,8 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
>  	struct nfs4_delegation *dp = calldata;
>  	struct nfs4_client *clp = dp->dl_client;
>  
> +	nfsd4_cb_done(task, calldata);
> +
>  	switch (task->tk_status) {
>  	case -EIO:
>  		/* Network partition? */
> @@ -699,16 +711,20 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
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
> +	kfree(task->tk_msg.rpc_resp);
>  }
>  
>  static void nfsd4_cb_recall_release(void *calldata)
> @@ -734,16 +750,32 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
>  {
>  	struct nfs4_client *clp = dp->dl_client;
>  	struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
> +	struct nfs4_rpc_args *args;
> +	struct nfs4_rpc_res *res;
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
> +	res = kzalloc(sizeof(*res), GFP_KERNEL);
> +	if (!res) {
> +		kfree(args);
> +		status = -ENOMEM;
> +		goto out;
> +	}

Hmm, why not allocate the two in one piece and possibly having a kmem_cache
for them?

Benny

> +	args->args_op = dp;
> +	msg.rpc_argp = args;
> +	msg.rpc_resp = res;
>  	dp->dl_retries = 1;
>  	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
>  				&nfsd4_cb_recall_ops, dp);
> +out:
>  	if (status) {
>  		put_nfs4_client(clp);
>  		nfs4_put_delegation(dp);
