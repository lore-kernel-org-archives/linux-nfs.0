From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Wed, 11 Jun 2008 17:46:13 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net>
References: <1212519001.24900.14.camel@hololw58> <20080606160922.GG30863@fieldses.org> <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net> <20080609185355.GF28584@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75D9F@hoexmb9.conoco.net> <20080610171602.GG20184@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DA3@hoexmb9.conoco.net> <20080611184613.GM15380@fieldses.org> <20080611195222.GP15380@fieldses.org> <20080611160947.5f08fb16@tleilax.poochiereds.net> <20080611205749.GA25194@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Jeff Layton" <jlayton@poochiereds.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman1.ppco.com ([138.32.41.4]:44728 "EHLO mailman1.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbYFKWqU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 18:46:20 -0400
In-Reply-To: <20080611205749.GA25194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Wednesday, June 11, 2008 3:58 PM
> To: Jeff Layton
> Cc: linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org; 
> Weathers, Norman R.
> Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
> 
> On Wed, Jun 11, 2008 at 04:09:47PM -0400, Jeff Layton wrote:
> > On Wed, 11 Jun 2008 15:52:22 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > I'm probably missing something fundamental--why doesn't
> > > /proc/slab_allocators show any results for size-x where x >= 4096?
> > > 
> > > Someone's seeing a performance problem with the linux nfs 
> server.  One
> > > of the symptoms is the "size-4096" slab cache seems to be out of
> > > control.  I assumed that meant that memory allocated by 
> kmalloc() might
> > > be leaking, so figured it might be interesting to turn on
> > > CONFIG_DEBUG_SLAB_LEAK.  As far as I can tell what that 
> does is list
> > > kmalloc() callers in /proc/slab_allocators.  But that 
> doesn't seem to be
> > > showing any results for size-4096.  Can anyone provide a clue?
> > > Thanks!
> > > 
> > > --b.
> > > 
> > 
> > 
> > Hmm...I've never used this, but in kmem_cache_alloc():
> > 
> >         /*
> >          * Enable redzoning and last user accounting, 
> except for caches with
> >          * large objects, if the increased size would 
> increase the object size
> >          * above the next power of two: caches with object 
> sizes just above a
> >          * power of two have a significant amount of 
> internal fragmentation.
> >          */
> >         if (size < 4096 || fls(size - 1) == fls(size-1 + 
> REDZONE_ALIGN +
> >                                                 2 * 
> sizeof(unsigned long long)))
> >                 flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
> > 
> > 
> > ...looks like it specifically excludes some caches.
> 
> Ah, I missed that!  I'm a little confused as to how those 
> flags behavior
> affect the collection of the leak debugging data, but I can 
> verify that
> the below does result in size-4096 showing up in 
> /proc/slab_allocators;
> hopefully there's no more negative result than the 
> performance penalty.
> 
> Norman, do you think you could try applying this and then 
> trying again?
> 
> --b.


I will try and get it patched and retested, but it may be a day or two
before I can get back the information due to production jobs now
running.  Once they finish up, I will get back with the info.

Thanks everyone for looking at this, by the way!

> 
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 06236e4..b379e31 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2202,7 +2202,7 @@ kmem_cache_create (const char *name, 
> size_t size, size_t align,
>  	 * above the next power of two: caches with object 
> sizes just above a
>  	 * power of two have a significant amount of internal 
> fragmentation.
>  	 */
> -	if (size < 4096 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
> +	if (size < 8192 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
>  						2 * 
> sizeof(unsigned long long)))
>  		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
>  	if (!(flags & SLAB_DESTROY_BY_RCU))
> 


Norman Weathers
