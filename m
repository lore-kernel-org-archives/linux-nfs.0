Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52064 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965676AbeBMVDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 16:03:14 -0500
Date: Tue, 13 Feb 2018 16:03:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: "Wang, Alan 1. (NSB - CN/Hangzhou)" <alan.1.wang@nokia-sbell.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: A special case in write_flush which cause the umount busy
Message-ID: <20180213210314.GA12201@fieldses.org>
References: <VI1PR07MB342127E2A55088F691693A3BA2F00@VI1PR07MB3421.eurprd07.prod.outlook.com>
 <87inb0r7cd.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87inb0r7cd.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 14, 2018 at 06:57:06AM +1100, NeilBrown wrote:
> I think this change is safe.  It is a bit of a hack, but the "flush"
> interface was actually very poorly designed and I don't think it *can*
> be implemented cleanly.
> Maybe we should just ignore the number written in and *always* flush
> the cache completely.  That is was it always wanted.
> 
> See below.
> 
> Bruce: do you have any thoughts on this?

I'm fine with ignoring the number--I agree that the chance anyone is
doing anything fancier is vanishingly small.

--b.

> 
> Thanks,
> NeilBrown
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index aa36dad32db1..43f117d1547e 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -1450,7 +1450,7 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
>  			   struct cache_detail *cd)
>  {
>  	char tbuf[20];
> -	char *bp, *ep;
> +	char *ep;
>  	time_t then, now;
>  
>  	if (*ppos || count > sizeof(tbuf)-1)
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
> +	/* Always flush everything, so behave like cache_purge()
> +	 * Can only set flush_time to 1 second beyond "now", or
>  	 * possibly 1 second beyond flushtime.  This is because
>  	 * flush_time never goes backwards so it mustn't get too far
>  	 * ahead of time.
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
> 
> 
> >
> > --------------------------------------------------------------------------
> >        then = get_expiry(&bp);
> >        now = seconds_since_boot();
> >        cd->nextcheck = now;
> >        /* Can only set flush_time to 1 second beyond "now", or
> >        * possibly 1 second beyond flushtime.  This is because
> >        * flush_time never goes backwards so it mustn't get too far
> >        * ahead of time.
> >        */
> >        if (then != now)
> >               printk("%s %d then = %d, now = %d\n", __func__, __LINE__, then, now);
> > -      if (then >= now) {
> > +     if (then >= now - 1) {
> >               /* Want to flush eve


