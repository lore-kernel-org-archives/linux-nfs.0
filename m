Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496Ab1KVU1B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 15:27:01 -0500
Date: Tue, 22 Nov 2011 15:26:54 -0500
To: Thomas Meyer <thomas@m3y3r.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd4: Use kmemdup rather than duplicating its
 implementation
Message-ID: <20111122202654.GC21451@fieldses.org>
References: <1321569820.1624.302.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321569820.1624.302.camel@localhost.localdomain>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2011 at 11:43:40PM +0100, Thomas Meyer wrote:
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.

Thanks, applying for 3.3.--b.

> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> ---
> 
> diff -u -p a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> --- a/fs/nfsd/nfs4state.c 2011-11-07 19:38:23.353822940 +0100
> +++ b/fs/nfsd/nfs4state.c 2011-11-08 10:34:05.545953251 +0100
> @@ -985,12 +985,11 @@ static struct nfs4_client *alloc_client(
>  	clp = kzalloc(sizeof(struct nfs4_client), GFP_KERNEL);
>  	if (clp == NULL)
>  		return NULL;
> -	clp->cl_name.data = kmalloc(name.len, GFP_KERNEL);
> +	clp->cl_name.data = kmemdup(name.data, name.len, GFP_KERNEL);
>  	if (clp->cl_name.data == NULL) {
>  		kfree(clp);
>  		return NULL;
>  	}
> -	memcpy(clp->cl_name.data, name.data, name.len);
>  	clp->cl_name.len = name.len;
>  	return clp;
>  }
> diff -u -p a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> --- a/fs/nfsd/nfs4xdr.c 2011-11-07 19:38:23.357156324 +0100
> +++ b/fs/nfsd/nfs4xdr.c 2011-11-08 10:34:08.289323359 +0100
> @@ -215,10 +215,9 @@ defer_free(struct nfsd4_compoundargs *ar
>  static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  {
>  	if (p == argp->tmp) {
> -		p = kmalloc(nbytes, GFP_KERNEL);
> +		p = kmemdup(argp->tmp, nbytes, GFP_KERNEL);
>  		if (!p)
>  			return NULL;
> -		memcpy(p, argp->tmp, nbytes);
>  	} else {
>  		BUG_ON(p != argp->tmpp);
>  		argp->tmpp = NULL;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
