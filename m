Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59270 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751575AbdHUVOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 21 Aug 2017 17:14:00 -0400
Date: Mon, 21 Aug 2017 17:13:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/3] nfsd: Limit end of page list when decoding NFSv4
 WRITE
Message-ID: <20170821211359.GA14949@fieldses.org>
References: <20170818150957.26571.12169.stgit@klimt.1015granger.net>
 <20170818151219.26571.31977.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170818151219.26571.31977.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 18, 2017 at 11:12:19AM -0400, Chuck Lever wrote:
> When processing an NFSv4 WRITE operation, argp->end should never
> point past the end of the data in the final page of the page list.
> Otherwise, nfsd4_decode_compound can walk into uninitialized memory.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4xdr.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 51e729a..7c48d68 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -144,7 +144,7 @@ static void next_decode_page(struct nfsd4_compoundargs *argp)
>  	argp->p = page_address(argp->pagelist[0]);
>  	argp->pagelist++;
>  	if (argp->pagelen < PAGE_SIZE) {
> -		argp->end = argp->p + (argp->pagelen>>2);
> +		argp->end = argp->p + XDR_QUADLEN(argp->pagelen);
>  		argp->pagelen = 0;
>  	} else {
>  		argp->end = argp->p + (PAGE_SIZE>>2);
> @@ -1279,9 +1279,7 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compoundargs *argp, struct xdr_ne
>  		argp->pagelen -= pages * PAGE_SIZE;
>  		len -= pages * PAGE_SIZE;
>  
> -		argp->p = (__be32 *)page_address(argp->pagelist[0]);
> -		argp->pagelist++;
> -		argp->end = argp->p + XDR_QUADLEN(PAGE_SIZE);
> +		next_decode_page(argp);

I think there's no change in behavior here *except* for adding a new
argp->pagelen=0 (or argp->pagelen -= PAGE_SIZE).

--b.

>  	}
>  	argp->p += XDR_QUADLEN(len);
>  
