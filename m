From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Wed, 11 Jun 2008 18:54:31 -0400
Message-ID: <20080611225431.GD25194@fieldses.org>
References: <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net> <20080609185355.GF28584@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75D9F@hoexmb9.conoco.net> <20080610171602.GG20184@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DA3@hoexmb9.conoco.net> <20080611184613.GM15380@fieldses.org> <20080611195222.GP15380@fieldses.org> <20080611160947.5f08fb16@tleilax.poochiereds.net> <20080611205749.GA25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325AbYFKWyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 18:54:33 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C297701002D75DAA-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 11, 2008 at 05:46:13PM -0500, Weathers, Norman R. wrote:
> I will try and get it patched and retested, but it may be a day or two
> before I can get back the information due to production jobs now
> running.  Once they finish up, I will get back with the info.

Understood.

> Thanks everyone for looking at this, by the way!

And thanks for your persistence.

--b.

> 
> > 
> > 
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 06236e4..b379e31 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -2202,7 +2202,7 @@ kmem_cache_create (const char *name, 
> > size_t size, size_t align,
> >  	 * above the next power of two: caches with object 
> > sizes just above a
> >  	 * power of two have a significant amount of internal 
> > fragmentation.
> >  	 */
> > -	if (size < 4096 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
> > +	if (size < 8192 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
> >  						2 * 
> > sizeof(unsigned long long)))
> >  		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
> >  	if (!(flags & SLAB_DESTROY_BY_RCU))
> > 
> 
> 
> Norman Weathers
