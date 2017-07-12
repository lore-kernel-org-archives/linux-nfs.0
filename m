Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36098 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751842AbdGLTjl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jul 2017 15:39:41 -0400
Received: by mail-it0-f65.google.com with SMTP id k3so3539820ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 12 Jul 2017 12:39:41 -0700 (PDT)
Subject: Re: [RFC v3 32/42] NFSD OFFLOAD_STATUS xdr
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-33-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <7836b917-9867-8a38-b273-bf88be8f432e@gmail.com>
Date: Wed, 12 Jul 2017 15:39:38 -0400
MIME-Version: 1.0
In-Reply-To: <20170711164416.1982-33-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 07/11/2017 12:44 PM, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 20 ++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c  | 30 ++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h     | 10 ++++++++++
>  3 files changed, 58 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 3d8ed3f..6d20ee1 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1468,6 +1468,13 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
>  	fput(file);
>  	return status;
>  }
> +static __be32
> +nfsd4_offload_status(struct svc_rqst *rqstp,
> +		     struct nfsd4_compound_state *cstate,
> +		     struct nfsd4_offload_status *os)
> +{
> +	return nfserr_notsupp;
> +}

One small comment on the placement of this function: I think it should go above nfsd4_fallocate() to keep fallocate / allocate / deallocate together.

Thanks!
Anna

>  
>  static __be32
>  nfsd4_allocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> @@ -2436,6 +2443,14 @@ static inline u32 nfsd4_copy_notify_rsize(struct svc_rqst *rqstp,
>  		* sizeof(__be32);
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
> @@ -2846,6 +2861,11 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		.op_name = "OP_COPY_NOTIFY",
>  		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_notify_rsize,
>  	},
> +	[OP_OFFLOAD_STATUS] = {
> +		.op_func = (nfsd4op_func)nfsd4_offload_status,
> +		.op_name = "OP_OFFLOAD_STATUS",
> +		.op_rsize_bop = (nfsd4op_rsize)nfsd4_offload_status_rsize,
> +	},
>  };
>  
>  /**
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c4438ac..f032178 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1836,6 +1836,13 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
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
> @@ -1942,7 +1949,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
>  	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
> -	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_offload_status,
>  	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
>  	[OP_WRITE_SAME]		= (nfsd4_dec)nfsd4_decode_notsupp,
> @@ -4483,6 +4490,25 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
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
> @@ -4588,7 +4614,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_LAYOUTSTATS]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_OFFLOAD_CANCEL]	= (nfsd4_enc)nfsd4_encode_noop,
> -	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_offload_status,
>  	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_seek,
>  	[OP_WRITE_SAME]		= (nfsd4_enc)nfsd4_encode_noop,
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index e6fa914..c3e6907 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -561,6 +561,15 @@ struct nfsd4_copy_notify {
>  	struct nl4_servers	cpn_src;
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
>  	__be32					status;
> @@ -617,6 +626,7 @@ struct nfsd4_op {
>  		struct nfsd4_clone		clone;
>  		struct nfsd4_copy		copy;
>  		struct nfsd4_copy_notify	copy_notify;
> +		struct nfsd4_offload_status	offload_status;
>  		struct nfsd4_seek		seek;
>  	} u;
>  	struct nfs4_replay *			replay;
> 
