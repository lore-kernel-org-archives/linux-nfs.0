Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45679 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754429Ab0HRV05 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 17:26:57 -0400
Subject: Re: [PATCH 1/4] sunrpc: don't shorten buflen twice in
 xdr_shrink_pagelen
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1282164159-20283-1-git-send-email-bhalevy@panasas.com>
References: <4C6C4565.1070603@panasas.com>
	 <1282164159-20283-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 17:26:54 -0400
Message-ID: <1282166814.8540.119.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 23:42 +0300, Benny Halevy wrote:
> On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> >
> > The buflen is reset for all cases at the end of xdr_shrink_pagelen.
> > The data left in the tail after xdr_read_pages is not processed when the
> > buflen is incorrectly set.
> 
> Note that in this case we also lose (len - tail->iov_len)
> bytes from the buffered data in pages.

We don't really need to do that. The amount of free space in the tail
(as opposed to space occupied by data) can be calculated as:

buf->buflen - buf->head->iov_len - buf->page_len - buf->tail->iov_len;


> Reported-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/xdr.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index a1f82a8..91f0de9 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -407,8 +407,7 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
>  		if (tail->iov_len > len) {
>  			copy = tail->iov_len - len;
>  			memmove(p, tail->iov_base, copy);
> -		} else
> -			buf->buflen -= len;
> +		}
>  		/* Copy from the inlined pages into the tail */
>  		copy = len;
>  		if (copy > tail->iov_len)


