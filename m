From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/4] sunrpc: simplify xdr_shrijk_pagelen use of "copy"
Date: Wed, 18 Aug 2010 17:19:47 -0400
Message-ID: <1282166387.8540.112.camel@heimdal.trondhjem.org>
References: <4C6C4565.1070603@panasas.com>
	 <1282164183-20389-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63893 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab0HRVUG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 17:20:06 -0400
In-Reply-To: <1282164183-20389-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-08-18 at 23:43 +0300, Benny Halevy wrote:
> The "copy" variable value can be computed using the existing
> logic rather than repeating it.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/xdr.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 42a7ebf..2ab59c3 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -402,14 +402,14 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
>  
>  	/* Shift the tail first */
>  	if (tail->iov_len != 0) {
> +		copy = len;
>  		if (tail->iov_len > len) {
>  			char *p = (char *)tail->iov_base + len;
>  			memmove(p, tail->iov_base, tail->iov_len - len);
> +		} else {
> +			copy = tail->iov_len;
>  		}
                 ^^^ We don't need a C block for the 'else' case.

>  		/* Copy from the inlined pages into the tail */
> -		copy = len;
> -		if (copy > tail->iov_len)
> -			copy = tail->iov_len;
>  		_copy_from_pages((char *)tail->iov_base,
>  				buf->pages, buf->page_base + pglen - len,
>  				copy);


