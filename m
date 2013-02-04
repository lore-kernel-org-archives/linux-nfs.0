Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51255 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753467Ab3BDSSy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 13:18:54 -0500
Date: Mon, 4 Feb 2013 13:18:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 9/8] nfsd: handle arbitrary page array layouts in
 nfsd_cache_crc
Message-ID: <20130204181853.GM815@fieldses.org>
References: <1359983887-28535-1-git-send-email-jlayton@redhat.com>
 <1360001258-13320-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360001258-13320-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 01:07:38PM -0500, Jeff Layton wrote:
> The original code didn't handle the case where the page_base was close
> to the end of the page. In practice, page_base is always 0 on receive,
> so it's not a problem today, but let's future-proof this in the event
> that it ever is.

OK--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfscache.c | 21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index cb655f3..e705fea 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -248,6 +248,8 @@ nfsd_reply_cache_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  static u32
>  nfsd_cache_crc(struct xdr_buf *buf)
>  {
> +	int idx;
> +	unsigned int base;
>  	u32 crc;
>  	const unsigned char *p = buf->head[0].iov_base;
>  	size_t csum_len = min_t(size_t, buf->head[0].iov_len + buf->page_len,
> @@ -258,13 +260,18 @@ nfsd_cache_crc(struct xdr_buf *buf)
>  	crc = crc32(crc_seed, p, len);
>  	csum_len -= len;
>  
> -	/* Nothing left */
> -	if (!csum_len)
> -		return crc;
> -
> -	/* checksum the rest from the page_array */
> -	p = page_address(buf->pages[0]) + buf->page_base;
> -	return crc32(crc, p, csum_len);
> +	/* Continue into page array */
> +	idx = buf->page_base / PAGE_SIZE;
> +	base = buf->page_base & ~PAGE_MASK;
> +	while (csum_len) {
> +		p = page_address(buf->pages[idx]) + base;
> +		len = min(PAGE_SIZE - base, csum_len);
> +		crc = crc32(crc, p, len);
> +		csum_len -= len;
> +		base = 0;
> +		++idx;
> +	}
> +	return crc;
>  }
>  
>  /*
> -- 
> 1.7.11.7
> 
