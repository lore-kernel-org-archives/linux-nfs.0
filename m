Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbaLHWix (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 17:38:53 -0500
Date: Mon, 8 Dec 2014 17:38:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH v1] sunrpc/cache: convert to use string_escape_str()
Message-ID: <20141208223852.GA20526@fieldses.org>
References: <1417189828-25688-1-git-send-email-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1417189828-25688-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 28, 2014 at 05:50:28PM +0200, Andy Shevchenko wrote:
> There is nice kernel helper to escape a given strings by provided rules. Let's
> use it instead of custom approach.

Looks good, but it broke nfsd.

After staring at the patch for a while:

> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  net/sunrpc/cache.c | 27 ++++++---------------------
>  1 file changed, 6 insertions(+), 21 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 0663621..5cf60a4 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -20,6 +20,7 @@
>  #include <linux/list.h>
>  #include <linux/module.h>
>  #include <linux/ctype.h>
> +#include <linux/string_helpers.h>
>  #include <asm/uaccess.h>
>  #include <linux/poll.h>
>  #include <linux/seq_file.h>
> @@ -1067,32 +1068,16 @@ void qword_add(char **bpp, int *lp, char *str)
>  {
>  	char *bp = *bpp;
>  	int len = *lp;
> -	char c;
> +	int ret;
>  
>  	if (len < 0) return;
>  
> -	while ((c=*str++) && len)
> -		switch(c) {
> -		case ' ':
> -		case '\t':
> -		case '\n':
> -		case '\\':
> -			if (len >= 4) {
> -				*bp++ = '\\';
> -				*bp++ = '0' + ((c & 0300)>>6);
> -				*bp++ = '0' + ((c & 0070)>>3);
> -				*bp++ = '0' + ((c & 0007)>>0);
> -			}
> -			len -= 4;
> -			break;
> -		default:
> -			*bp++ = c;
> -			len--;
> -		}
> -	if (c || len <1) len = -1;
> +	ret = string_escape_str(str, &bp, len, ESCAPE_OCTAL, "\\ \n\t");
> +	if (ret < 0 || ret == len)
> +		len = -1;
>  	else {
>  		*bp++ = ' ';
> -		len--;
> +		len -= ret - 1;

Looks like that should be ret + 1, not ret - 1.  With that change,
things work.

Inclined to actually commit that as:

	len -= ret;
	*bp++ = ' ';
	len--;

just to make the arithmetic really obvious.

--b.

>  	}
>  	*bpp = bp;
>  	*lp = len;
> -- 
> 2.1.3
> 
