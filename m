From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [RFC 27/39] nfs41: consider minorversion in
 callback_xdr:process_op
Date: Mon, 15 Jun 2009 17:15:42 -0700
Message-ID: <1245111342.7470.3.camel@heimdal.trondhjem.org>
References: <49FA3180.5030404@panasas.com>
	 <1241133824-1185-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60173 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbZFPAPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 20:15:40 -0400
In-Reply-To: <1241133824-1185-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-01 at 02:23 +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback_xdr.c |   63 ++++++++++++++++++++++++++++++++++++++----------
>  1 files changed, 50 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index e141a7e..dd25794 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -359,31 +359,61 @@ out:
>  	return status;
>  }
>  
> -static __be32 process_op(struct svc_rqst *rqstp,
> +static __be32 process_op(uint32_t minorversion, int nop,
> +		struct svc_rqst *rqstp,
>  		struct xdr_stream *xdr_in, void *argp,
>  		struct xdr_stream *xdr_out, void *resp)
>  {
>  	struct callback_op *op = &callback_ops[0];
>  	unsigned int op_nr = OP_CB_ILLEGAL;
> -	__be32 status = 0;
> +	__be32 status;
>  	long maxlen;
>  	__be32 res;
>  
>  	dprintk("%s: start\n", __func__);
>  	status = decode_op_hdr(xdr_in, &op_nr);
> -	if (likely(status == 0)) {
> +	if (unlikely(status))
> +		goto out_illegal;
> +
> +	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
> +		__func__, minorversion, nop, op_nr);
> +#if defined(CONFIG_NFS_V4_1)
> +	if (minorversion == 1) {
>  		switch (op_nr) {
> -			case OP_CB_GETATTR:
> -			case OP_CB_RECALL:
> -				op = &callback_ops[op_nr];
> -				break;
> -			default:
> -				op_nr = OP_CB_ILLEGAL;
> -				op = &callback_ops[0];
> -				status = htonl(NFS4ERR_OP_ILLEGAL);
> +		case OP_CB_GETATTR:
> +		case OP_CB_RECALL:
> +			op = &callback_ops[op_nr];
> +			break;
> +
> +		case OP_CB_LAYOUTRECALL:
> +		case OP_CB_NOTIFY:
> +		case OP_CB_PUSH_DELEG:
> +		case OP_CB_RECALL_ANY:
> +		case OP_CB_RECALLABLE_OBJ_AVAIL:
> +		case OP_CB_RECALL_SLOT:
> +		case OP_CB_SEQUENCE:
> +		case OP_CB_WANTS_CANCELLED:
> +		case OP_CB_NOTIFY_LOCK:
> +			op = &callback_ops[0];
> +			status = htonl(NFS4ERR_NOTSUPP);
> +			break;
> +		default:
> +			goto out_illegal;
>  		}
> -	}
>  
> +		goto out;
> +	}
> +#endif /* defined(CONFIG_NFS_V4_1) */

Please move into a separate function. 

> +
> +	switch (op_nr) {
> +	case OP_CB_GETATTR:
> +	case OP_CB_RECALL:
> +		op = &callback_ops[op_nr];
> +		break;
> +	default:
> +		goto out_illegal;
> +	}

Ditto...

> +out:
>  	maxlen = xdr_out->end - xdr_out->p;
>  	if (maxlen > 0 && maxlen < PAGE_SIZE) {
>  		if (likely(status == 0 && op->decode_args != NULL))
> @@ -400,6 +430,12 @@ static __be32 process_op(struct svc_rqst *rqstp,
>  		status = op->encode_res(rqstp, xdr_out, resp);
>  	dprintk("%s: done, status = %d\n", __func__, ntohl(status));
>  	return status;
> +
> +out_illegal:
> +	op_nr = OP_CB_ILLEGAL;
> +	op = &callback_ops[0];
> +	status = htonl(NFS4ERR_OP_ILLEGAL);
> +	goto out;
>  }
>  
>  /*
> @@ -431,7 +467,8 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
>  		return rpc_system_err;
>  
>  	while (status == 0 && nops != hdr_arg.nops) {
> -		status = process_op(rqstp, &xdr_in, argp, &xdr_out, resp);
> +		status = process_op(hdr_arg.minorversion, nops,
> +				    rqstp, &xdr_in, argp, &xdr_out, resp);
>  		nops++;
>  	}
>  

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
