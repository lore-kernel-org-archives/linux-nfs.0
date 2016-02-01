Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660AbcBASiH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 13:38:07 -0500
Date: Mon, 1 Feb 2016 13:38:05 -0500
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: nfsd: supports read buffer from multiples pages
Message-ID: <20160201183805.GB5499@fieldses.org>
References: <56AE0302.6050101@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56AE0302.6050101@gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 31, 2016 at 08:50:10PM +0800, Kinglong Mee wrote:
> ltp fsync02 will cause nfs sending LAYOUTCOMMIT with length
> larger than two pages. nfsd returns NFSERR_BAD_XDR right now.

This is with the xfs block layout?

Christoph, do we know anything about average or worst-case sizes for
that layout update field?

> This patch lets nfsd supports read buffer from multiples pages.

Hm.  We'll end up kmalloc()ing the passed-in field length:

		p = argp->tmpp = kmalloc(nbytes, GFP_KERNEL);

We still do still have that (avail + argp->pagelen) limit, so we're not
going to pass arbitrarily large nbytes straight from the network to
kmalloc.  But we do try to avoid depending on higher-order allocations.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 18 ++++++++++++++----
>  1 file changed, 14 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d6ef095..fcf399f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -143,11 +143,11 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  	 * Maybe we need a new page, maybe we have just run out
>  	 */
>  	unsigned int avail = (char *)argp->end - (char *)argp->p;
> +	unsigned int copied = 0;
>  	__be32 *p;
> +
>  	if (avail + argp->pagelen < nbytes)
>  		return NULL;
> -	if (avail + PAGE_SIZE < nbytes) /* need more than a page !! */
> -		return NULL;
>  	/* ok, we can do it with the current plus the next page */
>  	if (nbytes <= sizeof(argp->tmp))
>  		p = argp->tmp;
> @@ -164,9 +164,19 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
>  	 * guarantee p points to at least nbytes bytes.
>  	 */
>  	memcpy(p, argp->p, avail);
> +	copied += avail;
> +	nbytes -= avail;
> +
> +	while (nbytes > PAGE_SIZE) {
> +		next_decode_page(argp);
> +		memcpy(((char*)p) + copied, argp->p, PAGE_SIZE);
> +		copied += PAGE_SIZE;
> +		nbytes -= PAGE_SIZE;
> +	}
> +
>  	next_decode_page(argp);
> -	memcpy(((char*)p)+avail, argp->p, (nbytes - avail));
> -	argp->p += XDR_QUADLEN(nbytes - avail);
> +	memcpy(((char*)p) + copied, argp->p, nbytes);
> +	argp->p += XDR_QUADLEN(nbytes);
>  	return p;
>  }
>  
> -- 
> 2.5.0
