Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40194 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750943AbdI1TeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:34:15 -0400
Date: Thu, 28 Sep 2017 15:34:13 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 02/10] NFSD OFFLOAD_STATUS xdr
Message-ID: <20170928193413.GO10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-3-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170928172945.50780-3-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 01:29:37PM -0400, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 20 ++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c  | 30 ++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h     | 10 ++++++++++
>  3 files changed, 58 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3c69db7..8601fc4 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1142,6 +1142,13 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	fput(file);
>  	return status;
>  }
> +static __be32
> +nfsd4_offload_status(struct svc_rqst *rqstp,
> +		     struct nfsd4_compound_state *cstate,
> +		     union nfsd4_op_u *u)
> +{
> +	return nfserr_notsupp;
> +}
>  
>  static __be32
>  nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> @@ -2039,6 +2046,14 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		1 /* cr_synchronous */) * sizeof(__be32);
>  }
>  
> +static inline u32 nfsd4_offload_status_rsize(struct svc_rqst *rqstp,
> +					     struct nfsd4_op *op)
> +{
> +	return (op_encode_hdr_size +
> +		2 /* osr_count */ +
> +		1 /* osr_complete<1> optional 0 for now */) * sizeof(__be32);
> +}
> +
>  #ifdef CONFIG_NFSD_PNFS
>  static inline u32 nfsd4_getdeviceinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  {
> @@ -2452,6 +2467,11 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		.op_name = "OP_SEEK",
>  		.op_rsize_bop = nfsd4_seek_rsize,
>  	},
> +	[OP_OFFLOAD_STATUS] = {
> +		.op_func = nfsd4_offload_status,
> +		.op_name = "OP_OFFLOAD_STATUS",
> +		.op_rsize_bop = nfsd4_offload_status_rsize,
> +	},
>  };
>  
>  /**
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2c61c6b..ed8b61f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1768,6 +1768,13 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  }
>  
>  static __be32
> +nfsd4_decode_offload_status(struct nfsd4_compoundargs *argp,
> +			    struct nfsd4_offload_status *os)
> +{
> +	return nfsd4_decode_stateid(argp, &os->stateid);
> +}
> +
> +static __be32
>  nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
>  {
>  	DECODE_HEAD;
> @@ -1874,7 +1881,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
> -	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_offload_status,
>  	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
>  	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
> @@ -4216,6 +4223,25 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  }
>  
>  static __be32
> +nfsd4_encode_offload_status(struct nfsd4_compoundres *resp, __be32 nfserr,
> +			    struct nfsd4_offload_status *os)
> +{
> +	struct xdr_stream *xdr = &resp->xdr;
> +	__be32 *p;
> +
> +	if (nfserr)
> +		return nfserr;

Note you can skip this--see upstream bac966d60652 and b7571e4cd39a.

--b.

> +
> +	p = xdr_reserve_space(xdr, 8 + 4);
> +	if (!p)
> +		return nfserr_resource;
> +	p = xdr_encode_hyper(p, os->count);
> +	*p++ = cpu_to_be32(0);
> +
> +	return nfserr;
> +}
> +
> +static __be32
>  nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		  struct nfsd4_seek *seek)
>  {
> @@ -4318,7 +4344,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
> -	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_offload_status,
>  	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
>  	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 4ac2676..9b0c099 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -542,6 +542,15 @@ struct nfsd4_seek {
>  	loff_t		seek_pos;
>  };
>  
> +struct nfsd4_offload_status {
> +	/* request */
> +	stateid_t	stateid;
> +
> +	/* response */
> +	u64		count;
> +	u32		status;
> +};
> +
>  struct nfsd4_op {
>  	int					opnum;
>  	const struct nfsd4_operation *		opdesc;
> @@ -600,6 +609,7 @@ struct nfsd4_op {
>  		struct nfsd4_fallocate		deallocate;
>  		struct nfsd4_clone		clone;
>  		struct nfsd4_copy		copy;
> +		struct nfsd4_offload_status	offload_status;
>  		struct nfsd4_seek		seek;
>  	} u;
>  	struct nfs4_replay *			replay;
> -- 
> 1.8.3.1
> 
