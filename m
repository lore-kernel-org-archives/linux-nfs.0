Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41815 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbcEPUzZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2016 16:55:25 -0400
Subject: Re: [PATCH 2/4] NFSv4: Label stateids with the type
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <1463424447-57302-1-git-send-email-trond.myklebust@primarydata.com>
 <1463424447-57302-2-git-send-email-trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <07c85b1d-fa94-90aa-b44e-ca465562bf4e@Netapp.com>
Date: Mon, 16 May 2016 16:55:03 -0400
MIME-Version: 1.0
In-Reply-To: <1463424447-57302-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 05/16/2016 02:47 PM, Trond Myklebust wrote:
> In order to more easily distinguish what kind of stateid we are dealing
> with, introduce a type that can be used to label the stateid structure.
> 
> The label will be useful both for debugging, but also when dealing with
> operations like SETATTR, READ and WRITE that can take several different
> types of stateid as arguments.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/callback_xdr.c                     | 18 ++++++++++---
>  fs/nfs/flexfilelayout/flexfilelayout.c    |  7 +++---
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
>  fs/nfs/nfs4_fs.h                          |  7 ++++--
>  fs/nfs/nfs4proc.c                         |  3 +++
>  fs/nfs/nfs4state.c                        |  5 +++-
>  fs/nfs/nfs4xdr.c                          | 42 ++++++++++++++++++++++++-------
>  include/linux/nfs4.h                      | 25 ++++++++++++++----
>  8 files changed, 86 insertions(+), 24 deletions(-)
> 
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 976c90608e56..3a1dcee29861 100644

<snip>


> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 88474a4fc669..7a24c92d1672 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4270,6 +4270,30 @@ static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
>  	return decode_opaque_fixed(xdr, stateid, NFS4_STATEID_SIZE);
>  }
>  
> +static int decode_open_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
> +{
> +	stateid->type = NFS4_OPEN_STATEID_TYPE;
> +	return decode_stateid(xdr, stateid);
> +}
> +
> +static int decode_lock_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
> +{
> +	stateid->type = NFS4_LOCK_STATEID_TYPE;
> +	return decode_stateid(xdr, stateid);
> +}
> +
> +static int decode_delegation_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
> +{
> +	stateid->type = NFS4_DELEGATION_STATEID_TYPE;
> +	return decode_stateid(xdr, stateid);
> +}
> +
> +static int decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
> +{
> +	stateid->type = NFS4_LAYOUT_STATEID_TYPE;
> +	return decode_stateid(xdr, stateid);
> +}

Can you wrap decode_layout_stateid() in an #ifdef CONFIG_NFS_V4_1 check?  Otherwise I get warnings when I compile without v4.1 enabled:


  CC [M]  fs/nfs/nfs3acl.o
  LD [M]  fs/nfs/nfsv3.o
  CC [M]  fs/nfs/nfs4proc.o
  CC [M]  fs/nfs/nfs4xdr.o
fs/nfs/nfs4xdr.c:4291:12: warning: 'decode_layout_stateid' defined but not used [-Wunused-function]
 static int decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
            ^~~~~~~~~~~~~~~~~~~~~
  CC [M]  fs/nfs/nfs4state.o
  CC [M]  fs/nfs/nfs4renewd.o
  CC [M]  fs/nfs/nfs4super.o
  CC [M]  fs/nfs/nfs4file.o
  CC [M]  fs/nfs/delegation.o
  CC [M]  fs/nfs/nfs4idmap.o
  CC [M]  fs/nfs/callback.o
  CC [M]  fs/nfs/callback_xdr.o
fs/nfs/callback_xdr.c:159:15: warning: 'decode_layout_stateid' defined but not used [-Wunused-function]
 static __be32 decode_layout_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
               ^~~~~~~~~~~~~~~~~~~~~
  CC [M]  fs/nfs/callback_proc.o
  CC [M]  fs/nfs/nfs4namespace.o

Thanks,
Anna

