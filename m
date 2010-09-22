From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCHv1.5 2/3] sunrpc/cache: don't use custom hex_to_bin()
 converter
Date: Wed, 22 Sep 2010 15:03:40 -0400
Message-ID: <20100922190340.GF26903@fieldses.org>
References: <2d00b66224535ae82be1a1e638b86b81fb890f58.1285051188.git.andy.shevchenko@gmail.com>
 <9ff9c1f334999e0128fe6426aaad4e9d465f310f.1285051188.git.andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754834Ab0IVTFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 15:05:11 -0400
In-Reply-To: <9ff9c1f334999e0128fe6426aaad4e9d465f310f.1285051188.git.andy.shevchenko@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 21, 2010 at 09:40:25AM +0300, Andy Shevchenko wrote:
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: linux-nfs@vger.kernel.org

Thanks, applied for 2.6.37.

--b.

> ---
>  net/sunrpc/cache.c |   20 +++++++++++++-------
>  1 files changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 5b7b56f..c944a24 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1171,13 +1171,19 @@ int qword_get(char **bpp, char *dest, int bufsize)
>  	if (bp[0] == '\\' && bp[1] == 'x') {
>  		/* HEX STRING */
>  		bp += 2;
> -		while (isxdigit(bp[0]) && isxdigit(bp[1]) && len < bufsize) {
> -			int byte = isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
> -			bp++;
> -			byte <<= 4;
> -			byte |= isdigit(*bp) ? *bp-'0' : toupper(*bp)-'A'+10;
> -			*dest++ = byte;
> -			bp++;
> +		while (len < bufsize) {
> +			int h, l;
> +
> +			h = hex_to_bin(bp[0]);
> +			if (h < 0)
> +				break;
> +
> +			l = hex_to_bin(bp[1]);
> +			if (l < 0)
> +				break;
> +
> +			*dest++ = (h << 4) | l;
> +			bp += 2;
>  			len++;
>  		}
>  	} else {
> -- 
> 1.7.2.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
