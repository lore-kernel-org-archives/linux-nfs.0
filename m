Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46262 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaCWGri (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 02:47:38 -0400
Date: Sat, 22 Mar 2014 23:47:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 20/50] nfsd4: keep xdr buf length updated
Message-ID: <20140323064738.GB24465@infradead.org>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
 <1395537141-10389-21-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1395537141-10389-21-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fae7d02..a3dce3c 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -3051,9 +3051,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
>  	WRITE32(eof);
>  	WRITE32(maxcount);
>  	ADJUST_ARGS();
> -	resp->xdr.buf->head[0].iov_len = (char*)p
> -				- (char*)resp->xdr.buf->head[0].iov_base;
> +	WARN_ON_ONCE(resp->xdr.buf->head[0].iov_len != (char*)p
> +				- (char*)resp->xdr.buf->head[0].iov_base);

There should be spaces between the typename and the *.

>  	resp->xdr.buf->page_len = maxcount;
> +	xdr->buf->len += maxcount;
>  	xdr->iov = xdr->buf->tail;
>  
>  	/* Use rest of head for padding and remaining ops: */
> @@ -3064,6 +3065,7 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		WRITE32(0);
>  		resp->xdr.buf->tail[0].iov_base += maxcount&3;
>  		resp->xdr.buf->tail[0].iov_len = 4 - (maxcount&3);
> +		xdr->buf->len -= (maxcount&3);
>  		ADJUST_ARGS();
>  	}
>  	return 0;
> @@ -3109,6 +3111,7 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
>  	resp->xdr.buf->head[0].iov_len = (char*)p
>  				- (char*)resp->xdr.buf->head[0].iov_base;
>  	resp->xdr.buf->page_len = maxcount;
> +	xdr->buf->len += maxcount;
>  	xdr->iov = xdr->buf->tail;

To me it seems all these manpiluations sream for being split into
well-documented little helpers.

