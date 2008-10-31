From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH]:
Date: Fri, 31 Oct 2008 16:39:03 -0400
Message-ID: <20081031203903.GD8955@fieldses.org>
References: <4902068D.2030201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52312 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbYJaUjH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2008 16:39:07 -0400
In-Reply-To: <4902068D.2030201-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2008 at 01:31:57PM -0400, Steve Dickson wrote:
> [As requested, here is the debugging portion broken out of
> the 6th patch in the "Dynamic Pseudo Root" patch series.]
> 
> Added dprintk to the top and bottom of both expkey_parse() and
> svc_export_parse(). The top dprintks shows what rpc.mountd gave
> to the routines to parse. These match up well with the current
> debugging statements in the rpc.mount routines nfsd_export()
> and nfsd_fh(). 
>
> The bottom two dprintks show when either routine error out. This
> was very useful in debugging why exports failed or hang.


Did you try experiment with strace very much before trying this?
Something like

	strace -e read,write -s 1000 -p `pidof rpc.gssd`

will show the contents of the upcalls and downcalls and any returned
error, so I'm not convinced that dprintk's of the upcall/downcall data
are necessary.

> diff -up linux/net/sunrpc/cache.c.org linux/net/sunrpc/cache.c
> --- linux/net/sunrpc/cache.c.org	2008-10-24 13:00:46.000000000 -0400
> +++ linux/net/sunrpc/cache.c	2008-10-14 07:54:01.000000000 -0400
> @@ -215,11 +215,13 @@ int cache_check(struct cache_detail *det
>  		if (rv == -EAGAIN)
>  			rv = -ENOENT;
>  	} else if (rv == -EAGAIN || age > refresh_age/2) {
> -		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
> -				refresh_age, age);
> +		dprintk("check_check: upcall: h 0x%p pending %d rv %d\n", 
> +			h, test_bit(CACHE_PENDING, &h->flags), rv);

THis is actually changing the information printed instead of adding
more.  Are you sure this is what you want?

>  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
>  			switch (cache_make_upcall(detail, h)) {
>  			case -EINVAL:
> +				dprintk("check_check: upcall(-EINVAL): h 0x%p rv %d\n",
> +					h, rv);

>From a quick check of cache_make_upcall, -EINVAL is returned either when
cache_request is NULL (looks like that would be a bug?), or in the case
where nobody's listening on the given upcall channel, in which case
there's already a printk().

--b.

>  				clear_bit(CACHE_PENDING, &h->flags);
>  				if (rv == -EAGAIN) {
>  					set_bit(CACHE_NEGATIVE, &h->flags);
> @@ -231,6 +233,8 @@ int cache_check(struct cache_detail *det
>  
>  			case -EAGAIN:
>  				clear_bit(CACHE_PENDING, &h->flags);
> +				dprintk("check_check: upcall(-EAGAIN): h 0x%p flags 0x%lx\n",
> +					h, h->flags);
>  				cache_revisit_request(h);
>  				break;
>  			}
> @@ -560,13 +564,16 @@ static int cache_defer_req(struct cache_
>  		/* too much in the cache, randomly drop this one,
>  		 * or continue and drop the oldest below
>  		 */
> -		if (net_random()&1)
> +		if (net_random()&1) {
> +			dprintk("cache_defer_req:  0x%p: dropping request\n", item);
>  			return -ETIMEDOUT;
> +		}
>  	}
>  	dreq = req->defer(req);
> -	if (dreq == NULL)
> +	if (dreq == NULL) {
> +		dprintk("cache_defer_req: 0x%p: request timedout\n", item);
>  		return -ETIMEDOUT;
> -
> +	}
>  	dreq->item = item;
>  
>  	spin_lock(&cache_defer_lock);
> @@ -596,6 +603,7 @@ static int cache_defer_req(struct cache_
>  		/* must have just been validated... */
>  		cache_revisit_request(item);
>  	}
> +	dprintk("cache_defer_req:  0x%p: request deferred\n", item);
>  	return 0;
>  }
>  
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
