Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46247 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaCWGnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 02:43:37 -0400
Date: Sat, 22 Mar 2014 23:43:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 18/50] nfsd4: use xdr_stream throughout compound encoding
Message-ID: <20140323064336.GA24465@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-19-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1395537141-10389-19-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  #define RESERVE_SPACE(nbytes)	do {				\
> -	p = resp->xdr.p;						\
> -	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->xdr.end);		\
> +	p = xdr_reserve_space(&resp->xdr, nbytes);		\
> +	BUG_ON(!p);						\
>  } while (0)
> -#define ADJUST_ARGS()		resp->xdr.p = p
> +#define ADJUST_ARGS()		WARN_ON_ONCE(p != resp->xdr.p)	\

I think the code would become more clear if you'd start expanding these
macros.  IF the RESERVE_SPACE BUG_ON is important enough it should move
into xdr_reserve_space or a variant thereof, or otherweise just removed.

> +	if (nfserr) {
> +		xdr->p -= 2;
> +		xdr->iov->iov_len -= 8;


> +	if (nfserr) {
> +		xdr->p--;
> +		xdr->iov->iov_len -= 4;
>  		return nfserr;
> +	}


> +	xdr->p = savep;
> +	xdr->iov->iov_len = ((char *)resp->xdr.p)
> +				- (char *)resp->xdr.buf->head[0].iov_base;

Where is this coming from?  Looks like deep magic to be and would
benefit from comments, symbolic names and/or a helper.
