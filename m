Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357Ab0C3PJa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 11:09:30 -0400
Date: Tue, 30 Mar 2010 11:11:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/9] sunrpc: never return expired entries in
	sunrpc_cache_lookup
Message-ID: <20100330151138.GG11545@fieldses.org>
References: <20100203060657.12945.27293.stgit@notabene.brown> <20100203063131.12945.97779.stgit@notabene.brown> <20100317213307.GD2501@fieldses.org> <20100324122200.08f98be7@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100324122200.08f98be7@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 24, 2010 at 12:22:00PM +1100, Neil Brown wrote:
> On Wed, 17 Mar 2010 17:33:07 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Feb 03, 2010 at 05:31:31PM +1100, NeilBrown wrote:
> > > If sunrpc_cache_lookup finds an expired entry, remove it from
> > > the cache and return a freshly created non-VALID entry instead.
> > > This ensures that we only ever get a usable entry, or an
> > > entry that will become usable once an update arrives.
> > > i.e. we will never need to repeat the lookup.
> > > 
> > > This allows us to remove the 'is_expired' test from cache_check
> > > (i.e. from cache_is_valid).  cache_check should never get an expired
> > > entry as 'lookup' will never return one.  If it does happen - due to
> > > inconvenient timing - then just accept it as still valid, it won't be
> > > very much past it's use-by date.
> > 
> > Looks right to me.  Thanks, applied.
> > 
> > By the way, if we get sunrpc_cache_update(old, new1) and
> > sunrpc_cache_update(old, new2) simultaneously, what happens?
> 
> Interesting question.
> I guess you could get two entries for the same key in the cache.
> However the ->parse routines are protected by i_mutex

Oh, right, missed that.  Might simplify verification of this sort of
thing to have that be the responsibility of the core cache code rather
than the caller, though.

> so you would need on
> update to come through /proc/net/rpc/..../channel, and the other to come
> through the legacy nfsd syscal.
> Highly unlikely.
> 
> > 
> > More generally: should we try to ensure that a cache never contains two
> > entries which match the same key?
> 
> I don't think we need to.  The newer will over-ride the older which will
> eventually expire from the cache or be flushed.
> So worst-case someone will look in the /content file, see two entries with
> the same key, and get confused.  I don't think it is a problem that needs
> fixing.

Well, my real fear here is that an rpc call could stall indefinitely if
it waited on one item while the other one got updated.

I don't see how that's possible, though.

--b.
