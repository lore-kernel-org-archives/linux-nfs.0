From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] nfsd: make nfs4xdr WRITEMEM safe against zero count
Date: Mon, 2 Jun 2008 12:36:04 -0400
Message-ID: <20080602163604.GD18887@fieldses.org>
References: <483E7DB8.1050705@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752586AbYFBQgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 12:36:05 -0400
In-Reply-To: <483E7DB8.1050705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2008 at 12:56:08PM +0300, Benny Halevy wrote:
> WRITEMEM zeroes the last word in the destination buffer
> for padding purposes, but this must not be done if
> no bytes are to be copied, as it would result
> in zeroing of the word right before the array.

Thanks, applied.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> 
> --
> The current implementation works since it's always called
> with non zero nbytes or it follows an encoding of the
> string (or opaque) length which, if equal to zero, 
> can be overwritten with zero.

I also added the above paragraph to the changelog.

> 
> Another way of implementing that is the way it's done in
> fs/nfsd/nfs4callback.c:
> 
> static inline __be32 *
> xdr_writemem(__be32 *p, const void *ptr, int nbytes)
> {
> 	int tmp = XDR_QUADLEN(nbytes);
> 	if (!tmp)
> 		return p;
> 	p[tmp-1] = 0;
> 	memcpy(p, ptr, nbytes);
> 	return p + tmp;
> }
> 
> #define WRITEMEM(ptr,nbytes)     do {                           \
> 	p = xdr_writemem(p, ptr, nbytes);                       \
> } while (0)
> 
> Also, is there any plan to clean up the xdr encoding definition
> any time and define a cleaner static inline API?

Not currently.

> I'd be happy to take a stab at it and come up with a
> written and tested proposal.

That could be helpful, thanks.

--b.

> 
> Benny
> 
> git diff --stat -p
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e8e27fb..588c9f6 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1712,7 +1712,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  	*p++ = htonl((u32)((n) >> 32));				\
>  	*p++ = htonl((u32)(n));					\
>  } while (0)
> -#define WRITEMEM(ptr,nbytes)     do {				\
> +#define WRITEMEM(ptr,nbytes)     do if (nbytes > 0) {		\
>  	*(p + XDR_QUADLEN(nbytes) -1) = 0;                      \
>  	memcpy(p, ptr, nbytes);					\
>  	p += XDR_QUADLEN(nbytes);				\
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
