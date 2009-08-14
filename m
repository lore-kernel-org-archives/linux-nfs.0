From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC v2 16/21] nfs: nfs4xdr: introduce decode_verifier
 helper
Date: Fri, 14 Aug 2009 13:54:41 -0400
Message-ID: <1250272482.5476.14.camel@heimdal.trondhjem.org>
References: <4A8571E2.8020800@panasas.com>
	 <1250259596-13993-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42681 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932241AbZHNRyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2009 13:54:54 -0400
In-Reply-To: <1250259596-13993-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-14 at 17:19 +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |   20 +++++++++++---------
>  1 files changed, 11 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 86e6983..b835dcc 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3320,17 +3320,19 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
>  	return status;
>  }
>  
> +static int decode_verifier(struct xdr_stream *xdr, void *verifier)
> +{
> +	return decode_opaque_fixed(xdr, verifier, 8);
> +}
> +
>  static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
>  {
> -	__be32 *p;
>  	int status;
>  
>  	status = decode_op_hdr(xdr, OP_COMMIT);
> -	if (status)
> -		return status;
> -	READ_BUF(8);
> -	COPYMEM(res->verf->verifier, 8);
> -	return 0;
> +	if (!status)
> +		status = decode_verifier(xdr, res->verf->verifier);
> +	return status;
>  }
>  
>  static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
> @@ -3852,10 +3854,10 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
>  	int		status;
>  
>  	status = decode_op_hdr(xdr, OP_READDIR);
> -	if (status)
> +	if (!status)
> +		status = decode_verifier(xdr, readdir->verifier.data);
> +	if (unlikely(status))
>  		return status;
> -	READ_BUF(8);
> -	COPYMEM(readdir->verifier.data, 8);
>  	dprintk("%s: verifier = %08x:%08x\n",
>  			__func__,
>  			((u32 *)readdir->verifier.data)[0],

This introduces an uninitialised variable warning into decode_readdir.
The fix would be to use xdr->p in the calculation of hdrlen.

I'll add that, no need to resend.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
