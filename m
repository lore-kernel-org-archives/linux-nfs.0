Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab3LLQAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 11:00:12 -0500
Date: Thu, 12 Dec 2013 11:00:10 -0500
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v1] net/sunrpc/cache: simplify code by using
 hex_pack_byte()
Message-ID: <20131212160010.GB11521@fieldses.org>
References: <1386856161-29889-1-git-send-email-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386856161-29889-1-git-send-email-andriy.shevchenko@linux.intel.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 03:49:21PM +0200, Andy Shevchenko wrote:
> hex_pack_byte() is a fast way to convert a byte in its ASCII representation. We
> may use it instead of custom approach.

Thanks, I'll take that through the nfsd tree for 3.14.

--b.

> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  net/sunrpc/cache.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index a72de07..0877db0 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1111,9 +1111,7 @@ void qword_addhex(char **bpp, int *lp, char *buf, int blen)
>  		*bp++ = 'x';
>  		len -= 2;
>  		while (blen && len >= 2) {
> -			unsigned char c = *buf++;
> -			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
> -			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
> +			bp = hex_byte_pack(bp, *buf++);
>  			len -= 2;
>  			blen--;
>  		}
> -- 
> 1.8.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
