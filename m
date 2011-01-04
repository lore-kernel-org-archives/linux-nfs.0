Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35315 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab1ADVPq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:15:46 -0500
Date: Wed, 5 Jan 2011 08:15:38 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110105081538.0779659d@notabene.brown>
In-Reply-To: <20110104184314.GD2308@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
	<20110103222605.GA24811@fieldses.org>
	<20110104030805.GA3194@fieldses.org>
	<20110104155107.0ff2c199@notabene.brown>
	<20110104184314.GD2308@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 4 Jan 2011 13:43:14 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Tue, Jan 04, 2011 at 03:51:07PM +1100, NeilBrown wrote:
> > On Mon, 3 Jan 2011 22:08:05 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> > wrote:
> > 
> > > On Mon, Jan 03, 2011 at 05:26:05PM -0500, J. Bruce Fields wrote:
> > > > On Wed, Dec 29, 2010 at 03:47:52PM -0500, bfields wrote:
> > > > > From: J. Bruce Fields <bfields@redhat.com>
> > > > > 
> > > > > Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
> > > > > (and allowing any concurrent users to destroy it on last put) instead of
> > > > > trying to update it in place.
> > > > 
> > > > Or the following seems simpler.
> > > > 
> > > > (And I was thinking it was necessary to ensure that the right thing
> > > > happened to the cached xprt->xpt_auth_cache entry--though on a second
> > > > look I see that sunrpc_cache_update also expires the replaced entry
> > > > immediately.  Still, this seems simpler if it also works.)
> > > 
> > > Eh, on third thoughts: we probably do want a real negative entry created
> > > in the cache, so I think the original patch was correct!
> > 
> > I like your second thought better than your third.
> > I don't see any reason to push this item out of the cache extra quickly.
> > In fact I think it would still be correct to just remove those two lines and
> > not set expiry_time to 0.  auth_unix_lookup will never find that IP address,
> > and so it doesn't matter if it remains in the cache or not.
> > I guess there could result in the cache appearing to contain different data
> > depending on whether you look at it the 'old' way or the 'new' way, but I
> > don't that is a real problem, and setting expiry_time to 0 overcomes that.
> > 
> > What was the substance of your third thought?
> 
> I had some idea that we could end up with a cache entry stuck in the
> cache forever.
> 
> OK, actually I think late last night I reverted into some sort of "maybe
> if I type the first thing that comes to my mind, somebody else will
> think this through for me" state.  Apologies.  Um, did I win?

This would be the Andrew Morton method of community involvement:  say
something obviously wrong as it produces more responses than saying something
right - and some of them might be useful.... I fall for it all the time!


> 
> > BTW, you could use sunrpc_invalidate rather than just setting expiry_time to
> > zero, which would hurry it out of the cache a bit faster.
> 
> Yep, I like that, and I'd forgotten about sunrpc_invalidate, thanks!
> Done....  (As below).
> 
> > And this all made me realise that there is more code that can be placed under
> > CONFIG_NFSD_DEPRECTATED.
> 
> Yep, applied.
> 
> (When do we get to remove all this?  Taking a stab at the 2.6.40 merge
> window....

That is what is says in feature-removal-schedule.txt (which no-one reads).


>             OK, party at my place in May!)

Will there still be snow?  I'm not coming if there is no snow!

(patch looks good)

NeilBrown



> 
> --b.
> 
> commit ab5c05c579b0b37b9bf2c79c9c8f0ef6045ee41d
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Dec 24 14:03:38 2010 -0500
> 
>     svcrpc: modifying valid sunrpc cache entries is racy
>     
>     Once a sunrpc cache entry is VALID, we should be replacing it (and
>     allowing any concurrent users to destroy it on last put) instead of
>     trying to update it in place.
>     
>     Otherwise someone referencing the ip_map we're modifying here could try
>     to use the m_client just as we're putting the last reference.
>     
>     The bug should only be seen by users of the legacy nfsd interfaces.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index a04ac91..59a7c52 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -401,8 +401,7 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
>  		return NULL;
>  
>  	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
> -		if (test_and_set_bit(CACHE_NEGATIVE, &ipm->h.flags) == 0)
> -			auth_domain_put(&ipm->m_client->h);
> +		sunrpc_invalidate(&ipm->h, sn->ip_map_cache);
>  		rv = NULL;
>  	} else {
>  		rv = &ipm->m_client->h;

