Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab1ADVVs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:21:48 -0500
Date: Tue, 4 Jan 2011 16:21:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110104212147.GF7908@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
 <20110103222605.GA24811@fieldses.org>
 <20110104030805.GA3194@fieldses.org>
 <20110104155107.0ff2c199@notabene.brown>
 <20110104184314.GD2308@fieldses.org>
 <20110105081538.0779659d@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110105081538.0779659d@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 08:15:38AM +1100, NeilBrown wrote:
> On Tue, 4 Jan 2011 13:43:14 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> > Yep, applied.
> > 
> > (When do we get to remove all this?  Taking a stab at the 2.6.40 merge
> > window....
> 
> That is what is says in feature-removal-schedule.txt (which no-one reads).
> 
> 
> >             OK, party at my place in May!)
> 
> Will there still be snow?  I'm not coming if there is no snow!

If anyone attends from Australia, I'll find the snow.  It may melt
rather quickly, though....

> (patch looks good)

Applied--thanks for the help!--b.

> 
> NeilBrown
> 
> 
> 
> > 
> > --b.
> > 
> > commit ab5c05c579b0b37b9bf2c79c9c8f0ef6045ee41d
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Fri Dec 24 14:03:38 2010 -0500
> > 
> >     svcrpc: modifying valid sunrpc cache entries is racy
> >     
> >     Once a sunrpc cache entry is VALID, we should be replacing it (and
> >     allowing any concurrent users to destroy it on last put) instead of
> >     trying to update it in place.
> >     
> >     Otherwise someone referencing the ip_map we're modifying here could try
> >     to use the m_client just as we're putting the last reference.
> >     
> >     The bug should only be seen by users of the legacy nfsd interfaces.
> >     
> >     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> > index a04ac91..59a7c52 100644
> > --- a/net/sunrpc/svcauth_unix.c
> > +++ b/net/sunrpc/svcauth_unix.c
> > @@ -401,8 +401,7 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
> >  		return NULL;
> >  
> >  	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
> > -		if (test_and_set_bit(CACHE_NEGATIVE, &ipm->h.flags) == 0)
> > -			auth_domain_put(&ipm->m_client->h);
> > +		sunrpc_invalidate(&ipm->h, sn->ip_map_cache);
> >  		rv = NULL;
> >  	} else {
> >  		rv = &ipm->m_client->h;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
