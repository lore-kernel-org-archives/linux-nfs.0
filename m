Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37457 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182Ab0L3BTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 20:19:49 -0500
Date: Thu, 30 Dec 2010 12:19:40 +1100
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20101230121940.3f48223a@notabene.brown>
In-Reply-To: <20101229205942.GD12218@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
	<20101229205942.GD12218@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 29 Dec 2010 15:59:42 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Dec 29, 2010 at 03:47:52PM -0500, bfields wrote:
> > From: J. Bruce Fields <bfields@redhat.com>
> > 
> > Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
> > (and allowing any concurrent users to destroy it on last put) instead of
> > trying to update it in place.
> > 
> > Otherwise someone referencing the ip_map we're modifying here could try
> > to use the m_client just as we're putting the last reference.
> > 
> > The bug should only be seen by users of the legacy nfsd interfaces.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  net/sunrpc/svcauth_unix.c |   18 ++++++++++++++++--
> >  1 files changed, 16 insertions(+), 2 deletions(-)
> > 
> > Intended to apply for 2.6.38 if this looks right....
> 
> Also noticed while trying to track down an rhel5 oops in
> svcauth_unix_set_client():
> 
> 	- cache_check() can set an entry negative in place, which if
> 	  nothing else must cause a leak in some cases.  (Because when
> 	  the entry is eventually destroyed, it will be assumed to not
> 	  have any contents.)  I suppose the fix is again to try to
> 	  adding a new negative entry instead.

cache_check should only set an entry 'negative' if it is not already valid
(rv == -EAGAIN) and there is no up-call pending.

Maybe we should check CACHE_VALID again after the test_and_set of
CACHE_PENDING, but is a very unlikely race (if it is actually a race at all)

> 
> 	- since cache_check() doesn't use any locking, I can't see what
> 	  guarantees that when it sees the CACHE_VALID bit set and
> 	  CACHE_NEGATIVE cleared, it must necessarily see the new
> 	  contents.   I think that'd be fixed by a wmb() before setting
> 	  those bits and a rmb() after checking them.  I don't know if
> 	  it's actually possible to hit that bug....

Yes, we probably want a set_bit_lock in cache_fresh_locked() though I don't
think that exists, so we could use test_and_set_bit_locked() instead.

But it does feel like maybe we should add some locking to cache_check.
Take the lock at the the start, and release it after the
test_and_set_bit(CACHE_PENDING) or once we have decided not to do that ???

I think when I wrote this I might have thought that bit ops implied memory
ordering ... or maybe I just didn't think through the issues properly at all.

Thanks,
NeilBrown


> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

