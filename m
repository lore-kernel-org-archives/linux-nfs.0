Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45067 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752562Ab0DTQvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 12:51:53 -0400
Date: Tue, 20 Apr 2010 12:51:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] bug in read_buf
Message-ID: <20100420165152.GD28826@fieldses.org>
References: <19405.3732.562014.510508@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19405.3732.562014.510508@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 20, 2010 at 12:16:52PM +1000, Neil Brown wrote:
> 
> Surely this can never have worked... which implies that the code has
> never been used?
> 
> When read_buf is called to move over to the next page in the pagelist
> of an NFSv4 request, it sets argp->end to essentially a random
> number, certainly not an address within the page which argp->p now
> points to.  So subsequent calls to READ_BUF will think there is much
> more than a page of spare space (the cast to u32 ensures an unsigned
> comparison) so we can expect to fall off the end of the second
> page.

Yipes, thanks.

> I guess we never ever receive requests with any operation starting
> beyond the first page!

putfh-write-getattr, for example, is common enough.  The write decoding
should leave arg->end set correctly.  But there are two read_buf()'s in
decode_getattr(), and I can't see why we don't hit this bug on a write
that leaves that final getattr exactly straddling a page boundary.

--b.

> [[
> I found this while looking at why fsstress over NFS over RDMA caused
> a bad memory dereference in READ32, suggesting that 'p' had a bad
> value.  However it was ffff8801299188f0, which is not an "I've fallen
> off the end of the page" sort of value.  So I think it must be a
> different bug :-(  It is as if the page is being unmapped underneath
> us...
> ]]
> NeilBrown
> 
> 
> 
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e170317..34ccf81 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -161,10 +161,10 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  	argp->p = page_address(argp->pagelist[0]);
>  	argp->pagelist++;
>  	if (argp->pagelen < PAGE_SIZE) {
> -		argp->end = p + (argp->pagelen>>2);
> +		argp->end = argp->p + (argp->pagelen>>2);
>  		argp->pagelen = 0;
>  	} else {
> -		argp->end = p + (PAGE_SIZE>>2);
> +		argp->end = argp->p + (PAGE_SIZE>>2);
>  		argp->pagelen -= PAGE_SIZE;
>  	}
>  	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
> @@ -1426,10 +1426,10 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  			argp->p = page_address(argp->pagelist[0]);
>  			argp->pagelist++;
>  			if (argp->pagelen < PAGE_SIZE) {
> -				argp->end = p + (argp->pagelen>>2);
> +				argp->end = argp->p + (argp->pagelen>>2);
>  				argp->pagelen = 0;
>  			} else {
> -				argp->end = p + (PAGE_SIZE>>2);
> +				argp->end = argp->p + (PAGE_SIZE>>2);
>  				argp->pagelen -= PAGE_SIZE;
>  			}
>  		}
> 
> 
