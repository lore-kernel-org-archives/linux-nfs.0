Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52398 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751923AbeEGQze (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 May 2018 12:55:34 -0400
Date: Mon, 7 May 2018 12:55:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: restrict rd_maxcount to svc_max_payload in
 nfsd_encode_readdir
Message-ID: <20180507165534.GE4749@fieldses.org>
References: <20180507130108.7136-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180507130108.7136-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.17 and stable.--b.

On Mon, May 07, 2018 at 09:01:08AM -0400, Scott Mayhew wrote:
> nfsd4_readdir_rsize restricts rd_maxcount to svc_max_payload when
> estimating the size of the readdir reply, but nfsd_encode_readdir
> restricts it to INT_MAX when encoding the reply.  This can result in log
> messages like "kernel: RPC request reserved 32896 but used 1049444".
> 
> Restrict rd_dircount similarly (no reason it should be larger than
> svc_max_payload).
> 
> Signen-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 1d048dd..cfe535c 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3651,7 +3651,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  		nfserr = nfserr_resource;
>  		goto err_no_verf;
>  	}
> -	maxcount = min_t(u32, readdir->rd_maxcount, INT_MAX);
> +	maxcount = svc_max_payload(resp->rqstp);
> +	maxcount = min_t(u32, readdir->rd_maxcount, maxcount);
>  	/*
>  	 * Note the rfc defines rd_maxcount as the size of the
>  	 * READDIR4resok structure, which includes the verifier above
> @@ -3665,7 +3666,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
>  
>  	/* RFC 3530 14.2.24 allows us to ignore dircount when it's 0: */
>  	if (!readdir->rd_dircount)
> -		readdir->rd_dircount = INT_MAX;
> +		readdir->rd_dircount = svc_max_payload(resp->rqstp);
>  
>  	readdir->xdr = xdr;
>  	readdir->rd_maxcount = maxcount;
> -- 
> 2.9.5
