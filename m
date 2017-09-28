Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750977AbdI1Tez (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 15:34:55 -0400
Date: Thu, 28 Sep 2017 15:34:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 03/10] NFSD OFFLOAD_CANCEL xdr
Message-ID: <20170928193452.GP10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-4-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170928172945.50780-4-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 01:29:38PM -0400, Olga Kornievskaia wrote:
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 13 +++++++++++++
>  fs/nfsd/nfs4xdr.c  |  2 +-
>  2 files changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 8601fc4..11ade90 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1121,6 +1121,14 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  }
>  
>  static __be32
> +nfsd4_offload_cancel(struct svc_rqst *rqstp,
> +		     struct nfsd4_compound_state *cstate,
> +		     union nfsd4_op_u *u)
> +{
> +	return 0;
> +}
> +
> +static __be32
>  nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		struct nfsd4_fallocate *fallocate, int flags)
>  {
> @@ -2472,6 +2480,11 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
>  		.op_name = "OP_OFFLOAD_STATUS",
>  		.op_rsize_bop = nfsd4_offload_status_rsize,
>  	},
> +	[OP_OFFLOAD_CANCEL] = {

I think you want .op_flags = OP_MODIFIES_SOMETHING as well.

> +		.op_func = nfsd4_offload_cancel,
> +		.op_name = "OP_OFFLOAD_CANCEL",
> +		.op_rsize_bop = nfsd4_only_status_rsize,
> +	},
>  };
>  
>  /**
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index ed8b61f..31ee5e1 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1880,7 +1880,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
> -	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_offload_status,
>  	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_offload_status,
>  	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
>  	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
> -- 
> 1.8.3.1
> 
