Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33556 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934090AbdBQUl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 15:41:27 -0500
Date: Fri, 17 Feb 2017 15:41:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: Get response size before operation for all RPCs
Message-ID: <20170217204126.GL10894@fieldses.org>
References: <dee5cc7c-2bdb-e0d8-92bc-bfb9ab9dc28e@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <dee5cc7c-2bdb-e0d8-92bc-bfb9ab9dc28e@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK.  I think overestimates for these operations are generally safe, but
it's probably better to have closer estimates.  Applying this and the
following.

--b.

On Fri, Feb 03, 2017 at 10:36:00PM +0800, Kinglong Mee wrote:
> NFSD adds PAGE_SIZE for those RPCs which not support op_rsize_bop(),
> A PAGE_SIZE (4096) is larger than many real response size, eg, 
> access (op_encode_hdr_size + 2), seek (op_encode_hdr_size + 3).
> 
> This patch just adds op_rsize_bop() for all RPCs getting response size.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 63 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 74a6e57..aed3dba 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1838,6 +1838,12 @@ static inline u32 nfsd4_status_stateid_rsize(struct svc_rqst *rqstp, struct nfsd
>  	return (op_encode_hdr_size + op_encode_stateid_maxsz)* sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_access_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	/* ac_supported, ac_resp_access */
> +	return (op_encode_hdr_size + 2)* sizeof(__be32);
> +}
> +
>  static inline u32 nfsd4_commit_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + op_encode_verifier_maxsz) * sizeof(__be32);
> @@ -1892,6 +1898,11 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
>  	return ret;
>  }
>  
> +static inline u32 nfsd4_getfh_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size + 1) * sizeof(__be32) + NFS4_FHSIZE;
> +}
> +
>  static inline u32 nfsd4_link_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + op_encode_change_info_maxsz)
> @@ -1933,6 +1944,11 @@ static inline u32 nfsd4_readdir_rsize(struct svc_rqst *rqstp, struct nfsd4_op *o
>  		XDR_QUADLEN(rlen)) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_readlink_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size + 1) * sizeof(__be32) + PAGE_SIZE;
> +}
> +
>  static inline u32 nfsd4_remove_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + op_encode_change_info_maxsz)
> @@ -1952,11 +1968,23 @@ static inline u32 nfsd4_sequence_rsize(struct svc_rqst *rqstp,
>  		+ XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_test_stateid_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size + 1 + op->u.test_stateid.ts_num_ids)
> +		* sizeof(__be32);
> +}
> +
>  static inline u32 nfsd4_setattr_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + nfs4_fattr_bitmap_maxsz) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_secinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size + RPC_AUTH_MAXFLAVOR *
> +		(4 + XDR_QUADLEN(GSS_OID_MAX_LEN))) * sizeof(__be32);
> +}
> +
>  static inline u32 nfsd4_setclientid_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
>  	return (op_encode_hdr_size + 2 + XDR_QUADLEN(NFS4_VERIFIER_SIZE)) *
> @@ -2011,6 +2039,19 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  }
>  
>  #ifdef CONFIG_NFSD_PNFS
> +static inline u32 nfsd4_getdeviceinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	u32 maxcount = 0, rlen = 0;
> +
> +	maxcount = svc_max_payload(rqstp);
> +	rlen = min(op->u.getdeviceinfo.gd_maxcount, maxcount);
> +
> +	return (op_encode_hdr_size +
> +		1 /* gd_layout_type*/ +
> +		XDR_QUADLEN(rlen) +
> +		2 /* gd_notify_types */) * sizeof(__be32);
> +}
> +
>  /*
>   * At this stage we don't really know what layout driver will handle the request,
>   * so we need to define an arbitrary upper bound here.
> @@ -2040,10 +2081,17 @@ static inline u32 nfsd4_layoutreturn_rsize(struct svc_rqst *rqstp, struct nfsd4_
>  }
>  #endif /* CONFIG_NFSD_PNFS */
>  
> +
> +static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size + 3) * sizeof(__be32);
> +}
> +
>  static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_ACCESS] = {
>  		.op_func = (nfsd4op_func)nfsd4_access,
>  		.op_name = "OP_ACCESS",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_access_rsize,
>  	},
>  	[OP_CLOSE] = {
>  		.op_func = (nfsd4op_func)nfsd4_close,
> @@ -2081,6 +2129,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_GETFH] = {
>  		.op_func = (nfsd4op_func)nfsd4_getfh,
>  		.op_name = "OP_GETFH",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_getfh_rsize,
>  	},
>  	[OP_LINK] = {
>  		.op_func = (nfsd4op_func)nfsd4_link,
> @@ -2099,6 +2148,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_LOCKT] = {
>  		.op_func = (nfsd4op_func)nfsd4_lockt,
>  		.op_name = "OP_LOCKT",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_lock_rsize,
>  	},
>  	[OP_LOCKU] = {
>  		.op_func = (nfsd4op_func)nfsd4_locku,
> @@ -2111,15 +2161,18 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_lookup,
>  		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
>  		.op_name = "OP_LOOKUP",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_LOOKUPP] = {
>  		.op_func = (nfsd4op_func)nfsd4_lookupp,
>  		.op_flags = OP_HANDLES_WRONGSEC | OP_CLEAR_STATEID,
>  		.op_name = "OP_LOOKUPP",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_NVERIFY] = {
>  		.op_func = (nfsd4op_func)nfsd4_nverify,
>  		.op_name = "OP_NVERIFY",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_OPEN] = {
>  		.op_func = (nfsd4op_func)nfsd4_open,
> @@ -2177,6 +2230,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_READLINK] = {
>  		.op_func = (nfsd4op_func)nfsd4_readlink,
>  		.op_name = "OP_READLINK",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_readlink_rsize,
>  	},
>  	[OP_REMOVE] = {
>  		.op_func = (nfsd4op_func)nfsd4_remove,
> @@ -2215,6 +2269,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_secinfo,
>  		.op_flags = OP_HANDLES_WRONGSEC,
>  		.op_name = "OP_SECINFO",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_secinfo_rsize,
>  	},
>  	[OP_SETATTR] = {
>  		.op_func = (nfsd4op_func)nfsd4_setattr,
> @@ -2240,6 +2295,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_VERIFY] = {
>  		.op_func = (nfsd4op_func)nfsd4_verify,
>  		.op_name = "OP_VERIFY",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
>  	},
>  	[OP_WRITE] = {
>  		.op_func = (nfsd4op_func)nfsd4_write,
> @@ -2314,11 +2370,13 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_secinfo_no_name,
>  		.op_flags = OP_HANDLES_WRONGSEC,
>  		.op_name = "OP_SECINFO_NO_NAME",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_secinfo_rsize,
>  	},
>  	[OP_TEST_STATEID] = {
>  		.op_func = (nfsd4op_func)nfsd4_test_stateid,
>  		.op_flags = ALLOWED_WITHOUT_FH,
>  		.op_name = "OP_TEST_STATEID",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_test_stateid_rsize,
>  	},
>  	[OP_FREE_STATEID] = {
>  		.op_func = (nfsd4op_func)nfsd4_free_stateid,
> @@ -2332,6 +2390,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  		.op_func = (nfsd4op_func)nfsd4_getdeviceinfo,
>  		.op_flags = ALLOWED_WITHOUT_FH,
>  		.op_name = "OP_GETDEVICEINFO",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_getdeviceinfo_rsize,
>  	},
>  	[OP_LAYOUTGET] = {
>  		.op_func = (nfsd4op_func)nfsd4_layoutget,
> @@ -2381,6 +2440,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>  	[OP_SEEK] = {
>  		.op_func = (nfsd4op_func)nfsd4_seek,
>  		.op_name = "OP_SEEK",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_seek_rsize,
>  	},
>  };
>  
> @@ -2425,14 +2485,11 @@ bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
>  
>  int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
> -	struct nfsd4_operation *opdesc;
> -	nfsd4op_rsize estimator;
> -
>  	if (op->opnum == OP_ILLEGAL)
>  		return op_encode_hdr_size * sizeof(__be32);
> -	opdesc = OPDESC(op);
> -	estimator = opdesc->op_rsize_bop;
> -	return estimator ? estimator(rqstp, op) : PAGE_SIZE;
> +
> +	BUG_ON(OPDESC(op)->op_rsize_bop == NULL);
> +	return OPDESC(op)->op_rsize_bop(rqstp, op);
>  }
>  
>  void warn_on_nonidempotent_op(struct nfsd4_op *op)
> -- 
> 2.9.3
