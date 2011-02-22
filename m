Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36958 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab1BVVHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Feb 2011 16:07:39 -0500
Date: Wed, 23 Feb 2011 08:07:31 +1100
From: NeilBrown <neilb@suse.de>
To: Rob Landley <rlandley@parallels.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: CACHE_NEW_EXPIRY is 120, nextcheck initialized to 30*60=1800?
Message-ID: <20110223080731.6c013be2@notabene.brown>
In-Reply-To: <4D63BAA0.3090505@parallels.com>
References: <4D63BAA0.3090505@parallels.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 22 Feb 2011 07:31:12 -0600 Rob Landley <rlandley@parallels.com> wrote:

> In net/sunrpc/cache.c line 416 or so (function cache_clean()) there's
> this bit:
> 
> else {
>         current_index = 0;
>         current_detail->nextcheck = seconds_since_boot()+30*60;
> }
> 
> The other uses of seconds_since_boot() add CACHE_NEW_EXPIRY (which is
> 120).  This is A) more than ten times that, B) a magic inline constant.
> 
> Is there a reason for this?  (Some subtle cache lifetime balancing thing?)

Apples and oranges are both fruit, but don't taste the same...


'nextcheck' is when to next clean old data out of the cache.  There is no
rush to remove this data, it is just about freeing up memory.  So every
half hour is fine.  Sometimes an immediate flush is called if there is a
pressing need to remove stuff, but by default, occasional is enough.

CACHE_NEW_EXPIRY is the expiry time for cache entries that are incomplete and
have not yet been filled-in by a down-call.  When user-space fills in a cache
entry it gets an expiry time, typically half and hour I think,  though that
is up to user-space.  If no down-call arrive for 120 seconds we forget about
it.  I don't recall the exact point of this - maybe it is to encourage a new
up-call..

But I agree that the 30*60 should be a #defined constant.  Patches welcome :-)

NeilBrown

