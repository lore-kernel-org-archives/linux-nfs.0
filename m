Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:46295 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085Ab1J0KvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 06:51:24 -0400
Message-ID: <4EA9379A.10605@netapp.com>
Date: Thu, 27 Oct 2011 06:51:06 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] NFS: Clean up nfs4_xdr_dec_secinfo()
References: <20111025161631.5996.30680.stgit@seurat.1015granger.net> <20111025161753.5996.83383.stgit@seurat.1015granger.net>
In-Reply-To: <20111025161753.5996.83383.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/25/2011 12:17 PM, Chuck Lever wrote:
> Clean up: Remove superfluous logic at the tail of
> nfs4_xdr_dec_secinfo() .

Oops.  Good catch!

- Bryan
> 
> Introduced by commit 5a5ea0d4 "NFS: Add secinfo procedure" (March 24,
> 2011).
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/nfs4xdr.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 1dce12f..e6161b2 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -6602,8 +6602,6 @@ static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
>  	if (status)
>  		goto out;
>  	status = decode_secinfo(xdr, res);
> -	if (status)
> -		goto out;
>  out:
>  	return status;
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

