Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41840 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751540AbeBVAqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 19:46:53 -0500
Date: Wed, 21 Feb 2018 19:46:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: "Wang, Alan 1. (NSB - CN/Hangzhou)" <alan.1.wang@nokia-sbell.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: cache: ignore timestamp written to 'flush' file.
Message-ID: <20180222004652.GE6535@fieldses.org>
References: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com>
 <87inb0r7cd.fsf@notabene.neil.brown.name>
 <20180213210314.GA12201@fieldses.org>
 <877ergqsmd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877ergqsmd.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 14, 2018 at 12:15:06PM +1100, NeilBrown wrote:
> 
> The interface for flushing the sunrpc auth cache was poorly
> designed and has caused problems a number of times.
> 
> The design is that you write a timestamp, and all entries
> created before that time are discarded.
> The most obvious problem is that this is not what people
> actually want.  They want to just flush the whole cache.
> The 1-second granularity can be a problem, as can the use
> of wall-clock time.
> 
> A current problem is that code will write the current time to
> this file - expecting it to clear everything - and if the
> seconds number ticks over before this timestamp is checked,
> the test "then >= now" fails, and a full flush isn't forced.
> 
> So lets just drop the subtleties and always flush the whole
> cache.  The worst this could do is impose an extra cost
> refilling it, but that would require someone to be using
> non-standard tools.
> 
> We still report an error if the string written is not a number,
> but we cause any valid number to flush the whole cache.

Thanks, applying for 4.17 (unless someone thinks it's more urgent).

--b.

> 
> Reported-by: "Wang, Alan 1. (NSB - CN/Hangzhou)" <alan.1.wang@nokia-sbell.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  net/sunrpc/cache.c | 32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 8a7e1c774f9c..26582e27be6a 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1450,8 +1450,8 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
>  			   struct cache_detail *cd)
>  {
>  	char tbuf[20];
> -	char *bp, *ep;
> -	time_t then, now;
> +	char *ep;
> +	time_t now;
>  
>  	if (*ppos || count > sizeof(tbuf)-1)
>  		return -EINVAL;
> @@ -1461,24 +1461,24 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
>  	simple_strtoul(tbuf, &ep, 0);
>  	if (*ep && *ep != '\n')
>  		return -EINVAL;
> +	/* Note that while we check that 'buf' holds a valid number,
> +	 * we always ignore the value and just flush everything.
> +	 * Making use of the number leads to races.
> +	 */
>  
> -	bp = tbuf;
> -	then = get_expiry(&bp);
>  	now = seconds_since_boot();
> -	cd->nextcheck = now;
> -	/* Can only set flush_time to 1 second beyond "now", or
> -	 * possibly 1 second beyond flushtime.  This is because
> -	 * flush_time never goes backwards so it mustn't get too far
> -	 * ahead of time.
> +	/* Always flush everything, so behave like cache_purge()
> +	 * Do this by advancing flush_time to the current time,
> +	 * or by one second if it has already reached the current time.
> +	 * Newly added cache entries will always have ->last_refresh greater
> +	 * that ->flush_time, so they don't get flushed prematurely.
>  	 */
> -	if (then >= now) {
> -		/* Want to flush everything, so behave like cache_purge() */
> -		if (cd->flush_time >= now)
> -			now = cd->flush_time + 1;
> -		then = now;
> -	}
>  
> -	cd->flush_time = then;
> +	if (cd->flush_time >= now)
> +		now = cd->flush_time + 1;
> +
> +	cd->flush_time = now;
> +	cd->nextcheck = now;
>  	cache_flush();
>  
>  	*ppos += count;
> -- 
> 2.14.0.rc0.dirty
> 