> +
>  static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
>  {
>  	int status;
> @@ -4278,7 +4302,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
>  	if (status != -EIO)
>  		nfs_increment_open_seqid(status, res->seqid);
>  	if (!status)
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_open_stateid(xdr, &res->stateid);
>  	return status;
>  }
>  
> @@ -4937,7 +4961,7 @@ static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
>  	if (status == -EIO)
>  		goto out;
>  	if (status == 0) {
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_lock_stateid(xdr, &res->stateid);
>  		if (unlikely(status))
>  			goto out;
>  	} else if (status == -NFS4ERR_DENIED)
> @@ -4966,7 +4990,7 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
>  	if (status != -EIO)
>  		nfs_increment_lock_seqid(status, res->seqid);
>  	if (status == 0)
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_lock_stateid(xdr, &res->stateid);
>  	return status;
>  }
>  
> @@ -5016,7 +5040,7 @@ static int decode_rw_delegation(struct xdr_stream *xdr,
>  	__be32 *p;
>  	int status;
>  
> -	status = decode_stateid(xdr, &res->delegation);
> +	status = decode_delegation_stateid(xdr, &res->delegation);
>  	if (unlikely(status))
>  		return status;
>  	p = xdr_inline_decode(xdr, 4);
> @@ -5096,7 +5120,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
>  	nfs_increment_open_seqid(status, res->seqid);
>  	if (status)
>  		return status;
> -	status = decode_stateid(xdr, &res->stateid);
> +	status = decode_open_stateid(xdr, &res->stateid);
>  	if (unlikely(status))
>  		return status;
>  
> @@ -5136,7 +5160,7 @@ static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmre
>  	if (status != -EIO)
>  		nfs_increment_open_seqid(status, res->seqid);
>  	if (!status)
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_open_stateid(xdr, &res->stateid);
>  	return status;
>  }
>  
> @@ -5148,7 +5172,7 @@ static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *re
>  	if (status != -EIO)
>  		nfs_increment_open_seqid(status, res->seqid);
>  	if (!status)
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_open_stateid(xdr, &res->stateid);
>  	return status;
>  }
>  
> @@ -5919,7 +5943,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
>  	if (unlikely(!p))
>  		goto out_overflow;
>  	res->return_on_close = be32_to_cpup(p);
> -	decode_stateid(xdr, &res->stateid);
> +	decode_layout_stateid(xdr, &res->stateid);
>  	p = xdr_inline_decode(xdr, 4);
>  	if (unlikely(!p))
>  		goto out_overflow;
> @@ -5985,7 +6009,7 @@ static int decode_layoutreturn(struct xdr_stream *xdr,
>  		goto out_overflow;
>  	res->lrs_present = be32_to_cpup(p);
>  	if (res->lrs_present)
> -		status = decode_stateid(xdr, &res->stateid);
> +		status = decode_layout_stateid(xdr, &res->stateid);
>  	return status;
>  out_overflow:
>  	print_overflow_msg(__func__, xdr);
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 011433478a14..f561e2029862 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -50,12 +50,27 @@ struct nfs4_label {
>  
>  typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
>  
> -struct nfs_stateid4 {
> -	__be32 seqid;
> -	char other[NFS4_STATEID_OTHER_SIZE];
> -} __attribute__ ((packed));
> +struct nfs4_stateid_struct {
> +	union {
> +		char data[NFS4_STATEID_SIZE];
> +		struct {
> +			__be32 seqid;
> +			char other[NFS4_STATEID_OTHER_SIZE];
> +		} __attribute__ ((packed));
> +	};
> +
> +	enum {
> +		NFS4_INVALID_STATEID_TYPE = 0,
> +		NFS4_SPECIAL_STATEID_TYPE,
> +		NFS4_OPEN_STATEID_TYPE,
> +		NFS4_LOCK_STATEID_TYPE,
> +		NFS4_DELEGATION_STATEID_TYPE,
> +		NFS4_LAYOUT_STATEID_TYPE,
> +		NFS4_PNFS_DS_STATEID_TYPE,
> +	} type;
> +};
>  
> -typedef struct nfs_stateid4 nfs4_stateid;
> +typedef struct nfs4_stateid_struct nfs4_stateid;
>  
>  enum nfs_opnum4 {
>  	OP_ACCESS = 3,
> 

