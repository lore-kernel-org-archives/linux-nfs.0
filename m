From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 03/85] nfs: remove incorrect usage of nfs4 compound
 response hdr.status
Date: Mon, 17 Nov 2008 15:24:43 +0200
Message-ID: <4921709B.6020602@panasas.com>
References: <4918920E.3030301@panasas.com> <1226347519-6740-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:7136 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYKQNYs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:24:48 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1178437qwe.37
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 05:24:47 -0800 (PST)
In-Reply-To: <1226347519-6740-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:05 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> 3 call sites look at hdr.status before returning success.
> hdr.status must be zero in this case so there's no point in this.
> 
> Currently, hdr.status is correctly processed at decode_op_hdr time
> if the op status cannot be decoded.

review 11-14: send to Trond

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |    6 ------
>  1 files changed, 0 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index ac2386b..69b5a56 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4423,8 +4423,6 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
>  		status = decode_putfh(&xdr);
>  	if (!status)
>  		status = decode_fsinfo(&xdr, fsinfo);
> -	if (!status)
> -		status = nfs4_stat_to_errno(hdr.status);
>  	return status;
>  }
>  
> @@ -4513,8 +4511,6 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
>  	status = decode_compound_hdr(&xdr, &hdr);
>  	if (!status)
>  		status = decode_setclientid(&xdr, clp);
> -	if (!status)
> -		status = nfs4_stat_to_errno(hdr.status);
>  	return status;
>  }
>  
> @@ -4535,8 +4531,6 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
>  		status = decode_putrootfh(&xdr);
>  	if (!status)
>  		status = decode_fsinfo(&xdr, fsinfo);
> -	if (!status)
> -		status = nfs4_stat_to_errno(hdr.status);
>  	return status;
>  }
>  

